# Moved Blocks
# https://opentofu.org/docs/language/moved

moved {
  from = google_project_service_identity.logging[0]
  to   = google_project_service_identity.logging
}
