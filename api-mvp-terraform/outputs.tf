output "cluster_endpoint" {
  description = "GKE API server endpoint"
  value       = google_container_cluster.primary.endpoint
}

 output "ingress_ip" {
   description = "External IP of the HTTP(S) load balancer (empty until ready)"
   value       = try(
     kubernetes_ingress_v1.flask.status[0].load_balancer[0].ingress[0].ip,
     ""
   )
 }


