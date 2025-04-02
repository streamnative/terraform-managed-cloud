locals {
  streamnative_gsa = distinct(var.streamnative_vendor_access_gsa)
  cluster_projects = distinct(var.cluster_projects)
  buckets_list     = distinct([for item in var.buckets : "${split("/", item)[0]}"])
  buckets_path     = distinct([for item in var.buckets : "${replace(item, "/(\\/|\\/\\*)+$/", "")}"])
}

# Grant permissions to the project service account that will be impersonated by StreamNative Control Plane service account
locals {
  impersonation_roles = [
    "roles/storage.objectUser",
    "roles/storage.objectViewer",
  ]
  impersonation_iam_bindings = flatten([
    for role in local.impersonation_roles : [
      for bucket_path in local.buckets_path : {
        bucket : split("/", bucket_path)[0],
        role : role,
        expression : role == "roles/storage.objectViewer" ? "" : (length(split("/", bucket_path)) == 1 ? format("resource.name.startsWith(\"projects/_/buckets/%s/objects\")", split("/", bucket_path)[0]) : format("resource.name.startsWith(\"projects/_/buckets/%s/objects/%s/\")", split("/", bucket_path)[0], join("/", slice(split("/", bucket_path), 1, length(split("/", bucket_path))))))
      }
    ]
  ])

}
resource "google_service_account" "gsa" {
  account_id   = var.google_service_account_id
  project      = var.project
  display_name = "StreamNative Cloud access bucket service account."
}

resource "google_storage_bucket_iam_member" "gcs" {
  count  = length(local.impersonation_iam_bindings)
  bucket = local.impersonation_iam_bindings[count.index].bucket
  role   = local.impersonation_iam_bindings[count.index].role
  member = "serviceAccount:${google_service_account.gsa.email}"

  condition {
    title       = "restrict_to_data_path"
    description = "Restrict gcs access"
    expression  = local.impersonation_iam_bindings[count.index].expression
  }

  depends_on = [google_service_account.gsa]
}

resource "google_service_account_iam_member" "sn_control_plane" {
  count              = length(local.streamnative_gsa)
  service_account_id = google_service_account.gsa.id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${local.streamnative_gsa[count.index]}"
  depends_on         = [google_service_account.gsa]
}

data "google_project" "project" {
  count      = length(local.cluster_projects)
  project_id = local.cluster_projects[count.index]
}

resource "google_service_account_iam_member" "sn_data_plane" {
  count              = length(local.cluster_projects)
  service_account_id = google_service_account.gsa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.project[count.index].number}/locations/global/workloadIdentityPools/${local.cluster_projects[count.index]}.svc.id.goog/namespace/${var.streamnative_org_id}"
  depends_on         = [google_service_account.gsa]

}

output "google_service_account" {
  value       = google_service_account.gsa
  description = "Google Service Account for Access GCS Bucket"
  depends_on  = [google_service_account.gsa]
}
