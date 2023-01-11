output "vpc_name" {
  value = module.vpc.name
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "first_az" {
  value = module.vpc.azs[0]
}
output "second_az" {
  value = module.vpc.azs[1]
}
output "first_subnet" {
  value = module.vpc.public_subnets[0]
}
output "second_subnet" {
  value = module.vpc.public_subnets[1]
}
output "sg_name" {
  value = module.sg.security_group_name
}
output "sg_id" {
  value = module.sg.security_group_id
}
output "key_pair" {
  value = aws_key_pair.test.key_name
}
output "placement_group" {
  value = aws_placement_group.cluster.id
}
