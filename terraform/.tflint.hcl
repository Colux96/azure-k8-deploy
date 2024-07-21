# Configura il plugin Azure
plugin "azurerm" {
  enabled=true
}

# Abilita o disabilita regole specifiche
rule "azurerm_storage_account_requires_tls" {
  enabled = true  # Abilita la regola per verificare che gli account di storage richiedano TLS
}

rule "azurerm_virtual_network" {
  enabled = true  # Abilita la regola per verificare la configurazione delle reti virtuali
}

rule "azurerm_resource_group" {
  enabled = true  # Abilita la regola per verificare la configurazione dei gruppi di risorse
}

# Configura il livello di log
log {
  level = "info"  # Può essere "debug", "info", "warn", o "error"
}