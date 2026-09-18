"""Offline checks for ACK tag-update authorization; no cloud credentials required."""

import fnmatch
import json
from pathlib import Path
import subprocess
import tempfile
import unittest


POLICY = (Path(__file__).resolve().parents[1]
          / "modules/alicloud/vendor-access/files/access_policy.json.tpl")
ACCOUNT = "1234567890123456"
REGION = "cn-hangzhou"


def render_policy(region):
    expression = (
        f"jsonencode(jsondecode(templatefile({json.dumps(str(POLICY))}, "
        f"{json.dumps({'account_id': ACCOUNT, 'region': region})})))\n"
    )
    with tempfile.TemporaryDirectory() as directory:
        result = subprocess.run(
            ["terraform", "console", "-no-color"], input=expression,
            cwd=directory, text=True, capture_output=True, check=True,
        )
    return json.loads(json.loads(result.stdout))


def tag_update_statements(policy):
    return [statement for statement in policy["Statement"]
            if statement["Effect"] == "Allow" and any(
                fnmatch.fnmatchcase("cs:ModifyClusterTags", action)
                for action in statement["Action"])]


class AckTagUpdatePolicyTest(unittest.TestCase):
    def test_existing_cluster_tag_update_is_scoped_to_account_and_region(self):
        statements = tag_update_statements(render_policy(REGION))
        self.assertTrue(statements, "Existing ACK tag updates need cs:ModifyClusterTags")
        for statement in statements:
            self.assertEqual(statement["Resource"],
                             [f"acs:cs:{REGION}:{ACCOUNT}:cluster/*"])
            self.assertNotIn("Condition", statement,
                             "Tag backfills must not require the new tags to exist")
        resources = [resource for statement in statements
                     for resource in statement["Resource"]]
        for arn, allowed in [
            (f"acs:cs:{REGION}:{ACCOUNT}:cluster/c-existing", True),
            (f"acs:cs:cn-shanghai:{ACCOUNT}:cluster/c-existing", False),
            (f"acs:cs:{REGION}:9999999999999999:cluster/c-existing", False),
            (f"acs:cs:{REGION}:{ACCOUNT}:nodepool/np-existing", False),
        ]:
            with self.subTest(arn=arn):
                self.assertEqual(any(fnmatch.fnmatchcase(arn, resource)
                                     for resource in resources), allowed)

    def test_default_region_retains_account_and_cluster_scope(self):
        statements = tag_update_statements(render_policy("*"))
        self.assertTrue(statements)
        for statement in statements:
            self.assertEqual(statement["Resource"],
                             [f"acs:cs:*:{ACCOUNT}:cluster/*"])


if __name__ == "__main__":
    unittest.main()
