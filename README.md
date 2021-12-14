# terraform-azurerm-aks-mysql

[Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-gb/services/kubernetes-service/)
MySQL Terraform Module.

## Usage

```hcl
module "mysql" {
  source = "github.com/dbalcomb/terraform-azurerm-aks-mysql"

  name   = "mysql"
  region = "uksouth"
  size   = 4

  cluster = {
    service_principal = {
      id = "00000000-0000-0000-0000-000000000000"
    }
  }
}
```

## Inputs

| Name                           | Type     | Default | Description                                 |
| ------------------------------ | -------- | ------- | ------------------------------------------- |
| `name`                         | `string` |         | The service name                            |
| `region`                       | `string` |         | The target region                           |
| `size`                         | `number` | `64`    | The storage size in GB                      |
| `cluster`                      | `object` |         | The cluster configuration                   |
| `cluster.service_principal`    | `object` |         | The cluster service principal configuration |
| `cluster.service_principal.id` | `string` |         | The cluster service principal ID            |

## Outputs

| Name            | Type     | Description               |
| --------------- | -------- | ------------------------- |
| `name`          | `string` | The service name          |
| `namespace`     | `string` | The service namespace     |
| `region`        | `string` | The target region         |
| `port`          | `number` | The service port          |
| `external_name` | `string` | The external service name |
| `root_password` | `string` | The service root password |
