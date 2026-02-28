terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
}

module "test" {
  source = "../../../"

  cis_2_2_logging_sink_project_id = var.cis_2_2_logging_sink_project_id
  description                     = "mock"
  billing_account                 = "000000-000000-000000"
  folder_id                       = "0000000000000"

  labels = {
    "mock-key" = "mock-value"
  }

  prefix = "mock"

  services = [
    "mock.googleapis.com"
  ]
}
