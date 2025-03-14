provider "aws" {
region = "ap-south-1"
}

resource "aws_key_pair" "t_key" {
    key_name   = "first-key-pair"
    public_key = file("aws_terraform_key") 
    }

resource "aws_vpc" "t_vpc" {
  cidr_block = "10.0.0.0/16"
    tags = {
          Name = "firstVPC"
            }
          }

resource "aws_subnet" "t_subnet" {
  vpc_id            = aws_vpc.t_vpc.id
  cidr_block        = "10.0.1.0/24" 
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"  
  tags = {
    Name = "first-Subnet"
  }
}

resource "aws_internet_gateway" "t_igw" {
    vpc_id = aws_vpc.t_vpc.id
  }

  resource "aws_route_table" "t_public_route_table" {
      vpc_id = aws_vpc.t_vpc.id

        route {
              cidr_block = "0.0.0.0/0"
              gateway_id = aws_internet_gateway.t_igw.id
              }
    }

        resource "aws_route_table_association" "t_public_route_table_association" {
          subnet_id      = aws_subnet.t_subnet.id
          route_table_id = aws_route_table.t_public_route_table.id
                    }

resource "aws_security_group" "t_sg" {
    vpc_id = aws_vpc.t_vpc.id
    name   = "first-security-group"
    description = "Allow SSH and HTTP traffic"
    
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port  = 80
      to_port    = 80
      protocol   = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "first-security-group"
      }
    }

resource "aws_instance" "t_ec2" {
  count = 3
  ami           = "ami-053b12d3152c0cc71" 
    instance_type = "t2.micro"  
    key_name = aws_key_pair.t_key.key_name
    subnet_id     = aws_subnet.t_subnet.id 
    vpc_security_group_ids = [aws_security_group.t_sg.id]
    tags = {
           Name = "FirstEC2Instancei-${count.index + 1}"
          }
  }
output "instance_public_ips" {
    value = aws_instance.t_ec2[*].public_ip
  }
