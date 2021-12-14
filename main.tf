locals {
  labels = {
    "app.kubernetes.io/name"       = "mysql"
    "app.kubernetes.io/instance"   = var.name
    "app.kubernetes.io/component"  = "mysql"
    "app.kubernetes.io/part-of"    = "mysql"
    "app.kubernetes.io/managed-by" = "terraform"
  }
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = var.name
  }
}

resource "kubernetes_service" "main" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.main.metadata.0.name
    labels    = local.labels
  }

  spec {
    selector   = local.labels
    cluster_ip = "None"

    port {
      port = 3306
    }
  }
}

resource "azurerm_resource_group" "main" {
  name     = format("%s-rg", var.name)
  location = var.region
}

resource "random_id" "disk" {
  byte_length = 4

  keepers = {
    name = var.name
  }
}

resource "azurerm_managed_disk" "main" {
  name                 = format("%s-%s", var.name, random_id.disk.hex)
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = tostring(var.size)
}

resource "kubernetes_persistent_volume" "main" {
  metadata {
    name = format("%s-pv", var.name)
  }

  spec {
    storage_class_name               = ""
    persistent_volume_reclaim_policy = "Retain"
    access_modes                     = ["ReadWriteOnce"]

    capacity = {
      storage = format("%sGi", var.size)
    }

    persistent_volume_source {
      azure_disk {
        kind          = "Managed"
        caching_mode  = "None"
        data_disk_uri = azurerm_managed_disk.main.id
        disk_name     = azurerm_managed_disk.main.name
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "main" {
  metadata {
    name      = format("%s-pvc", var.name)
    namespace = kubernetes_namespace.main.metadata.0.name

    annotations = {
      "volume.beta.kubernetes.io/storage-class" = ""
    }
  }

  spec {
    volume_name        = kubernetes_persistent_volume.main.metadata.0.name
    storage_class_name = ""
    access_modes       = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = format("%sGi", var.size)
      }
    }
  }
}

resource "kubernetes_deployment" "main" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.main.metadata.0.name
    labels    = local.labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.labels
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        container {
          name              = var.name
          image             = "mysql:5.7.36"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "mysql"
            container_port = 3306
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.env.metadata.0.name
            }
          }

          volume_mount {
            name       = "mysql"
            mount_path = "/var/lib/mysql"
            sub_path   = "mysql"
            read_only  = false
          }
        }

        volume {
          name = "mysql"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.main.metadata.0.name
          }
        }
      }
    }
  }
}

resource "random_password" "root" {
  length  = 32
  special = true
}

resource "kubernetes_secret" "env" {
  metadata {
    name      = format("%s-env", var.name)
    namespace = kubernetes_namespace.main.metadata.0.name
    labels    = local.labels
  }

  data = {
    MYSQL_ROOT_PASSWORD = random_password.root.result
  }
}

resource "azurerm_role_assignment" "disk" {
  principal_id         = var.cluster.service_principal.id
  scope                = azurerm_managed_disk.main.id
  role_definition_name = "Contributor"
}
