# Changelog

## [3.18.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.17.0...v3.18.0) (2025-01-14)


### Features

* Support permission init for control plane management volume ([#104](https://github.com/streamnative/terraform-managed-cloud/issues/104)) ([54cfb6f](https://github.com/streamnative/terraform-managed-cloud/commit/54cfb6f0c0a7a2d325691c24a3e402b6c46950e3))


### Bug Fixes

* **azure:** add `depends_on` for azure vendor-access module ([#109](https://github.com/streamnative/terraform-managed-cloud/issues/109)) ([64ee2b3](https://github.com/streamnative/terraform-managed-cloud/commit/64ee2b319d446f4cd03100d6c922331a104673dc))

## [3.17.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.16.1...v3.17.0) (2025-01-07)


### Features

* **azure:** add `Storage Blob Data Owner` for role assignment condition ([#106](https://github.com/streamnative/terraform-managed-cloud/issues/106)) ([b6506da](https://github.com/streamnative/terraform-managed-cloud/commit/b6506dac7c4b6b314129db9233b17e3ed7ccb72f))

## [3.16.1](https://github.com/streamnative/terraform-managed-cloud/compare/v3.16.0...v3.16.1) (2024-11-25)


### Bug Fixes

* Add new required EKS permissions ([#99](https://github.com/streamnative/terraform-managed-cloud/issues/99)) ([cfa2446](https://github.com/streamnative/terraform-managed-cloud/commit/cfa24462cd61df1ce96bbcbb15c9ce0aa9b0958c))

## [3.16.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.15.0...v3.16.0) (2024-11-20)


### Features

* Allow array of Org IDs ([#97](https://github.com/streamnative/terraform-managed-cloud/issues/97)) ([3990b48](https://github.com/streamnative/terraform-managed-cloud/commit/3990b48e511022c6e98f8f02fa2dee182cba8cdf))
* Split AWS Policies ([#98](https://github.com/streamnative/terraform-managed-cloud/issues/98)) ([9c404c0](https://github.com/streamnative/terraform-managed-cloud/commit/9c404c00b5f3b7889c979b06ae2266dee65abaa1))


### Bug Fixes

* update source path for new version ([#95](https://github.com/streamnative/terraform-managed-cloud/issues/95)) ([db248d5](https://github.com/streamnative/terraform-managed-cloud/commit/db248d5eb7ca8fcea9e20b22c30b7402f4634bf1))

## [3.15.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.14.1...v3.15.0) (2024-07-27)


### Features

* **aws:** add private link module ([#92](https://github.com/streamnative/terraform-managed-cloud/issues/92)) ([b99a234](https://github.com/streamnative/terraform-managed-cloud/commit/b99a234e9a588344bb389080996ea800c9dcff4c))
* Support GCP impersonation ([#94](https://github.com/streamnative/terraform-managed-cloud/issues/94)) ([97cfe1c](https://github.com/streamnative/terraform-managed-cloud/commit/97cfe1c53f6d9fa12953e975a7db5a71502197f5))

## [3.14.1](https://github.com/streamnative/terraform-managed-cloud/compare/v3.14.0...v3.14.1) (2024-07-05)


### Bug Fixes

* Prioritizing streamnative_google_account_ids  ([#87](https://github.com/streamnative/terraform-managed-cloud/issues/87)) ([409f5e5](https://github.com/streamnative/terraform-managed-cloud/commit/409f5e5e37f432217922b92f805591455b1ef7e5))

## [3.14.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.13.1...v3.14.0) (2024-07-02)


### Features

* update federated web identify to support multiple gsa ids ([#85](https://github.com/streamnative/terraform-managed-cloud/issues/85)) ([bdf1df7](https://github.com/streamnative/terraform-managed-cloud/commit/bdf1df7f9a34d614ddfd2a1eb91d11406b69d3c2))

## [3.13.1](https://github.com/streamnative/terraform-managed-cloud/compare/v3.13.0...v3.13.1) (2024-05-22)


### Bug Fixes

* autoscaling condition key ([470011e](https://github.com/streamnative/terraform-managed-cloud/commit/470011e4a69ac80ccb9813a3ce032bc272950094))
* **aws:** autoscaling condition key ([#84](https://github.com/streamnative/terraform-managed-cloud/issues/84)) ([470011e](https://github.com/streamnative/terraform-managed-cloud/commit/470011e4a69ac80ccb9813a3ce032bc272950094))
* use wildcard dns records for brokers in Azure private endpoint module ([#82](https://github.com/streamnative/terraform-managed-cloud/issues/82)) ([0528113](https://github.com/streamnative/terraform-managed-cloud/commit/0528113df0c5905abbf5958274470c680f79ca42))

## [3.13.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.12.0...v3.13.0) (2024-05-07)


### Features

* Add KMS for encrypting k8s etcd ([#77](https://github.com/streamnative/terraform-managed-cloud/issues/77)) ([4632366](https://github.com/streamnative/terraform-managed-cloud/commit/46323664400a0f46ca8f674bb238d6c0241ca86a))
* Allow iam:PutRolePolicy and iam:DeleteRolePolicy in aws ([#79](https://github.com/streamnative/terraform-managed-cloud/issues/79)) ([8740a56](https://github.com/streamnative/terraform-managed-cloud/commit/8740a562ecaf847a54ec0209bcb70fe4c721547b))
* **aws:** allow update route tables ([#80](https://github.com/streamnative/terraform-managed-cloud/issues/80)) ([577978d](https://github.com/streamnative/terraform-managed-cloud/commit/577978d4900fcde37a37be1c84ca620cc7f2ca10))

## [3.12.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.11.1...v3.12.0) (2024-04-08)


### Features

* add module for creating private endpoint and private dns record in Azure ([#75](https://github.com/streamnative/terraform-managed-cloud/issues/75)) ([bba75e0](https://github.com/streamnative/terraform-managed-cloud/commit/bba75e0a453a084e17e9284aa2c3c901c5c93a33))
* update aws role session duration ([#71](https://github.com/streamnative/terraform-managed-cloud/issues/71)) ([0683fc6](https://github.com/streamnative/terraform-managed-cloud/commit/0683fc6a89661894b27b8929ae1a4f1e058df50e))

## [3.11.1](https://github.com/streamnative/terraform-managed-cloud/compare/v3.11.0...v3.11.1) (2024-01-24)


### Bug Fixes

* fix typo ([#64](https://github.com/streamnative/terraform-managed-cloud/issues/64)) ([fbafeb2](https://github.com/streamnative/terraform-managed-cloud/commit/fbafeb2ca6647cb81e81d4c0d2143a1484f6e414))

## [3.11.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.10.0...v3.11.0) (2024-01-23)


### Features

* add azure production and staging env gsa ids ([#56](https://github.com/streamnative/terraform-managed-cloud/issues/56)) ([c935c91](https://github.com/streamnative/terraform-managed-cloud/commit/c935c91fd8a1728ece33fe2489bbca5f592eef47))


### Bug Fixes

* github workflow permission ([#57](https://github.com/streamnative/terraform-managed-cloud/issues/57)) ([1217189](https://github.com/streamnative/terraform-managed-cloud/commit/121718952f2ade66601a13816acc75286c5d6ca6))
* reduce character count ([#62](https://github.com/streamnative/terraform-managed-cloud/issues/62)) ([5c423ef](https://github.com/streamnative/terraform-managed-cloud/commit/5c423ef5affaaf5425e204bda890bf9d9c7b8211))
* reduce character limitr ([#61](https://github.com/streamnative/terraform-managed-cloud/issues/61)) ([d022643](https://github.com/streamnative/terraform-managed-cloud/commit/d0226435bf34e7be7539e90c73e82c629e646a2a))
* update aws policy ([a08c964](https://github.com/streamnative/terraform-managed-cloud/commit/a08c96475eb52c9385798a1d8e6e212c4f148f2e))
* update aws policy and docs ([#59](https://github.com/streamnative/terraform-managed-cloud/issues/59)) ([a08c964](https://github.com/streamnative/terraform-managed-cloud/commit/a08c96475eb52c9385798a1d8e6e212c4f148f2e))

## [3.10.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.9.0...v3.10.0) (2024-01-23)


### Features

* add azure production and staging env gsa ids ([#56](https://github.com/streamnative/terraform-managed-cloud/issues/56)) ([c935c91](https://github.com/streamnative/terraform-managed-cloud/commit/c935c91fd8a1728ece33fe2489bbca5f592eef47))
* remove sub level permission for azure cloud manager ([#55](https://github.com/streamnative/terraform-managed-cloud/issues/55)) ([4631fb4](https://github.com/streamnative/terraform-managed-cloud/commit/4631fb4893e5747f8dad9020ce46a54e198eaf74))


### Bug Fixes

* github workflow permission ([#57](https://github.com/streamnative/terraform-managed-cloud/issues/57)) ([1217189](https://github.com/streamnative/terraform-managed-cloud/commit/121718952f2ade66601a13816acc75286c5d6ca6))
* update aws policy ([a08c964](https://github.com/streamnative/terraform-managed-cloud/commit/a08c96475eb52c9385798a1d8e6e212c4f148f2e))
* update aws policy and docs ([#59](https://github.com/streamnative/terraform-managed-cloud/issues/59)) ([a08c964](https://github.com/streamnative/terraform-managed-cloud/commit/a08c96475eb52c9385798a1d8e6e212c4f148f2e))

## [3.9.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.8.0...v3.9.0) (2023-12-11)


### Features

* update permissions for bootstrap and boundary policy ([#52](https://github.com/streamnative/terraform-managed-cloud/issues/52)) ([711f06a](https://github.com/streamnative/terraform-managed-cloud/commit/711f06a03029ffe2d1eb2b1584f5818d1434abc1))


### Bug Fixes

* add pr check ci ([e5bf7e6](https://github.com/streamnative/terraform-managed-cloud/commit/e5bf7e6f13766587f8cfd426c2551ef4fdac4db9))
* add pr check ci ([#53](https://github.com/streamnative/terraform-managed-cloud/issues/53)) ([e5bf7e6](https://github.com/streamnative/terraform-managed-cloud/commit/e5bf7e6f13766587f8cfd426c2551ef4fdac4db9))

## [3.8.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.7.0...v3.8.0) (2023-11-01)


### Features

* add ReadOnlyAccess policy for bootstrap and management role ([#47](https://github.com/streamnative/terraform-managed-cloud/issues/47)) ([5e26b08](https://github.com/streamnative/terraform-managed-cloud/commit/5e26b08b5c576daece0818a03642648fe53b6a27))


### Bug Fixes

* Add provider version requirement for private service ([#48](https://github.com/streamnative/terraform-managed-cloud/issues/48)) ([ca4efe3](https://github.com/streamnative/terraform-managed-cloud/commit/ca4efe32b820eefc6e4aa394f24c41201292da12))

## [3.7.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.6.1...v3.7.0) (2023-10-24)


### Features

* Add GCP BYOC vendor access module ([#42](https://github.com/streamnative/terraform-managed-cloud/issues/42)) ([98b0dd9](https://github.com/streamnative/terraform-managed-cloud/commit/98b0dd9fd287e79d6952171f9b262376b79b2361))

## [3.6.1](https://github.com/streamnative/terraform-managed-cloud/compare/v3.6.0...v3.6.1) (2023-10-09)


### Bug Fixes

* typo in bootstrap template ([#39](https://github.com/streamnative/terraform-managed-cloud/issues/39)) ([70922ee](https://github.com/streamnative/terraform-managed-cloud/commit/70922ee89eaa27f88994cd9496f1b39f1790eef3))

## [3.6.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.5.0...v3.6.0) (2023-10-09)


### Features

* add iam policy for aws vpc peering ([#37](https://github.com/streamnative/terraform-managed-cloud/issues/37)) ([b67eeae](https://github.com/streamnative/terraform-managed-cloud/commit/b67eeae0c8ef0713f6f12859d4cfccc193ab15a4))

## [3.5.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.4.0...v3.5.0) (2023-08-02)


### Features

* Support create private service endpoint on shared VPC ([#34](https://github.com/streamnative/terraform-managed-cloud/issues/34)) ([8c9dc5d](https://github.com/streamnative/terraform-managed-cloud/commit/8c9dc5d7fdfceff140ae6ec59ec6cb5d92f53c27))
