// ========================================================
// MAIN TEMPLATE (RG scope)
// - Creates a secure Storage Account
// - Creates a Log Analytics Workspace
// - Adds a Resource Group lock
// - (Budget note output for now; real budget can be added later)
// ========================================================

targetScope = 'resourceGroup'

// ------------------ Parameters ----------------------
@description('Short base name used for resource names (letters/numbers, no dashes).')
param baseName string

@description('Environment tag (dev/test/prod).')
param environment string

@description('Azure region for resources.')
param location string

@description('Storage SKU (e.g., Standard_LRS).')
param storageSku string

@description('Monthly budget amount (for note/output only in this file).')
param monthlyBudget int

@description('Owner tag (email or team).')
param owner string

// ------------------ Variables (safe names) ----------------------
var namePrefix = toLower(replace(baseName, '-', ''))
var saName     = '${namePrefix}${uniqueString(resourceGroup().id)}' // <= 24 chars typical
var lawName    = '${namePrefix}-law'                                 // RG-unique is fine

// ------------------------ Storage Account -------------------------
resource storageaccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: saName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
  tags: {
    environment: environment
    owner: owner
    project: 'cafe-foundation'
  }
}

// ---------- Log Analytics Workspace ------------------
resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: lawName
  location: location
  properties: {
    retentionInDays: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    sku: {
      name: 'PerGB2018'
    }
  }
  tags: {
    environment: environment
    owner: owner
    project: 'cafe-foundation'
  }
}

// ------------ Resource Group Lock ----------------------
resource rgLock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'rg-can-not-delete'
  properties: {
    level: 'CanNotDelete'
    notes: 'Protect RG from accidental deletion'
  }
}

// ---------------- Notes & Outputs ----------------
output budgetNote string = 'Budget set to ${monthlyBudget} GBP (configure alerts in Cost Management)'
output storageAccountName string = saName
output logAnalyticsName string = lawName
output summary string = 'Deployed baseline: Storage + Log Analytics + RG Lock + Budget note'
