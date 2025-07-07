resource "kubernetes_service_account" "flask_sa" {
  metadata {
    name      = "flask-sa"
    namespace = "default"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.app.email
    }
  }
}

resource "kubernetes_deployment" "flask" {
  metadata {
    name      = "flask-api"
    namespace = "default"
    labels    = { app = "flask-api" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "flask-api" }
    }
    template {
      metadata { labels = { app = "flask-api" } }
      spec {
        service_account_name = kubernetes_service_account.flask_sa.metadata[0].name
        container {
          name  = "flask-api"
          image = var.image
          port { container_port = 8080 }
          readiness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask" {
  metadata {
    name      = "flask-api"
    namespace = "default"
  }
  spec {
    type = "NodePort"            # <- allow GCE Ingress to use it
    selector = { app = kubernetes_deployment.flask.spec[0].template[0].metadata[0].labels.app }
    port {
      port        = 80
      target_port = 8080
    }
  }
}


resource "kubernetes_ingress_v1" "flask" {
  metadata {
    name = "flask-ingress"
    annotations = {
      # optional, but keeps older tooling happy
      "kubernetes.io/ingress.class" = "gce"
    }
  }

  spec {
    ingress_class_name = "gce"     # << — this tells GKE which controller to use

    rule {
      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.flask.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
