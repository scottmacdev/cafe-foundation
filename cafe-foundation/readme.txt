# ☕ Cafe Foundation - Azure Bicep Lab Project  

## 📌 Overview  
This project is a **mini lab** to practice using **Azure Bicep** (Infrastructure as Code).  
It creates a **governed, cost-aware Azure foundation** for a small business (a café).  

The idea is to automate the setup of Azure resources without using the portal —  
everything is deployed from code, making it **repeatable and consistent**.  

---

## 📂 Project Structure  

- **`subscription.bicep`**  
  Runs at the **subscription level**.  
  - Creates a Resource Group  
  - Calls `main.bicep`  

- **`main.bicep`**  
  Runs at the **resource group level**. Builds the baseline resources:  
  - Storage Account (secure, HTTPS only, TLS 1.2)  
  - Log Analytics Workspace  
  - Resource Group Lock (`CanNotDelete`)  
  - Tags for governance  
  - Budget alerts (~£20/month for lab)  

---

## 📖 How to Use  

1. **Login to Azure CLI**  
   ```bash
   az login

cd cafe-foundation
az deployment sub what-if --location uksouth \
  --template-file subscription.bicep \
  --parameters rgName='cafe-foundation-rg' baseName='cafe' environment='dev' owner='mini-lab'

az deployment sub create --location uksouth \
  --template-file subscription.bicep \
  --parameters rgName='cafe-foundation-rg' baseName='cafe' environment='dev' storageSku='Standard_LRS' monthlyBudget=20 owner='mini-lab'

