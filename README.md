## Panoramica

Il seguente progetto ha lo scopo di eseguire il provisioning di un cluster Kubernetes composto da un manager e due workers e deployare una applicazione composta da almeno tre servizi e che presenti una interfaccia grafica accessibile via browser.

## Prerequisiti

- Una macchina dalla quale effettuare il provisioning delle macchine e il setup dell'ambiente, io utilizzerò una macchina virtuale Ubuntu 24.04 in locale su Virtualbox.
- Un account gratuito su [Azure](https://azure.microsoft.com/free/)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [Terraform](https://www.terraform.io/downloads.html)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Helm](https://helm.sh/docs/intro/install/)
- [Git](https://git-scm.com/download/linux)
- Un repository su [GitHub](https://github.com/) per il versionamento del codice

## Passaggi

### 1. Provisioning delle risorse su Azure con Terraform

Tra i vari tool disponibili, si è scelto di utilizzare Terraform per il provisioning delle risorse su Azure per i seguenti motivi:

- Codifica Dichiarativa: Terraform utilizza un linguaggio di configurazione dichiarativo, HCL (HashiCorp Configuration Language), che consente di definire lo stato desiderato dell'infrastruttura.
- Terraform è uno degli strumenti più popolari per il provisioning e la gestione dell'infrastruttura come codice (IaC).
- Stato Gestito: Terraform tiene traccia dello stato dell'infrastruttura attraverso un file di stato (.tfstate), che consente di sapere esattamente quali risorse sono state create, aggiornate o distrutte. Questo file aiuta a prevenire conflitti e mantiene la coerenza tra l'infrastruttura reale e quella definita nel codice.
- Multi-provider: Terraform supporta un'ampia varietà di provider, non solo Azure, ma anche AWS, Google Cloud, VirtualBox e altri. Questo lo rende una scelta eccellente per ambienti multi-cloud o per gestire più tipi di infrastruttura con un unico strumento.
- Modularità e Riutilizzo: Terraform supporta i moduli, che consentono di creare blocchi riutilizzabili di configurazioni. Questo facilita la gestione di infrastrutture complesse e la standardizzazione di configurazioni attraverso progetti.
 -Pianificazione e Applicazione: La funzione terraform plan consente di vedere le modifiche che saranno apportate prima di applicarle. Questo aiuta a evitare cambiamenti imprevisti e a garantire che le modifiche siano come previsto.
- Gestione delle Dipendenze: Terraform gestisce automaticamente le dipendenze tra risorse, assicurandosi che le risorse siano create, aggiornate o distrutte nell'ordine corretto.
- Comunità e Supporto: Terraform ha una grande comunità e una vasta documentazione, che può essere utile per risolvere problemi e apprendere le best practice.

### Login da comand line sul portale Azure

Aprire un terminale e utilizzare il comando az login. Questo aprirà una finestra del browser in cui si dovra inserire le proprie credenziali Azure. Se il login ha successo, il terminale mostrerà le informazioni dell'account e le sottoscrizioni disponibili.

 ```sh
   az login
  ```

Selezionare la sottoscrizione da utilizzare tra quelle elencate e premere invio.
Ora si è pronti per il provisioning di risorse su Azure.

### Creazione delle Risorse

- Crea una directory per il progetto:
    ```sh
    mkdir azure-k8s-project
    cd azure-k8s-project
    ```
- Clona il progetto:
    ```sh
    git clone https://github.com/Colux96/azure-k8-deploy.git
    ```
- Edita il file `terraform/template.tfvars` inserendo le credenziali delle virtual machine che verranno create e rinomina il file in `terraform.tfvars`:
    ```
    vm_admin_user = "PLACEHOLDER_UTENTE"
    vm_admin_password = "PLACEHOLDER_PASSWORD"
    ```

- Esegui i seguenti comandi Terraform per creare le risorse:
    ```sh
    # Inizializza il backend terraform e installa i moduli necessari (i provider azure e k8s)
    terraform init
    
    # Pianifica le risorse che andranno create e salva lo stato nel file plan.tfplan
    terraform plan -out=plan.tfplan
    
    # Applica la configurazione e crea le risorse necessarie su Azure
    terraform apply -target=module.network -target=module.vm
    ```

### 2. Configurazione delle VM con Ansible
Procedere con Ansible alla configurazione del cluster sulle macchine virtuali appena create.

- Edita l'inventario Ansible `ansible/hosts.template` con le informazioni delle macchine virtuali, e rinominare il file in `hosts`:
    ```ini
    [master_nodes]
    master ansible_host=PLACEHOLDER_IP ansible_user=PLACEHOLDER_USER ansible_ssh_pass=PLACEHOLDER_PASSWORD
    
    [worker_nodes]
    worker1 ansible_host=PLACEHOLDER_IP ansible_user=PLACEHOLDER_USER ansible_ssh_pass=PLACEHOLDER_PASSWORD
    worker2 ansible_host=PLACEHOLDER_IP ansible_user=PLACEHOLDER_USER ansible_ssh_pass=PLACEHOLDER_PASSWORD
    
    [all:vars]
    ansible_python_interpreter=/usr/bin/python3

    ```

- Esegui il playbook Ansible e fornire la password per i comandi sudo quando richiesto:
    ```sh
    ansible-playbook site.yaml -K
    ```

### 3. Creazione del namespace e del job di benchmark
Il provider Terraform tramite il modulo creato "benchmark" si occuperà di creare un namespace denominato “kiratech-test”
e creare un job sul cluster Kubernetes che eseguirà un benchmark di security con l'utilizzo del tool [kube-bench](https://github.com/aquasecurity/kube-bench).

Si è scelto di utilizzare kube-bench per il benchmark di sicurezza per i seguenti motivi:

- Standard di Riferimento: kube-bench utilizza il benchmark CIS Kubernetes come base per i suoi controlli. Il Center for Internet Security (CIS) è riconosciuto per i suoi standard di sicurezza approfonditi e consolidati, e le loro raccomandazioni sono ampiamente accettate nella comunità di sicurezza informatica.
- Automazione e Facilità d'Uso: kube-bench è progettato per essere eseguito automaticamente sui cluster Kubernetes tramite l'uso dei job
- Aggiornamenti Regolari: Lo strumento è mantenuto attivamente e aggiornato con le ultime best practices e raccomandazioni di sicurezza, garantendo che il benchmark rimanga rilevante e efficace.

Eseguire il seguente comando per Applicare la configurazione del namespace e del job di benchmark sul cluster Kubernetes.
- Comando per applicare la configurazione
    ```sh
    terraform apply -target=module.benchmark
    ```
- Per verificare il risultato del benchmark, controllare i log del pod creato dal job:
    ```sh
    kubectl get pod
    kubectl log <NOME_POD> 
    ```

### 4. Deployment dell'Applicazione con Helm

- **Edita il file `helm/values_template.yaml` configurando le porte desiderate e le credenziali per il servizio di mysql. Fatto ciò rinomina il file in i `values.yaml`**:
    ```sh
      user: "PLACEHOLDER_USER"
      password: "PLACEHOLDER_PASSWORD"
    ```
### 5. Configurazione della Continuous Integration

#### Motivazione
La Continuous Integration è implementata tramite Github actions per garantire che il codice venga verificato automaticamente ad ogni commit.

- **Configura GitHub Actions nel repository**:
    ```yaml
    name: CI

    on: [push]

    jobs:
      terraform:
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v2
        - name: Set up Terraform
          uses: hashicorp/setup-terraform@v1
          with:
            terraform_version: 1.0.11
        - name: Terraform Init
          run: terraform init
        - name: Terraform Plan
          run: terraform plan

      ansible:
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v2
        - name: Set up Ansible
          run: sudo apt-get install ansible
        - name: Run Ansible Playbook
          run: ansible-playbook -i inventory setup.yaml

      helm:
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v2
        - name: Set up Helm
          run: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        - name: Deploy Helm Chart
          run: helm install myapp ./myapp -n kiratech-test
    ```

### Versionamento del Codice
Versionare il codice su Github in modo da agevolare il team work, tornare facilmente a versioni precedenti o abbracciare filosofie GitOps.

-  **Inizializza un repository Git**:
    ```sh
    git init
    git remote add origin https://github.com/username/repository.git
    git add .
    git commit -m "Initial commit"
    git push -u origin master
    ```

- Effettuare commit di modifiche
  ```sh
    git add .
    git commit -m "Descrizione breve ma efficace delle modifiche effettuate"
    ```

- Aggiornare il repository remoto
  ```sh
    git push
    ```



## Note

- Sarebbe opportuno l'integrazione di una componente CD per il deploy automatico dell'applicazione a ogni commit
- Per migliorare il progetto sarebbe opportuno l'implementazione di un inventory Ansible dinamico che preleva automaticamente le informazioni necessarie da Terraform
- Monitorare costantemente l'utilizzo delle risorse per non superare i limiti dell'account gratuito di Azure.