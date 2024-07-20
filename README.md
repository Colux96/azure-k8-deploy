Il seguente progetto ha lo scopo di eseguire il provisioning di un cluster Kubernetes composto da un manager e due workers e deployare una applicazione composta da almeno tre servizi e che presenti una interfaccia grafica accessibile via browser.

## Prerequisiti

#`Installazione Azure cli
https://learn.microsoft.com/it-it/cli/azure/install-azure-cli-linux?pivots=apt

# Login azure
https://learn.microsoft.com/it-it/cli/azure/authenticate-azure-cli-interactively

# Installazione Terraform
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

# STEP 1 - Provisioning su Azure con Terraform

Si è scelto di utilizzare terraform come tool di provisioning per le VM in quanto verrà utilizzato anche in seguito per il provisioning del cluster Kubernetes.

https://learn.microsoft.com/it-it/azure/virtual-machines/linux/quick-create-terraform?tabs=azure-cli

Una volta scritti i file .tf, comando per avvio terraform che si scaricherà i moduli necessari per lavorare con Azure (hashicorp/azurerm)
		terraform init 
		
# Controlla se la configurazione è valida
		terraform validate

# Pianifica le configurazioni da applicare e le salva su un file

   terraform plan -out=plan.tfplan

# Applica le configurazioni dal file plan
		
		terraform apply plan.tfplan
