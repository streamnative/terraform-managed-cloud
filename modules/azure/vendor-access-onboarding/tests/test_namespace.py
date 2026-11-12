import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from check_namespace import collisions


class NamespaceTests(unittest.TestCase):
    def test_first_install_and_later_target_collision(self):
        groups = [{"name": name} for name in ("Manager-RG", "snce-abc-eastus-ce1", "Nodes-CE2", "customer")]
        self.assertEqual(collisions(groups, "snce-abc-", ["manager-rg"]), ["Manager-RG", "snce-abc-eastus-ce1"])
        self.assertEqual(collisions(groups, "", ["snce-abc-eastus-ce2", "nodes-ce2"]), ["Nodes-CE2"])
        self.assertEqual(collisions(groups, "", ["snce-abc-eastus-ce3", "nodes-ce3"]), [])

    def test_disposable_profile_rejects_every_existing_group(self):
        self.assertEqual(collisions([{"name": "customer-unrelated"}], "snce-abc-", ["manager-rg"], True), ["customer-unrelated"])
        self.assertEqual(collisions([], "snce-abc-", ["manager-rg"], True), [])
