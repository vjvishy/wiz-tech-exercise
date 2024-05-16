output "region" {
  description = "AWS region"
  value       = var.aws_region
}
output "db_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "db_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "ec2_instance_dns_name" {
  description = "EC2 instance DNS Name"
  value       = module.ec2_instance.public_dns
}

output "db_instance_private_key" {
  description = "Private AWS EC2 Key Pair information"
  value       = module.key_pair.private_key_openssh
  sensitive   = true
}

output "s3_bucket_name" {
  description = "AWS S3 Name"
  value       = module.s3-bucket.s3_bucket_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

/*
output "public_dns_name" {
  description = "Public DNS names of the load balancer for this project"
  value       = module.elb_http.elb_dns_name
}
*/
