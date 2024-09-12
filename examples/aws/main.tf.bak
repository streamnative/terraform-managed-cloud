# Copyright 2023 StreamNative, Inc.
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

provider "aws" {
  region = "us-west-2"
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws/vendor-access?ref=v3.15.0"

  external_id = "o-wak6b"

  # This is for staging env
  streamnative_vendor_access_role_arns  = ["arn:aws:iam::311022431024:role/cloud-manager", "arn:aws:iam::554905616298:role/cloud-manager", "arn:aws:iam::738562057640:role/cloud-manager"]
  streamnative_support_access_role_arns = ["arn:aws:iam::311022431024:role/cloud-support-general", "arn:aws:iam::554905616298:role/cloud-support-general", "arn:aws:iam::738562057640:role/cloud-support-general"]
}