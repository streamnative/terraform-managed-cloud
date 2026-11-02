import json
import unittest
import urllib.error

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import submit_hints

TEST_ENDPOINT = "http://127.0.0.1:8765" + submit_hints.PATH


HINTS = {
    "organization": "o-poc01",
    "subscriptionId": "11111111-1111-4111-8111-111111111111",
    "tenantId": "22222222-2222-4222-8222-222222222222",
    "automationClientId": "33333333-3333-4333-8333-333333333333",
}


class Response:
    status = 202

    def __enter__(self):
        return self

    def __exit__(self, *args):
        pass


class Opener:
    def __init__(self, outcomes):
        self.outcomes = iter(outcomes)
        self.requests = []

    def open(self, request, timeout):
        self.requests.append(request)
        outcome = next(self.outcomes)
        if isinstance(outcome, Exception):
            raise outcome
        return outcome


class SubmitHintsTests(unittest.TestCase):
    def test_rejects_secret_or_unknown_fields(self):
        for extra in ("accessToken", "supportClientId", "endpoint"):
            with self.subTest(extra=extra), self.assertRaises(ValueError):
                submit_hints.validate_hints(json.dumps(HINTS | {extra: "unexpected"}))

    def test_rejects_display_names_and_noncanonical_ids(self):
        for changes in ({"organization": "Example Company"}, {"tenantId": "../../common"},
                        {"tenantId": "AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA"},
                        {"subscriptionId": "00000000-0000-0000-0000-000000000000"}):
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                submit_hints.validate_hints(json.dumps(HINTS | changes))

    def test_strict_json_and_size_boundary(self):
        raw = json.dumps(HINTS)
        self.assertEqual(submit_hints.validate_hints(raw.ljust(4096)), HINTS)
        for invalid in (raw.ljust(4097), raw[:-1] + ',"organization":"o-other"}', "[" * 1100):
            with self.subTest(raw=invalid[:40]), self.assertRaises(ValueError):
                submit_hints.validate_hints(invalid)

    def test_rejects_unsafe_endpoints(self):
        for endpoint in ("http://example.com" + submit_hints.PATH,
                         "https://user:password@example.com" + submit_hints.PATH,
                         "https://example.com" + submit_hints.PATH + "?token=secret",
                         "https://example.com/other", "file:///tmp/hints"):
            with self.subTest(endpoint=endpoint), self.assertRaises(ValueError):
                submit_hints.validate_endpoint(endpoint)

    def test_retries_transient_failure_without_auth_header(self):
        failure = urllib.error.HTTPError("unused", 429, "rate limited", {}, None)
        opener = Opener([failure, Response()])
        sleeps = []
        submit_hints.publish(TEST_ENDPOINT, HINTS, opener=opener, sleep=sleeps.append)
        self.assertEqual(sleeps, [1])
        self.assertEqual(len(opener.requests), 2)
        request = opener.requests[-1]
        self.assertIsNone(request.get_header("Authorization"))
        self.assertEqual(json.loads(request.data), HINTS)

    def test_redirect_and_permanent_failure_not_retried(self):
        for status in (301, 302, 307, 400, 403):
            with self.subTest(status=status):
                failure = urllib.error.HTTPError("unused", status, "sensitive body", {}, None)
                opener = Opener([failure])
                with self.assertRaisesRegex(RuntimeError, f"HTTP {status}"):
                    submit_hints.publish(TEST_ENDPOINT, HINTS, opener=opener)
                self.assertEqual(len(opener.requests), 1)

    def test_retry_limit(self):
        opener = Opener([TimeoutError(), TimeoutError()])
        with self.assertRaisesRegex(RuntimeError, "bounded retries"):
            submit_hints.publish(TEST_ENDPOINT, HINTS, attempts=2,
                                 opener=opener, sleep=lambda _: None)


if __name__ == "__main__":
    unittest.main()
