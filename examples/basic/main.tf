module "mysql" {
  source = "../.."

  name   = "mysql"
  region = "uksouth"
  size   = 4

  cluster = {
    service_principal = {
      id = "00000000-0000-0000-0000-000000000000"
    }
  }
}
