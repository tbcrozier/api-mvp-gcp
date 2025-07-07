resource "google_service_account" "app" {
  account_id   = "flask-api-sa"
  display_name = "Flask API Service Account"
}

resource "google_project_iam_member" "fhir_reader" {
  project = var.project_id
  role    = "roles/healthcare.fhirResourceReader"
  member  = "serviceAccount:${google_service_account.app.email}"
}

resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = google_service_account.app.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/flask-sa]"
}

resource "google_project_iam_member" "nodes_ar_pull" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}
