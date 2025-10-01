// =============================================================
// Cafe-Foundation - Subscription Level Deployment
//--------------------------------------------------------------
//
// Purpose:
// - Runs at the SUBSCRIPTION level so it can CREATE a new Resource Group.
// - Then calls main.bicep to build everything inside that Resource Group.
//
// What this template will do:
// 1) Create a Resource Group to hold all Azure resources.
// 2) Pass key settings (region, environment, budget, owner) to main.bicep which will:
//    - create a secure Storage Account
//    - set up Log Analytics (log book)
//    - apply governance rules (Azure Policies)
//    - add a safety lock to prevent accidental deletion
//    - configure diagnostic logging
//    - create a monthly cost budget with alerts
//
// How to preview (what-if):
// az deployment sub what-if --location uksouth \
//   --template-file subscription.bicep \
//   --parameters rgName='cafe-foundation-rg' baseName='cafe' environment='dev' owner='you@example.com'
//
// How to deploy:
// az deployment sub create --location uksouth \
//   --template-file subscription.bicep \
//   --parameters rgName='cafe-foundation-rg' baseName='cafe' environment='dev' owner='you@example.com'
// =============================================================

// Deploys at subscription level
targetScope = 'subscription'

// ---------- Parameters --------------

@description('Name of the Resource Group to create')
@minLength(3)
@maxLength(90)
param rgName string

@description('Azure region where the Resource Group and resources will live')
// Tip: az account list-locations -o table
@allowed([ 'uksouth', 'ukwest' ])
param location string = 'uksouth'

@description('Short base name used to build resource names (letters/numbers, no dashes)')
@minLength(3)
@maxLength(12)
param baseName string

@description('Storage SKU for the Storage Account')
@allowed([ 'Standard_LRS' ])
param storageSku string = 'Standard_LRS'

@description('Environment tag for governance and cost tracking')
@allowed([ 'dev', 'test', 'prod' ])
param environment string = 'dev'

@description('Monthly budget (USD) for cost alerts')
@minValue(5)
@maxValue(25)
param monthlyBudget int = 20

@description('Owner tag to identify who is responsible (email or team name)')
@minLength(1)
@maxLength(64)
param owner string = 'mini-lab'

// ------------------------- Create the Resource Group ------------------
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
  tags: {
    environment: environment
    owner: owner
    project: 'cafe-foundation'
  }
}

// ---------------- Call the RG-scoped template (main.bicep) ----------------
// This runs INSIDE the RG we just created and builds the governed baseline.
module baseline 'main.bicep' = {
  name: 'cafe-foundation-baseline'
  scope: rg
  params: {
    baseName: baseName
    environment: environment
    location: location
    storageSku: storageSku
    monthlyBudget: monthlyBudget
    owner: owner
  }
}

// ---------------- OUTPUTS ----------------
output resourceGroupId string = rg.id
output summary string = baseline.outputs.summary
