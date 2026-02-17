# Changelog

## [3.23.2](https://github.com/streamnative/terraform-managed-cloud/compare/v3.23.1...v3.23.2) (2026-02-17)


### Bug Fixes

* Update permission boundary for vpce permissions ([#142](https://github.com/streamnative/terraform-managed-cloud/issues/142)) ([a03b303](https://github.com/streamnative/terraform-managed-cloud/commit/a03b303ef291629abdc38d3ecf1f38d74c2ef79d))

## [3.23.1](https://github.com/streamnative/terraform-managed-cloud/compare/v3.23.0...v3.23.1) (2026-02-17)


### Bug Fixes

* Add permissions to create private link service cross regions ([#140](https://github.com/streamnative/terraform-managed-cloud/issues/140)) ([c0380cf](https://github.com/streamnative/terraform-managed-cloud/commit/c0380cf52c9383d22560d63c3d854c0c58c68ed5))

## [3.23.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.22.1...v3.23.0) (2025-09-18)


### Features

* Declare SLB permissions on AliCloud ([#137](https://github.com/streamnative/terraform-managed-cloud/issues/137)) ([c9bb72e](https://github.com/streamnative/terraform-managed-cloud/commit/c9bb72e5c3e52575ecd96226a97aed02a76260dd))

## [3.22.1](https://github.com/streamnative/terraform-managed-cloud/compare/v3.22.0...v3.22.1) (2025-07-11)


### Bug Fixes

* remove provider block in child module ([#134](https://github.com/streamnative/terraform-managed-cloud/issues/134)) ([3d6c3ff](https://github.com/streamnative/terraform-managed-cloud/commit/3d6c3ffaa18509a245c921f17ba46d1191f0cbcf))

## [3.22.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.21.0...v3.22.0) (2025-06-11)


### Features

* Support alicloud international ([#130](https://github.com/streamnative/terraform-managed-cloud/issues/130)) ([fe64024](https://github.com/streamnative/terraform-managed-cloud/commit/fe640247e00f64245f89e83d7be188c505ea8942))

## [3.21.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.20.0...v3.21.0) (2025-04-15)


### Features

* Support creating separate PSC for each zone in GCP ([#127](https://github.com/streamnative/terraform-managed-cloud/issues/127)) ([7b7746a](https://github.com/streamnative/terraform-managed-cloud/commit/7b7746a222b5af3bc631c6722c9a333c60a5b002))

## [3.20.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.19.0...v3.20.0) (2025-04-03)


### Features

* support volume access for gcp ([#125](https://github.com/streamnative/terraform-managed-cloud/issues/125)) ([45ed5ac](https://github.com/streamnative/terraform-managed-cloud/commit/45ed5acb7f5575df6e1aa2b97b9dba27b574e854))


### Bug Fixes

* removed slash suffix for volume access module ([#124](https://github.com/streamnative/terraform-managed-cloud/issues/124)) ([32b5b54](https://github.com/streamnative/terraform-managed-cloud/commit/32b5b54798eaed23c0385896fb7f80152298472c))
* Rename account id to google service account id ([#126](https://github.com/streamnative/terraform-managed-cloud/issues/126)) ([2c26a43](https://github.com/streamnative/terraform-managed-cloud/commit/2c26a437c3819a1722c6750071b4b61f4d9f8423))
* update s3 table permission ([#122](https://github.com/streamnative/terraform-managed-cloud/issues/122)) ([1264638](https://github.com/streamnative/terraform-managed-cloud/commit/12646384589c0c8b1fdf661aa417098bde0fdd29))

## [3.19.0](https://github.com/streamnative/terraform-managed-cloud/compare/v3.18.0...v3.19.0) (2025-02-28)


### Features

* add permissions for karpenter ([#105](https://github.com/streamnative/terraform-managed-cloud/issues/105)) ([ec3f23b](https://github.com/streamnative/terraform-managed-cloud/commit/ec3f23b3c0a971ef8ae68da48b5ce06769e672b4))
* simplify azure vendor access module ([#118](https://github.com/streamnative/terraform-managed-cloud/issues/118)) ([8f46442](https://github.com/streamnative/terraform-managed-cloud/commit/8f46442ae9c9747403a0ad5264ed442b2d2e3109))
* Support s3 table ([#111](https://github.com/streamnative/terraform-managed-cloud/issues/111)) ([55280ad](https://github.com/streamnative/terraform-managed-cloud/commit/55280ad602c5f37f4fc76a70e1f9386f016eb9f8))


### Bug Fixes

* add s3tables to boundary ([#119](https://github.com/streamnative/terraform-managed-cloud/issues/119)) ([91d111d](https://github.com/streamnative/terraform-managed-cloud/commit/91d111d885e93ba733aac5a0147d51377046f471))
* allow detach instance profile ([#117](https://github.com/streamnative/terraform-managed-cloud/issues/117)) ([ac58095](https://github.com/streamnative/terraform-managed-cloud/commit/ac58095a118aacd7f887a401f65f13e70f64d325))
* reduce s3table access permission ([#120](https://github.com/streamnative/terraform-managed-cloud/issues/120)) ([29ad930](https://github.com/streamnative/terraform-managed-cloud/commit/29ad9305e8dfaaaa99933eaad34dc29ced78d3d0))

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
