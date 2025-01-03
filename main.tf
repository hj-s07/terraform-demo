#aws_instance
/*resource "aws_launch_configuration" "example" {
  image_id        = "ami-042e76978adeb8c48"
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html 
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
  lifecycle {
    create_before_destroy = true
  }
}*/

resource "aws_launch_template" "example" {
  image_id               = "ami-042e76978adeb8c48"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = filebase64("user-data.sh") #launch_template의 경우 직접 작성 불가
}

#aws_autoscaling_group
resource "aws_autoscaling_group" "example" {
  # launch_configuration = aws_launch_configuration.example.name
  launch_template {
    id = aws_launch_template.example.id
  }
  target_group_arns   = [aws_lb_target_group.asg.arn] #이게먼저 만들어져야 arn 참조 가능
  vpc_zone_identifier = data.aws_subnets.default.ids  #추가
  min_size            = 2
  max_size            = 10
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}
#
resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id] #security_groups 인수를 통해 이 보안 그룹을 사용하도록 aws_lb 리소스에 알림
}
#
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"
  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}
#
resource "aws_security_group" "alb" {
  name = "terraform-example-alb"
  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#
resource "aws_lb_listener_rule" "asg" {
 listener_arn = aws_lb_listener.http.arn
 priority = 100
 condition {
  path_pattern {
   values = ["*"]
  }
 }
 action {
  type = "forward"
  target_group_arn = aws_lb_target_group.asg.arn
 }
}

#aws_security_group
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "asg" { #autoscaling_group 부분 확인
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}