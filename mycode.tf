
/*Create Ec2 Instance */
provider "aws" {
  region     = "us-east-1"
  profile    = "teruser"
}

/*Create Security Group and open port 80 and 22 */


 resource "aws_security_group" "ssh-http-fortf" {
  name        = "ssh-http-tf"
  description = "allow ssh and http traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}



resource "aws_instance" "myfirstin" {
    ami      = "ami-09d95fab7fff3776c" 
    instance_type  = "t2.micro"
    key_name       = "terkeypem"
    security_groups = [ "ssh-http-tf" ]
	
  
connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Dell/Desktop/terkey/terkeypem.pem")
    host     = aws_instance.myfirstin.public_ip 
	}
	
	 provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
       "sudo systemctl restart httpd",
      "sudo systemctl enable httpd", 
    ]
  }
tags = {
  Name = "terec21"   
   
}
}

resource "aws_ebs_volume" "ebsvo" {
  availability_zone = aws_instance.myfirstin.availability_zone
  size              = 1
  tags = {
    Name = "ebstest"
  }
}
resource "aws_volume_attachment" "ebsvol" {
 device_name = "/dev/sdc"
 volume_id = "${aws_ebs_volume.ebsvo.id}"
 instance_id = "${aws_instance.myfirstin.id}"
 force_detach = true
}

  resource "null_resource" "nullremote3" {

depends_on = [
    aws_volume_attachment.ebsvol,
  ]

connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Dell/Desktop/terkey/terkeypem.pem")
    host     = aws_instance.myfirstin.public_ip 
	}
	
	 provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdc",
      "sudo mount  /dev/xvdc  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/muraliv-it/1stdeploy.git /var/www/html/"
    ]
  }
 
 }
 
//  Creating S3 Bucket   
  resource "aws_s3_bucket" "testbucket" {
  bucket = "mys3bt1"
  acl = "private"
  force_destroy = "true" 
  versioning {
    enabled = true
  }

tags = {
    Name = "testbucket"
    Environment = "Dev"  
 
 }

 




