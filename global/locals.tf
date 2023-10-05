# Local Values
# https://www.terraform.io/language/values/locals

locals {
  base_project_id = "${var.prefix}-${var.description}-${var.environment}"

  # This map is used to create the GCP-CIS v1.3.0 logging metrics and alarms (2.4 - 2.11). It is recommended that metric filters and alarms be established for
  # the following resources.

  # The list of monitored-resource types in Monitoring is not presently the same as the list of monitored-resource types in Logging:
  # https://cloud.google.com/monitoring/api/resources#tag_global
  # https://cloud.google.com/logging/docs/api/v2/resource-list#resource-types

  cis_logging_metrics = {
    "cis-2-4" = {
      description   = "In order to prevent unnecessary project ownership assignments to users/service-accounts and further misuses of projects and resources, all roles/Owner assignments should be monitored."
      displayName   = "GCP-CIS v1.3.0 - 2.4 Ownership Assignments/Changes"
      filter        = "(protoPayload.serviceName=\"cloudresourcemanager.googleapis.com\") AND (ProjectOwnership OR projectOwnerInvitee) OR (protoPayload.serviceData.policyDelta.bindingDeltas.action=\"REMOVE\" AND protoPayload.serviceData.policyDelta.bindingDeltas.role=\"roles/owner\") OR (protoPayload.serviceData.policyDelta.bindingDeltas.action=\"ADD\" AND protoPayload.serviceData.policyDelta.bindingDeltas.role=\"roles/owner\")"
      resource_type = "global"
      status        = "medium"
    }
    "cis-2-5" = {
      description   = "Services write audit log entries to the Admin Activity and Data Access logs to help answer the questions of, \"who did what, where, and when?\" within GCP projects."
      displayName   = "GCP-CIS v1.3.0 - 2.5 Audit Configuration Changes"
      filter        = "protoPayload.methodName=\"SetIamPolicy\" AND protoPayload.serviceData.policyDelta.auditConfigDeltas:*"
      resource_type = "global"
      status        = "medium"
    }
    "cis-2-6" = {
      description   = "It is recommended that a metric filter and alarm be established for changes to Identity and Access Management (IAM) role creation, deletion and updating activities."
      displayName   = "GCP-CIS v1.3.0 - 2.6 Custom Role Changes"
      filter        = "resource.type=\"iam_role\" AND (protoPayload.methodName = \"google.iam.admin.v1.CreateRole\" OR protoPayload.methodName=\"google.iam.admin.v1.DeleteRole\" OR protoPayload.methodName=\"google.iam.admin.v1.UpdateRole\")"
      resource_type = "global"
      status        = "low"
    }
    "cis-2-7" = {
      description   = "It is recommended that a metric filter and alarm be established for Virtual Private Cloud (VPC) Network Firewall rule changes."
      displayName   = "GCP-CIS v1.3.0 - 2.7 VPC Network Firewall Rule Changes"
      filter        = "resource.type=\"gce_firewall_rule\" AND (protoPayload.methodName:\"compute.firewalls.patch\" OR protoPayload.methodName:\"compute.firewalls.insert\" OR protoPayload.methodName:\"compute.firewalls.delete\")"
      resource_type = "global"
      status        = "low"
    }
    "cis-2-8" = {
      description   = "It is recommended that a metric filter and alarm be established for Virtual Private Cloud (VPC) network route changes."
      displayName   = "GCP-CIS v1.3.0 - 2.8 VPC Network Route Changes"
      filter        = "resource.type=\"gce_route\" AND (protoPayload.methodName:\"compute.routes.delete\" OR protoPayload.methodName:\"compute.routes.insert\")"
      resource_type = "global"
      status        = "low"
    }
    "cis-2-9" = {
      description   = "It is recommended that a metric filter and alarm be established for Virtual Private Cloud (VPC) network changes."
      displayName   = "GCP-CIS v1.3.0 - 2.9 VPC Network Changes"
      filter        = "resource.type=\"gce_network\" AND (protoPayload.methodName:\"compute.networks.insert\" OR protoPayload.methodName:\"compute.networks.patch\" OR protoPayload.methodName:\"compute.networks.delete\" OR protoPayload.methodName:\"compute.networks.removePeering\" OR protoPayload.methodName:\"compute.networks.addPeering\")"
      resource_type = "global"
      status        = "low"
    }
    "cis-2-10" = {
      description   = "It is recommended that a metric filter and alarm be established for Cloud Storage Bucket IAM changes."
      displayName   = "GCP-CIS v1.3.0 - 2.10 Cloud Storage IAM Permission Changes"
      filter        = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.setIamPermissions\""
      resource_type = "gcs_bucket"
      status        = "low"
    }
    "cis-2-11" = {
      description   = "It is recommended that a metric filter and alarm be established for SQL instance configuration changes."
      displayName   = "GCP-CIS v1.3.0 - 2.11 SQL Instance Configuration Changes"
      filter        = "protoPayload.methodName=\"cloudsql.instances.update\""
      resource_type = "cloudsql_database"
      status        = "low"
    }
  }

  # Conditional Expressions
  # https://www.terraform.io/language/expressions/conditionals

  cis_2_2_logging_sink_project_id     = var.cis_2_2_logging_sink_project_id == "" ? google_project.this.project_id : var.cis_2_2_logging_sink_project_id
  cis_2_2_logging_sink_storage_bucket = var.cis_2_2_logging_sink_project_id == "" ? "logging.googleapis.com/${google_logging_project_bucket_config.cis_2_2_logging_sink[0].name}" : "logging.googleapis.com/projects/${var.cis_2_2_logging_sink_project_id}/locations/global/buckets/cis-2-2-logging-sink"

  monitoring_notification_channels = {
    "budget" = {
      description   = "Budget notification channel created by the terraform-google-project child module"
      display_name  = "Budget"
      email_address = var.budget_notification_email
    }

    "security" = {
      description   = "Security notification channel created by the terraform-google-project child module"
      display_name  = "Security"
      email_address = var.security_notification_email
    }
  }
  # Format Function
  # https://www.terraform.io/language/functions/format

  project_id = var.random_project_id ? format(
    "%s-%s-%s-%s",
    var.prefix,
    var.description,
    random_id.this[0].hex,
    var.environment,
  ) : local.base_project_id

  # Concat Function
  # https://www.terraform.io/language/functions/concat

  services = toset(concat(
    var.services,
    [
      "logging.googleapis.com"
    ]
  ))
}
