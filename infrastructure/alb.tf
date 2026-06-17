data "aws_autoscaling_group" "phoenix_nodes" {
  name = module.eks.eks_managed_node_groups_autoscaling_group_names[0]
}

resource "aws_security_group" "alb" {
  name        = "phoenix-app-alb"
  description = "Security group for phoenix-app ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
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
    Name        = "phoenix-app-alb"
    Environment = "production"
    Project     = "phoenix"
  }
}

resource "aws_security_group_rule" "node_alb_ingress" {
  description              = "ALB to node NodePort"
  type                     = "ingress"
  from_port                = 30080
  to_port                  = 30080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = module.eks.node_security_group_id
}

resource "aws_lb" "phoenix" {
  name               = "phoenix-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Name        = "phoenix-app-alb"
    Environment = "production"
    Project     = "phoenix"
  }
}

resource "aws_lb_target_group" "phoenix" {
  name        = "phoenix-app-tg"
  port        = 30080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name        = "phoenix-app-tg"
    Environment = "production"
    Project     = "phoenix"
  }
}

resource "aws_lb_listener" "phoenix" {
  load_balancer_arn = aws_lb.phoenix.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.phoenix.arn
  }
}

resource "aws_autoscaling_attachment" "phoenix" {
  autoscaling_group_name = data.aws_autoscaling_group.phoenix_nodes.name
  lb_target_group_arn    = aws_lb_target_group.phoenix.arn
}
