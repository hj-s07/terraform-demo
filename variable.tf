variable "server_port" {
  description = "The port. the server will use for HTTP requests"
  type        = number
}

output "alb_dns_name" { #dns 출력
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

/*output "public_ip" { #asg, lb 사용을 위한 주석처리
  value       = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}*/