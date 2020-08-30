provider "kubernetes" {}

resource "kubernetes_service" "mysvc" {
  depends_on = [kubernetes_deployment.mydeployment]
  metadata {
    name = "wp-service"
    labels = {
      app = "wp-frontend"
    }
  }
  spec {
    selector = {
      app = "wp-frontend"
    }
    port {
      node_port   = 30402
      port        = 80
      target_port = 80
    }
    type = "NodePort"
  }
}



resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name = "wp-pvc"
    labels = {
      app = "wp-frontend"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}


resource "kubernetes_deployment" "mydeployment" {
  depends_on = [kubernetes_persistent_volume_claim.pvc, aws_db_instance.mydb]
  metadata {
    name = "mydeployment"
    labels = {
      app = "wp-frontend"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "wp-frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "wp-frontend"
        }
      }
      spec {
        volume {
          name = "wordpress-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.pvc.metadata.0.name
          }
        }
        container {
          image = "wordpress:4.8-apache"
          env {
            name  = "WORDPRESS_DB_HOST"
            value = aws_db_instance.mydb.address
          }
          env {
            name  = "WORDPRESS_DB_USER"
            value = aws_db_instance.mydb.username
          }
          env {
            name  = "WORDPRESS_DB_PASSWORD"
            value = aws_db_instance.mydb.password
          }
          env {
            name  = "WORDPRESS_DB_NAME"
            value = aws_db_instance.mydb.name
          }

          name = "wp-container"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "wordpress-persistent-storage"
            mount_path = "/var/www/html"
          }
        }
      }
    }
  }
}

output "myurl" {
  value = " Connect to the url : 192.168.99.106:${kubernetes_service.mysvc.spec[0].port[0].node_port}"
}


