module "iks" {
  source  = "terraform-cisco-modules/iks/intersight"
  version = "2.4.0"

  ip_pool = {
    use_existing = local.model.ip_pool.iks_ip_pool_use_existing
    name         = local.model.ip_pool.iks_ip_pool_name
  }

  sysconfig = {
    use_existing = local.model.sysconfig.iks_sysconfig_use_existing
    name         = "${var.iks_cluster_name}-sysconfig"
    timezone    = local.model.sysconfig.iks_timezone
    dns_servers = [local.model.sysconfig.iks_dns_ip]
    ntp_servers = [local.model.sysconfig.iks_ntp_ip]
  }

  k8s_network = {
    use_existing = local.model.network.iks_k8s_network_use_existing
    name         = "${var.iks_cluster_name}-network-policy"
    pod_cidr     = local.model.network.iks_pod_cidr
    service_cidr = local.model.network.iks_service_cidr
    cni          = local.model.network.iks_cni
  }

  versionPolicy = {
    useExisting = local.model.version_policy.iks_version_policy_use_existing
    policyName  = local.model.version_policy.iks_version_policy_name
    iksVersionName = local.model.version_policy.iks_version_name
  }

  tr_policy = {
    use_existing = local.model.trusted_registry_policy.iks_tr_policy_use_existing
    create_new   = local.model.trusted_registry_policy.iks_tr_policy_create_new
    name         = "${var.iks_cluster_name}-triggermesh-trusted-registry"
  }

  runtime_policy = {
    use_existing         = false
    create_new           = false
    name                 = "${var.iks_cluster_name}-runtime"
    http_proxy_hostname  = local.model.runtime_policy.iks_proxy_hostname
    http_proxy_port      = 80
    http_proxy_protocol  = "http"
    http_proxy_username  = null
    http_proxy_password  = null
    https_proxy_hostname = local.model.runtime_policy.iks_proxy_hostname
    https_proxy_port     = 8080
    https_proxy_protocol = "https"
    https_proxy_username = null
    https_proxy_password = null
  }

  infraConfigPolicy = {
    use_existing = local.model.vm_infra_policy.iks_infra_config_policy_use_existing
    platformType = local.model.vm_infra_policy.iks_infra_config_policy_platform_type
    policyName   = "${var.iks_cluster_name}-vm-infra-policy"
    vcTargetName   = local.model.vm_infra_policy.iks_infra_config_policy_vc_target_name
    interfaces     = [local.model.vm_infra_policy.iks_infra_config_policy_interfaces]
    vcDatastoreName    = local.model.vm_infra_policy.iks_infra_config_policy_vc_datastore_name
    vcClusterName      = local.model.vm_infra_policy.iks_infra_config_policy_vc_cluster_name
    vcResourcePoolName = ""
    vcPassword         = base64decode(local.model.vm_infra_policy.iks_infra_config_policy_vc_password_b64)
  }

  instance_type = {
    use_existing = local.model.vm_instance_policy.iks_instance_type_use_existing
    name         = "${var.iks_cluster_name}-vm-instance-policy"
    cpu          = local.model.vm_instance_policy.iks_instance_type_cpu
    memory       = local.model.vm_instance_policy.iks_instance_type_memory
    disk_size    = local.model.vm_instance_policy.iks_instance_type_disk_size
  }

  cluster = {
    name                = "${var.iks_cluster_name}"
    action              = var.iks_cluster_action
    wait_for_completion = local.model.cluster_profile.iks_wait_for_completion
    worker_nodes        = local.model.cluster_profile.iks_cluster_worker_nodes
    load_balancers      = local.model.cluster_profile.iks_cluster_load_balancers
    worker_max          = local.model.cluster_profile.iks_cluster_worker_max
    control_nodes       = local.model.cluster_profile.iks_cluster_control_nodes
    ssh_user            = local.model.cluster_profile.iks_cluster_ssh_user
    ssh_public_key      = local.model.cluster_profile.iks_cluster_ssh_public_key
  }

  organization = local.model.organisation.iks_organisation

}

# Retrieve kubeconfig file from IKS cluster.
data "intersight_kubernetes_cluster" "kubeconfig" {
  name = var.iks_cluster_name

  depends_on = [
    module.iks
  ]
}

# Save kubeconfig file to local filesystem.
resource "local_file" "iks_kubeconfig" {
  content  = base64decode(data.intersight_kubernetes_cluster.kubeconfig.results[0].kube_config)
  filename = "./kubeconfig.yaml"
  depends_on = [
    data.intersight_kubernetes_cluster.kubeconfig
  ]
}

# Save kubeconfig file to Boutique deployment subdirectory.
resource "local_file" "iks_boutique_kubeconfig" {
  content  = base64decode(data.intersight_kubernetes_cluster.kubeconfig.results[0].kube_config)
  filename = "../2_Deploy_Boutique/kubeconfig.yaml"
  depends_on = [
    data.intersight_kubernetes_cluster.kubeconfig
  ]
}

# Untaint all nodes. 
resource "null_resource" "remove_iks_taints" {
  triggers = {
    kubeconfig_path = local_file.iks_kubeconfig.filename
  }
  provisioner "local-exec" {
    command = <<EOT
kubectl --kubeconfig ${self.triggers.kubeconfig_path} get nodes -o json | jq '.items[].spec.taints' 
kubectl taint node --all node-role.kubernetes.io/master:NoSchedule- --kubeconfig ${self.triggers.kubeconfig_path}
kubectl taint node --all node.cloudprovider.kubernetes.io/uninitialized- --kubeconfig ${self.triggers.kubeconfig_path}
EOT
  }
  depends_on = [
    local_file.iks_kubeconfig
  ]
}
