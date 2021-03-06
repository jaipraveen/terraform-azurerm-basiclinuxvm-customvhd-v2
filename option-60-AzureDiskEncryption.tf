/*
Example:

encryptDisks = {
  KeyVaultResourceId = azurerm_key_vault.test-keyvault.id
  KeyVaultURL        = azurerm_key_vault.test-keyvault.vault_uri
}

*/

variable "encryptDisks" {
  description = "Should the VM disks be encrypted"
  default     = null
}

resource "random_uuid" "SequenceVersion" {}

resource "azurerm_virtual_machine_extension" "AzureDiskEncryption" {

  count                      = var.encryptDisks == null ? 0 : 1
  name                       = "AzureDiskEncryption"
  depends_on                 = [azurerm_virtual_machine_extension.DAAgentForLinux]
  virtual_machine_id         = azurerm_virtual_machine.VM.id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryptionForLinux"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
        {  
          "EncryptionOperation": "EnableEncryption",
          "KeyVaultResourceId": "${var.encryptDisks.KeyVaultResourceId}",
          "KeyVaultURL": "${var.encryptDisks.KeyVaultURL}",
          "KeyEncryptionAlgorithm": "",
          "VolumeType": "All",
          "ResizeOSDisk": false,
          "SequenceVersion": "${random_uuid.SequenceVersion.result}"
        }
  SETTINGS

  tags = var.tags
}
