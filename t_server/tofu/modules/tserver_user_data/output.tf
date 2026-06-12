output "user_data" {
  value = data.cloudinit_config.tserver.rendered
}
