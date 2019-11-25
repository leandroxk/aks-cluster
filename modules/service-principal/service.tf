variable "name" {}
variable "years_to_pw_expire" { default = "17520h" }

data "azurerm_subscription" "main" {}

# Create Azure AD App
resource "azuread_application" "main" {
  name                       = var.name
  available_to_other_tenants = false
}

# Create Service Principal associated with the Azure AD App
resource "azuread_service_principal" "main" {
  application_id = azuread_application.main.application_id
}

# Generate random string to be used for Service Principal password
resource "random_string" "password" {
  length  = 32
  special = true
}

# Create Service Principal password
resource "azuread_service_principal_password" "main" {
  service_principal_id = azuread_service_principal.main.id
  value                = random_string.password.result
  end_date_relative    = format("%dh", var.years_to_pw_expire * 8760)
}

# Create role assignment for service principal
resource "azurerm_role_assignment" "main" {
  scope                = data.azurerm_subscription.main.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.main.id
}

output "display_name" {
  value = azuread_service_principal.main.display_name
}

output "client_id" {
  value = azuread_application.main.application_id
}

output "client_secret" {
  value     = azuread_service_principal_password.main.value
  sensitive = true
}

output "object_id" {
  value = azuread_service_principal.main.id
}