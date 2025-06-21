# Azure Storage Deployment with ARM & BICEP: Step-by-Step Guide

## Table of Contents

- [Azure Storage Deployment with ARM \& BICEP: Step-by-Step Guide](#azure-storage-deployment-with-arm--bicep-step-by-step-guide)
  - [Table of Contents](#table-of-contents)
  - [Learning Goals](#learning-goals)
  - [Introduction: What Are We Building?](#introduction-what-are-we-building)
    - [What is an Azure Storage Account?](#what-is-an-azure-storage-account)
    - [What are ARM and Bicep?](#what-are-arm-and-bicep)
  - [Prerequisites](#prerequisites)
    - [Test Azure CLI Login and Subscription](#test-azure-cli-login-and-subscription)
  - [Step 1: Set Up Your Environment](#step-1-set-up-your-environment)
  - [Step 2: ARM Deployment](#step-2-arm-deployment)
    - [2.1 Review the ARM Template](#21-review-the-arm-template)
    - [2.2 Create a Parameter File](#22-create-a-parameter-file)
    - [2.3 Deploy the ARM Template with Parameters](#23-deploy-the-arm-template-with-parameters)
    - [2.4 Check Your ARM Deployment](#24-check-your-arm-deployment)
  - [Step 3: Bicep Deployment](#step-3-bicep-deployment)
    - [3.1 Review the Bicep Template](#31-review-the-bicep-template)
    - [3.2 Customize the Bicep Template](#32-customize-the-bicep-template)
    - [3.3 Deploy the Bicep Template](#33-deploy-the-bicep-template)
    - [3.4 Check Your Bicep Deployment](#34-check-your-bicep-deployment)
  - [Step 7: Create New Templates for Other Resources](#step-7-create-new-templates-for-other-resources)
  - [Step 8: Automate with GitHub Actions (Optional)](#step-8-automate-with-github-actions-optional)
  - [Best Practice: Managing Templates for Dev and Prod](#best-practice-managing-templates-for-dev-and-prod)
    - [How to Do It](#how-to-do-it)
  - [Glossary](#glossary)
  - [Summary \& Next Steps](#summary--next-steps)

## Learning Goals

- Understand what an Azure Storage Account is and its use cases
- Learn what ARM and Bicep templates are, and why both are important
- Learn how to deploy resources using ARM templates and Bicep
- Practice using the Azure CLI
- Automate deployments with GitHub Actions
- Document and verify your work

---

## Introduction: What Are We Building?

If you’re new to Azure or cloud infrastructure, let’s start with the basics:

### What is an Azure Storage Account?

An Azure Storage Account is a secure, scalable, and highly available cloud storage solution provided by Microsoft Azure. It allows you to store files, images, videos, logs, backups, and more. You can use it for hosting static websites, supporting big data analytics, or simply storing application data.

### What are ARM and Bicep?

- **ARM (Azure Resource Manager) Template:** A JSON file that describes the resources you want to deploy in Azure. It’s a way to automate and standardize your cloud infrastructure.
- **Bicep:** A newer, more user-friendly language for defining Azure resources. Bicep compiles down to ARM JSON, but is easier to read and write.

> **Note:** Learning ARM first gives you a strong foundation, as Bicep ultimately uses ARM under the hood. This course will guide you through ARM deployment before introducing Bicep, so you understand both the fundamentals and the modern approach.

**Why use both?**

- ARM is the traditional, widely supported format.
- Bicep is the modern, recommended approach for new projects.
- Learning both helps you understand Azure infrastructure as code, and gives you flexibility for any project.

---

## Prerequisites

- **Azure Subscription**: You need an active Azure subscription to deploy resources and to log in with the Azure CLI.

  1. First, check if you already have a subscription by visiting the [Azure Subscriptions page](https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBlade). This will show all subscriptions associated with your account.
![alt text](docs/screenshots/az-subscription-check.png)

  2. If you don't have one, you can create a free account at [https://azure.com/free](https://azure.com/free).
  ![alt text](docs/screenshots/free-account-blur.png)

  3. If you already have an Azure account but no subscription, you can add a new subscription here: [Add Subscription](https://portal.azure.com/#view/Microsoft_Azure_Billing/CatalogBlade/appId/AddSubscriptionButton).
  ![alt text](docs/screenshots/new-subscription.png)

- **Azure CLI**: You need the Azure CLI installed. You can install it by following the official instructions:

  <https://learn.microsoft.com/en-us/cli/azure/install-azure-cli>

  Or on Linux (WSL2 Ubuntu, for me), run:

  ```bash
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  ```

### Test Azure CLI Login and Subscription

After installing the Azure CLI, log in and verify your subscription:

This command opens a web browser for you to log in to your Azure account.

```bash
az login
```

![alt text](docs/screenshots/az-login-terminal-blur.png)

You should see your default browser open with a login page.

![alt text](docs/screenshots/az-login-browser-open.png)

Multifactor authentication (MFA) may be required, depending on your organization's security policies. Follow the prompts to complete the login process.

![alt text](docs/screenshots/az-login-mfa-blur.png)

After logging in, you will see a confirmation message in the browser and the terminal.

![alt text](docs/screenshots/az-login-browser-confirmation.png)

After logging in, you can check your subscriptions with:

```bash
az account list --output table
```

![alt text](docs/screenshots/az-account-list.png)

If you have multiple subscriptions, set the correct one:

```bash
az account set --subscription "<subscription-name-or-id>"
```

---

## Step 1: Set Up Your Environment

1. Ensure you have completed the prerequisites above.
2. Open a terminal and navigate to this project directory.

---

## Step 2: ARM Deployment

### 2.1 Review the ARM Template

- **File:** `templates/storage-arm.json`

The ARM template is a JSON file that describes the Azure resources you want to deploy. Here’s what each part means:

- `$schema`: Specifies the location of the JSON schema file that describes the version of the template language.
- `contentVersion`: The version of your template (you can use `1.0.0.0`).
- `parameters`: Defines values you can pass in at deployment time (e.g., storage account name).
- `resources`: An array of resources to deploy. In this case, it defines a storage account with:
  - `type`: The Azure resource type (here, a storage account).
  - `apiVersion`: The API version to use for the resource.
  - `name`: The name of the storage account, set using a parameter.
  - `location`: The Azure region for deployment.
  - `sku`: The SKU (pricing tier) for the storage account.
  - `kind`: The type of storage account (e.g., `StorageV2`).
  - `properties`: Additional settings (empty here, but can be used for advanced configuration).

### 2.2 Create a Parameter File

> **Why use a parameter file?**  
> Parameter files let you keep your template code reusable and clean. Instead of hardcoding values (like the storage account name) in your main template, you provide them separately for each environment (dev, prod, etc.). This makes it easy to deploy the same template with different settings.

- Make a copy of the example parameter file below and save it as `dev.parameters.json` (or `prod.parameters.json` for production) in the `templates` folder, alongside your main template file.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "parameters": {
    "storageAccountName": {
      "value": "devstor<your-unique>"
    }
  }
}
```

> **Note:** The value you set here (e.g., `devstor<your-unique>`) must match the parameter used in your ARM template. Make sure the parameter name and value are consistent between your parameter file and the template for a successful deployment.

> **Tip:** Follow Microsoft naming best practices: use only lowercase letters and numbers, start with a prefix like `dev` or `prod`, keep it 3–24 characters, and make it globally unique (e.g., `devstor12345`).

> _Take a screenshot of your parameter file for your documentation or to share your progress._

### 2.3 Deploy the ARM Template with Parameters

1. Create a resource group (if you don't have one):

   ```bash
   az group create --name devops-rg --location westeurope
   ```

2. Deploy the storage account using the ARM template and your parameter file:

   ```bash
   az deployment group create --resource-group devops-rg --template-file templates/storage-arm.json --parameters @dev.parameters.json
   ```

### 2.4 Check Your ARM Deployment

After running the deployment command, immediately verify the result:

1. In the [Azure Portal](https://portal.azure.com/), navigate to your resource group (e.g., `devops-rg`).
2. Confirm that your storage account (e.g., `devstor<your-unique>`) appears in the list of resources.
3. Optionally, take a screenshot of the successful deployment for your own documentation or to share your results.

---

## Step 3: Bicep Deployment

### 3.1 Review the Bicep Template

- **File:** `templates/storage-bicep.bicep`

The Bicep template is a more concise, user-friendly file for defining Azure resources. It describes the same storage account as the ARM template, but with simpler syntax.

### 3.2 Customize the Bicep Template

> **Note:** Azure storage account names must be globally unique. Before deploying, edit the Bicep template and replace `devstor${UNIQUE}` with your own unique name (e.g., `devstorjohn01`).
>
> Example:
>
> ```bicep
> name: 'devstorjohn01'
> ```
>
> Use the same unique name in all deployment commands and when verifying in the Azure Portal.

### 3.3 Deploy the Bicep Template

1. Deploy the storage account using the Bicep template:

   ```bash
   az deployment group create --resource-group devops-rg --template-file templates/storage-bicep.bicep
   ```

### 3.4 Check Your Bicep Deployment

After running the deployment command, immediately verify the result:

1. In the [Azure Portal](https://portal.azure.com/), navigate to your resource group (e.g., `devops-rg`).
2. Confirm that your storage account (e.g., `devstor<your-unique>`) appears in the list of resources.
3. Optionally, take a screenshot of the successful deployment for your own documentation or to share your results.

---

## Step 7: Create New Templates for Other Resources

If you want to create a new resource (e.g., another storage account or a different Azure service), follow these steps:

1. **Copy the existing template:**
   - For ARM: Duplicate `templates/storage-arm.json` and give it a new descriptive name (e.g., `storage-logs-arm.json`).
   - For Bicep: Duplicate `templates/storage-bicep.bicep` and give it a new descriptive name (e.g., `storage-logs-bicep.bicep`).
2. **Update the resource name:**
   - Change the `name` property in the template to a new, unique value (e.g., `devstorlogs${UNIQUE}`).
3. **Update deployment commands:**
   - Use the new template filename in your Azure CLI deployment commands.
4. **Document your new resource:**
   - Add a section in the README or your own notes describing the purpose of the new resource and any special configuration.

This approach helps you reuse and extend your infrastructure as your projects grow.

---

## Step 8: Automate with GitHub Actions (Optional)

This project includes a sample GitHub Actions workflow in `.github/workflows/deploy.yml` to automate deployment on push.

---

## Best Practice: Managing Templates for Dev and Prod

Instead of duplicating your entire template for each environment, use parameters and environment-specific parameter files. This approach keeps your infrastructure code DRY (Don't Repeat Yourself) and easy to maintain.

### How to Do It

1. **Single Template:**
   - Keep one main template file (e.g., `storage-arm.json` or `main.bicep`).

2. **Parameter Files:**
   - Create separate parameter files for each environment, such as `dev.parameters.json` and `prod.parameters.json`.
   - Only environment-specific values (like resource names, SKUs, or locations) go in these files.

3. **Parameterize Resource Names:**
   - In your template, use a parameter for the storage account name.

   **Example (ARM):**
   ```json
   "parameters": {
     "storageAccountName": {
       "type": "string"
     }
   },
   "resources": [
     {
       "type": "Microsoft.Storage/storageAccounts",
       "apiVersion": "2021-02-01",
       "name": "[parameters('storageAccountName')]",
       // ...
     }
   ]
   ```

   **Example parameter file (`dev.parameters.json`):**
   ```json
   {
     "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
     "parameters": {
       "storageAccountName": {
         "value": "devstor123"
       }
     }
   }
   ```

4. **Deploy with Parameter File:**
   ```bash
   az deployment group create --resource-group devops-rg --template-file storage-arm.json --parameters @dev.parameters.json
   ```

This way, you can use the same template for all environments and just swap out the parameter file.

---

## Glossary

- **Resource**: Any manageable item available through Azure, such as a virtual machine, storage account, or database.
- **Resource Group**: A container that holds related Azure resources. It helps organize and manage resources as a unit.
- **ARM Template**: A JSON file that defines the infrastructure and configuration for your Azure solution.
- **Bicep**: A domain-specific language (DSL) for deploying Azure resources declaratively, offering a simpler syntax than ARM JSON.
- **Azure CLI**: A command-line tool to manage Azure resources from your terminal or scripts.
- **Subscription**: An Azure subscription is an agreement with Microsoft to use Azure services, and it provides access to resources and billing.
- **Deployment**: The process of creating or updating resources in Azure using templates or scripts.

---

## Summary & Next Steps

- You have learned how to deploy an Azure Storage Account using both ARM and Bicep.
- You practiced using the Azure CLI and optionally automated the process.
- For more, explore Azure documentation or try adding parameters to the templates for customization.