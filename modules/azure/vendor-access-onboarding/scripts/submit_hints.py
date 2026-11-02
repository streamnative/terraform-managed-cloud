#!/usr/bin/env python3
"""Apply-time discovery publication. Sends identifiers, never Azure bearer tokens.

Terraform supplies DISCOVERY_HINTS_JSON and DISCOVERY_ENDPOINT through the
process environment. This script does not invoke either cloud's login command.
"""

import argparse
import ipaddress
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid


FIELDS = {"organization", "subscriptionId", "tenantId", "automationClientId"}
PATH = "/v1/azure-discovery/hints"


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def validate_hints(raw):
    if not isinstance(raw, str) or len(raw.encode("utf-8")) > 4096:
        raise ValueError("discovery hints must be a JSON object smaller than 4096 bytes")
    def unique_pairs(items):
        result = {}
        for key, value in items:
            if key in result:
                raise ValueError("duplicate discovery field")
            result[key] = value
        return result

    try:
        hints = json.loads(raw, object_pairs_hook=unique_pairs)
    except (ValueError, RecursionError):
        raise ValueError("discovery hints must be valid JSON without duplicate fields") from None
    if not isinstance(hints, dict) or set(hints) != FIELDS:
        raise ValueError("expected exactly organization, subscriptionId, tenantId, automationClientId")
    if not all(isinstance(value, str) for value in hints.values()):
        raise ValueError("all discovery hint values must be strings")
    if not re.fullmatch(r"[a-z0-9](?:[-a-z0-9]{0,61}[a-z0-9])?", hints["organization"]):
        raise ValueError("organization must be the canonical API namespace, not its display name")
    for field in FIELDS - {"organization"}:
        value = uuid.UUID(hints[field])
        if value.int == 0 or str(value) != hints[field]:
            raise ValueError("identity fields must be nonzero canonical UUIDs")
        hints[field] = str(value)
    return hints


def validate_endpoint(endpoint):
    parsed = urllib.parse.urlsplit(endpoint)
    if parsed.username is not None or parsed.password is not None or parsed.query or parsed.fragment:
        raise ValueError("endpoint must not contain credentials, query parameters, or a fragment")
    if parsed.path != PATH or not parsed.hostname:
        raise ValueError("endpoint must use the discovery hints API path")
    # Accessing port also rejects malformed or out-of-range ports.
    _ = parsed.port
    loopback = parsed.hostname == "localhost"
    try:
        loopback = loopback or ipaddress.ip_address(parsed.hostname).is_loopback
    except ValueError:
        pass
    if parsed.scheme != "https" and not (parsed.scheme == "http" and loopback):
        raise ValueError("HTTPS is required except for the loopback-only PoC")
    return endpoint


def publish(endpoint, hints, attempts=6, opener=None, sleep=time.sleep):
    if not 1 <= attempts <= 8:
        raise ValueError("attempts must be between 1 and 8")
    opener = opener or urllib.request.build_opener(NoRedirect())
    payload = json.dumps(hints, sort_keys=True).encode("utf-8")
    request = urllib.request.Request(
        validate_endpoint(endpoint), data=payload, method="POST",
        headers={"Content-Type": "application/json", "Accept": "application/json"},
    )
    for attempt in range(attempts):
        try:
            with opener.open(request, timeout=15) as response:
                if response.status != 202:
                    raise RuntimeError("discovery endpoint did not return HTTP 202")
                # Acceptance is deliberately not a claim of verified access.
                return
        except urllib.error.HTTPError as error:
            retryable = error.code == 429 or 500 <= error.code < 600
            if not retryable:
                raise RuntimeError(f"discovery submission rejected (HTTP {error.code})") from None
        except (urllib.error.URLError, TimeoutError):
            pass
        if attempt + 1 < attempts:
            sleep(min(2 ** attempt, 16))
    raise RuntimeError("discovery submission unavailable after bounded retries; retry apply")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="validate without sending a request")
    parser.add_argument("--attempts", type=int, default=6)
    args = parser.parse_args(argv)
    try:
        hints = validate_hints(os.environ.get("DISCOVERY_HINTS_JSON", ""))
        endpoint = validate_endpoint(os.environ.get("DISCOVERY_ENDPOINT", ""))
        if args.dry_run:
            print("Discovery payload and endpoint validated; no request sent.")
            return 0
        publish(endpoint, hints, attempts=args.attempts)
        print("Discovery hints accepted. Connection verification is a separate backend outcome.")
        return 0
    except (ValueError, RuntimeError) as error:
        # Do not include HTTP response bodies or environment values in errors.
        print(str(error), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
