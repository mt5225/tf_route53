/* 
                      //-> rule01  ----------------------------> hosts_target01 -> server-01
      /^-listener[80] //-> ruleN -> ...                           ^
lb ==+                //-> default -> front_end_tg[80]           /
      \                                                         /
       \+-listener[443] //-> rule01  -------------------------+>
                        //-> ruleN -> ...
                        //-> default ->front_end_tg[443]
*/

variable "listeners" {
  description = "listener settings"
  type        = list
  default = [{
    port  = "80",
    proto = "http"
    }, {
    port  = "443",
    proto = "https"
  }]

}

locals {
  server_count = 0 #3
}

locals {
  subdomain_prefix = "app"
  rule_hoststarget = setproduct(aws_lb_listener.front_end.*.arn, aws_lb_target_group.*.arn)
}

resource "aws_lb" "elb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = ["subnet-09249a92f6e47afd4", "subnet-010f7f6678db9bb3a", "subnet-075758b93d48e7cfb"] # ${module.vpc.aws_subnet.public.*.id} TODO use module outputs 

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "vpc_lb"
  description = "Allow incoming HTTP connections."
  vpc_id      = module.vpc.vpc_id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "front_end" {
  count      = local.length(listeners)
  name       = "tf-example-lb-tg"
  port       = listeners[count.index].port
  protocol   = listeners[count.index].proto
  vpc_id     = module.vpc.vpc_id
  slow_start = 600 # 60 seconds * 10
}

resource "aws_lb_listener" "front_end" {
  count             = local.length(listeners)
  load_balancer_arn = aws_lb.elb.arn
  port              = listeners[count.index].port
  protocol          = listeners[count.index].proto
  #   ssl_policy        = "ELBSecurityPolicy-2016-08"
  #   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.front_end.*.arn, count.index)
  }
}


resource "aws_lb_listener_rule" "hosts_rule" {
  count        = length(local.rule_hoststarget)
  listener_arn = local.rule_hoststarget[count.index][0]
  priority     = "${count.index + 90}"

  action {
    type             = "forward"
    target_group_arn = local.rule_hoststarget[count.index][1]
  }

  condition {
    host_header {
      values = ["${local.subdomain_prefix}${count.index % local.server_count + 1}.baitelman.xyz"]
    }
  }
}

resource "aws_lb_target_group" "hosts_target" {
  count      = local.server_count
  name       = "tf-example-lb-tg-hosts${count.index + 1}"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = module.vpc.vpc_id
  slow_start = 600 # 60 seconds * 10
}

resource "aws_lb_target_group_attachment" "tg-attachment" {
  count            = local.server_count
  target_group_arn = element(aws_lb_target_group.hosts_target.*.arn, count.index)
  target_id        = element(aws_instance.servers.*.id, count.index)
  port             = 80
}

### EC2 Instances
resource "aws_instance" "servers" {
  count         = local.server_count
  ami           = "ami-04590e7389a6e577c"
  instance_type = "t2.micro"

  subnet_id = element(module.vpc.public_subnets, count.index)

  tags = {
    Name = "server-${count.index + 1}"
  }
}


### IAM User to de/register targets
resource "aws_iam_user" "lb_service_account" {
  name = "lb_service_account-svc"

}

resource "aws_iam_user_policy_attachment" "lb_service_account" {
  user       = "${aws_iam_user.lb_service_account.name}"
  policy_arn = "${aws_iam_policy.lb_service_account.arn}"
}

resource "aws_iam_policy" "lb_service_account" {
  policy = data.aws_iam_policy_document.lb_service_account.json

}


data "aws_iam_policy_document" "lb_service_account" {
  statement {
    actions = [
      "elasticloadbalancing:*"
    ]

    resources = [
      "arn:aws:elasticloadbalancing:us-west-2:*"
    ]

    effect = "Allow"
  }

}
