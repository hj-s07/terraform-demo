provider aws {}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"
  cluster_name = "webserver-stage"
  db_remote_state_bucket = "terraform-ssg-wl"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
  server_port = "8080"
}

output "lb_dns" {
 value = module.webserver_cluster.alb_dns_name
 description = "webserver stage load balancer"
}