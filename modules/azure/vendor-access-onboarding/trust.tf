# Copyright 2026 StreamNative, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

locals {
  # Exact current defaults, not an overridable list of arbitrary vendor identities.
  # https://github.com/streamnative/terraform-managed-cloud/blob/5a6be976945446aee9afff2d9464aaf2bfb4386c/modules/azure/sn-cloud-manager/main.tf
  trust_revision = "5a6be976945446aee9afff2d9464aaf2bfb4386c"
  automation_subjects = {
    test = {
      cloud_manager_sncloud_test_iam_gserviceaccount_com         = "103687585001802233900"
      pool_automation_sncloud_test_iam_gserviceaccount_com       = "101134291802756860252"
      cloud_support_general_sncloud_test_iam_gserviceaccount_com = "103182365501883681520"
    }
    staging = {
      cloud_manager   = "100475141292983344285"
      pool_automation = "100556251728244561373"
    }
    production = {
      cloud_manager   = "108050666045451143798"
      pool_automation = "108029274547326196788"
    }
  }
  support_subjects = {
    test = {
      cloud_support_general_sncloud_test_iam_gserviceaccount_com = "103182365501883681520"
    }
    staging = {
      cloud_support_general = "100434858314678442047"
    }
    production = {
      cloud_support_general = "105547309919970817091"
      cloud_support_china   = "118445804661219609076"
      cloud_support_eu      = "106226564917594611181"
      cloud_support_us      = "102988431238400117777"
    }
  }
}
