#this is to create a private app server only accessible via ALB

resource "aws_instance" "cloud_watch_web_server" {
  ami                         = "ami-07a6f770277670015"
  instance_type               = "t2.micro"
  key_name                    = "debson_keypair" 
  subnet_id                   = aws_subnet.cloud_watch_private_subnet_az1a.id
  vpc_security_group_ids      = [aws_security_group.cloud_watch_web_server_sg.id]
  associate_public_ip_address = false

  user_data                   = <<-EOF
    #!/bin/bash
    sudo su
    yum update -y
    yum install -y httpd
    cd /var/www/html
    wget https://github.com/Ahmednas211/jupiter-zip-file/raw/main/jupiter-main.zip
    unzip jupiter-main.zip
    cp -r jupiter-main/* /var/www/html
    rm -rf jupiter-main jupiter-main.zip
    systemctl start httpd
    systemctl enable httpd
  EOF

  tags = {
    Name = "cloud_watch_instance"
  }
} 

# create an SNS CPU alerts for cloud_watch instance
resource "aws_sns_topic" "alerts" {
  name = "cpu-alerts-topic"
}

resource "aws_sns_topic_subscription" "cloud_watch_email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "adebolaanimashaun@gmail.com"
}

#create a CPU alarm trigger using cloudwatch
# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Triggered when CPU exceeds 70%"
  dimensions = {
    InstanceId = aws_instance.cloud_watch_web_server.id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

#create a cloudwatch log_group
resource "aws_cloudwatch_log_group" "cloud_watch_log_group" {
  name              = "/ec2/structured-logs"
  retention_in_days = 14
}