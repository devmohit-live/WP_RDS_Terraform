provider "aws" {
  region  = "ap-south-1"
  profile = "default"
}

# Creating Security Group:
resource "aws_security_group" "rdssg" {
  name        = "db"
  description = "security group for webservers"

  ingress {
    description = ""
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "MYSQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds sg"
  }
}


# Creating RDS
resource "aws_db_instance" "mydb" {
  depends_on             = [aws_security_group.rdssg]
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  vpc_security_group_ids = [aws_security_group.rdssg.id]
  engine_version         = "5.7.30"
  instance_class         = "db.t2.micro"
  name                   = "mywpdb"
  username               = "mohit"
  password               = "redhat123"
  parameter_group_name   = "default.mysql5.7"
  publicly_accessible    = true
  skip_final_snapshot    = true

  tags = {
    Name = "mywpdb"
  }
}

# *********  For Testing Purpose :   ************

# output "op" {
#   value = "username is :${aws_db_instance.mydb.username} , dbname is: ${aws_db_instance.mydb.name}, pass is : ${aws_db_instance.mydb.password} , address is : ${aws_db_instance.mydb.address}"
# }
# output "name" {
#   value = "sg id is ${aws_security_group.rdssg.id}"
# }
