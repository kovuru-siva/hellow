  provider "aws" {
  region = var.region
}

data "aws_ami" "amazon_Linux" {
    most_recent = true
    owners = ["amazon"]

    filter {
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]

    }
  
}

data "aws_availability_zones" "available" {

}
resource "aws_key_pair" "first" {
  key_name = "first-key"
  public_key = file("~/.ssh/terraform_key.pub")
  
}

resource "aws_instance" "httpd" {
  ami = data.aws_ami.amazon_Linux.id
  instance_type = var.instance_type
  key_name  = aws_key_pair.first.key_name
  associate_public_ip_address = true

  tags = {
    Name = "Jenkins-HTTPD"
  }

  provisioner "local-exec" {
    command = "echo [web] > ../ansible/hosts && echo ${self.public_ip} >> ../ansible/hosts"
  }
}

output "pub_ip" {
  value = aws_instance.httpd.public_ip
  
}