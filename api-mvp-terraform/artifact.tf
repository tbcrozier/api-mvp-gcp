resource "google_artifact_registry_repository" "docker" {
  project       = var.project_id
  location      = var.region
  repository_id = "mvp-docker-repo"
  format        = "DOCKER"
  description   = "Docker images for API MVP"
}
