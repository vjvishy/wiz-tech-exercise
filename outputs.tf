output "db_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "db_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "public_dns_name" {
  description = "Public DNS names of the load balancer for this project"
  value       = module.elb_http.elb_dns_name
}
