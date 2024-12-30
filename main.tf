#aws_instance
resource "aws_instance" "example" {
  ami           = "ami-042e76978adeb8c48" #ubuntu 22.04 seoul region ami
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data  =  <<-EOF
                #!/bin/bash
                echo  "Hello, World"  >  index.html 
                nohup  busybox  httpd  -f  -p  8080  &
                EOF
  user_data_replace_on_change  =  true 

  tags  =  { 
    Name  =  "terraform-example"
  } 
}

#aws_security_group
resource  "aws_security_group" "instance"  {
  name  =  "terraform-example-instance" 
  
  ingress  { 
    from_port    =  8080 
    to_port      =  8080
    protocol     =  "tcp"
    cidr_blocks  =  [ "0.0.0.0/0" ] 
  }
}