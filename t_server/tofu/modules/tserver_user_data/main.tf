data "cloudinit_config" "tserver" {
  gzip          = true
  base64_encode = true

  # Common part
  part {
    content_type = "text/cloud-config"
    merge_type   = "list(append,recurse_list)+dict(no_replace,recurse_list)+str()"
    content = jsonencode({
      packages = [ "git" ]
      package_update = true
      package_upgrade = true
      # This seems to only works on Ubuntu
      package_reboot_if_required = true
      preserve_hostname = false
      hostname = var.hostname
      fqdn = var.my_fqdn
      create_hostname_file = true
      write_files = [
        {
          path        = "/var/lib/provision/deployment-config.sh",
          content     = templatefile("${path.module}/provision/deployment-config.sh",
                            {
                              default_user  = var.default_user,
                              default_group = var.default_group,
                              tserver_fqdn = var.tserver_fqdn
                            }
                        ),
          permissions = "0o755",
        },
        {
          path        = "/var/lib/provision/05-install-openvpn-build-deps.sh",
          content     = file("${path.module}/provision/05-install-openvpn-build-deps.sh"),
          permissions = "0o755",
        },
        {
          path        = "/var/lib/provision/install-openvpn-build-deps-rhel-9.sh",
          content     = file("${path.module}/provision/install-openvpn-build-deps-rhel-9.sh"),
          permissions = "0o755",
        },
        {
          path        = "/var/lib/provision/10-prepare_t_server.sh",
          content     = file("${path.module}/provision/10-prepare_t_server.sh"),
          permissions = "0o755",
        },
        {
          path = "/var/lib/provision/15-clone-repos.sh",
          content = file("${path.module}/provision/15-clone-repos.sh"),
          permissions = "0o755",
        },
        {
          path        = "/var/lib/provision/25-build-openvpn.sh",
          content     = file("${path.module}/provision/25-build-openvpn.sh"),
          permissions = "0o755",
        },
        {
          path        = "/var/lib/provision/26-copy-initial-openvpn.sh",
          content     = file("${path.module}/provision/26-copy-initial-openvpn.sh"),
          permissions = "0o755",
        },
        {
          path        = "/var/lib/provision/30-schedule-ovpn-dco-build.sh",
          content     = file("${path.module}/provision/30-schedule-ovpn-dco-build.sh"),
          permissions = "0o755",
        },
        {
          path        = "/var/lib/provision/build-ovpn-dco.sh",
          content     = file("${path.module}/provision/build-ovpn-dco.sh"),
          permissions = "0o755",
        },
        {
          path        = "/var/lib/provision/build-ovpn-dco.service",
          content     = file("${path.module}/provision/build-ovpn-dco.service"),
          permissions = "0o644",
        },
      ]
      runcmd = [
         "mkdir -p ${local.keydir}",
         # Add the t_server SSH authorized key as the very first step. Do not
         # overwrite the default user's existing authorized key created by the
         # Cloud provider.
         "sudo -u ${var.default_user} echo ${var.ssh_public_key} >> /home/${var.default_user}/.ssh/authorized_keys",
         "/var/lib/provision/05-install-openvpn-build-deps.sh",
         "dnf -y install vim tmux",
         "sudo -u ${var.default_user} /var/lib/provision/10-prepare_t_server.sh",
         "chown -R ${var.default_user}:${var.default_user} ${var.data_dir}",
         # Add compatibility link for old OpenVPN configuration files
         "ln -s ${var.data_dir} /root/",
         "sudo -u ${var.default_user} /var/lib/provision/15-clone-repos.sh",
         "sudo -u ${var.default_user} /var/lib/provision/25-build-openvpn.sh",
         "sudo -u ${var.default_user} /var/lib/provision/26-copy-initial-openvpn.sh",
         "sudo -u ${var.default_user} /var/lib/provision/30-schedule-ovpn-dco-build.sh",
      ]
    })
  }

  # Server VM
  dynamic "part" {
    for_each = var.tserver == true ? [1] : []

    content {
      content_type = "text/cloud-config"
      merge_type   = "list(append,recurse_list)+dict(no_replace,recurse_list)+str()"
      content = jsonencode({
        write_files = [
          {
            path        = "/var/lib/provision/id_ed25519",
            content     = var.ssh_private_key,
            permissions = "0o600",
          },
          {
            path        = "/var/lib/provision/20-build-openssl.sh",
            content     = file("${path.module}/provision/20-build-openssl.sh"),
            permissions = "0o755",
          },
          {
            path        = "/var/lib/provision/28-setup-test-dependencies.sh",
            content     = file("${path.module}/provision/28-setup-test-dependencies.sh"),
            permissions = "0o755",
          },
          {
            path        = "/var/lib/provision/35-generate-dh-params.sh",
            content     = file("${path.module}/provision/35-generate-dh-params.sh"),
            permissions = "0o755",
          },
          {
            path        = "/var/lib/provision/36-generate-secret-keys.sh",
            content     = file("${path.module}/provision/36-generate-secret-keys.sh"),
            permissions = "0o755",
          },
          {
            path        = "/var/lib/provision/40-build-sample-plugins.sh",
            content     = file("${path.module}/provision/40-build-sample-plugins.sh"),
            permissions = "0o755",
          },
          {
            path        = "/var/lib/provision/41-copy-plugins.sh",
            content     = file("${path.module}/provision/41-copy-plugins.sh"),
            permissions = "0o755",
          },
          {
            path        = "/var/lib/provision/91-distribute-keys.sh",
            content     = file("${path.module}/provision/91-distribute-keys.sh"),
            permissions = "0o755",
          },
          {
            path = "/etc/sysctl.d/vpn.conf",
            content = <<EOF
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF
          },
        ],
        runcmd = [
           "sudo -u ${var.default_user} mkdir -p ${local.keydir}",
           #"sudo -u ${var.default_user} /var/lib/provision/20-build-openssl.sh",
           "/var/lib/provision/28-setup-test-dependencies.sh",
           "sudo -u ${var.default_user} /var/lib/provision/35-generate-dh-params.sh",
           "sudo -u ${var.default_user} /var/lib/provision/36-generate-secret-keys.sh",
           "sudo -u ${var.default_user} /var/lib/provision/40-build-sample-plugins.sh",
           "sudo -u ${var.default_user} /var/lib/provision/41-copy-plugins.sh",
           "sudo -u ${var.default_user} /var/lib/provision/91-distribute-keys.sh",
        ],
      })
    }
  }

  # Anchor VM
  dynamic "part" {
    for_each = var.tserver_anchor == true ? [1] : []

    content {
      content_type = "text/cloud-config"
      merge_type   = "list(append,recurse_list)+dict(no_replace,recurse_list)+str()"
      content = jsonencode({
        write_files = [
          {
            path        = "/var/lib/provision/27-generate-openvpn-configs.sh",
            content     = file("${path.module}/provision/27-generate-openvpn-configs.sh"),
            permissions = "0o755",
          },
        ],
        runcmd = [
           "sudo -u ${var.default_user} mkdir -p ${local.keydir}",
           "sudo -u ${var.default_user} /var/lib/provision/27-generate-openvpn-configs.sh",
        ],
      })
    }
  }

  # Client VM
  dynamic "part" {
    for_each = var.tserver_client == true ? [1] : []

    content {
      content_type = "text/cloud-config"
      merge_type   = "list(append,recurse_list)+dict(no_replace,recurse_list)+str()"
      content = jsonencode({
        write_files = [
          {
            path        = "/var/lib/provision/podman/prepare-openvpn-build.sh",
            content     = file("${path.module}/provision/podman/prepare-openvpn-build.sh"),
            permissions = "0o755",
          },
          {
            path        = "/var/lib/provision/podman/create-openvpn-executable.sh",
            content     = file("${path.module}/provision/podman/create-openvpn-executable.sh"),
            permissions = "0o755",
          },
          {
            path        = "/var/lib/provision/podman/Containerfile.ubuntu-14.04",
            content     = file("${path.module}/provision/podman/Containerfile.ubuntu-14.04"),
            permissions = "0o755",
          },
          {
            path        = "/var/lib/provision/podman/Containerfile.ubuntu-20.04",
            content     = file("${path.module}/provision/podman/Containerfile.ubuntu-20.04"),
            permissions = "0o755",
          },
          {
            path        = "/var/lib/provision/podman/Containerfile.ubuntu-24.04",
            content     = file("${path.module}/provision/podman/Containerfile.ubuntu-24.04"),
            permissions = "0o755",
          },
          {
            path        = "/var/lib/provision/55-prepare_t_client.sh",
            content     = file("${path.module}/provision/55-prepare_t_client.sh"),
            permissions = "0o755",
          },
          {
            path        = "/var/lib/provision/92-setup-old-openvpn-versions.sh",
            content     = file("${path.module}/provision/92-setup-old-openvpn-versions.sh"),
            permissions = "0o755",
          },
        ]
        runcmd = [
           "sudo -u ${var.default_user} /var/lib/provision/55-prepare_t_client.sh",
           "sudo -u ${var.default_user} /var/lib/provision/92-setup-old-openvpn-versions.sh",
           # Without this selinux blocks device access from containers
           "setsebool -P  container_use_devices=true",
        ],
      })
    }
  }

  # Common part
  part {
    content_type = "text/cloud-config"
    merge_type   = "list(append,recurse_list)+dict(no_replace,recurse_list)+str()"
    content = jsonencode({
      write_files = [
        {
          path        = "/var/lib/provision/90-misc.sh",
          encoding    = "b64"
          content     = base64encode(templatefile("${path.module}/provision/90-misc.sh", { git_name = var.git_name, git_email = var.git_email })),
          permissions = "0o755",
        },
        {
          path        = "/var/lib/provision/99-restart.sh",
          encoding    = "b64"
          content     = base64encode(file("${path.module}/provision/99-restart.sh")),
          permissions = "0o755",
        },
      ],
      runcmd = [
         # Fix permissions that write_files cloud-init module broke
         "chown -R ${var.default_user}:${var.default_user} ${var.data_dir}",
         "sudo -u ${var.default_user} /var/lib/provision/90-misc.sh",
         "/var/lib/provision/99-restart.sh",
      ]
    })
  }
}
