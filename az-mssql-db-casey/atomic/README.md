# Terraform Module: Azure MSSQL Database (`azurerm_mssql_database`)

This module provides a **Terraform implementation** for deploying an **Azure MSSQL Database** (`azurerm_mssql_database`) with **comprehensive configuration options**. It supports **Standard, Premium, Hyperscale, Serverless, and Geo-Redundant** deployments with **best-practice security, high availability, and compliance**.

**By Casey Wood**  
microsoftexpert@gmail.com

---

## 🚀 Features


- **Flexible Configurations**:  
  - Supports **all SQL Server and database SKUs** (Standard, Premium, Hyperscale, Serverless, DataWarehouse, etc.).
  - **Multi-database support** within a single MSSQL Server.
  - **Read-replica and geo-redundancy configurations** available.
- **Security-First Approach**:
  - **Transparent Data Encryption (TDE)** enabled by default.
  - Supports **Customer-Managed Keys (CMK)** via Azure Key Vault.
  - **Threat Detection & Auditing Policies** configurable.
- **Data Protection & Backup Policies**:
  - **Geo-redundant backups** for high availability.
  - **Short & long-term retention policies** for compliance.
- **High Availability & Disaster Recovery**:
  - Supports **failover groups** with automatic failover.
  - **Read replicas for performance scaling**.
  - **Zone-redundant deployments** for **Business Critical SKUs**.
- **AzureAD Integration**:
  - Azure AD integration implicitly via "Security-First Approach" and "Azure AD Authentication".

---

## 📂 Module Structure

```plaintext
az-mssql-db-casey/
│── atomic/                  # Core Terraform module (all reusable logic)
│   ├── main.tf              # Terraform resource definitions
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Outputs
│   ├── providers.tf         # Provider configuration
│── blueprints/              # Pre-configured Terraform examples for various use cases
│   ├── geo_redundant_database/  # Geo-redundant backup-enabled database
│   ├── replication/         # Read replica configurations
│   ├── serverless_database/ # Serverless database configurations
│   ├── standard_database/   # Standard MSSQL deployment
│── automation/              # CI/CD automation scripts
│── scripts/                 # Utility scripts for validation & compliance
│── README.md                # Main documentation
│── LICENSE                  # License information
│── .gitignore               # Git ignored files

```
## 📥 Input Variables

| Name                            | Type           | Default       | Description                                                                                          |
|---------------------------------|----------------|----------------|------------------------------------------------------------------------------------------------------|
| `environment`                   | `string`       | `"dev"`        | The deployment environment (e.g., dev, staging, prod).                                               |
| `location`                      | `string`       | `"centralus"`  | Azure region for the primary MSSQL Server.                                                           |
| `secondary_location`            | `string`       | `null`         | Optional secondary region for geo-redundancy or replication scenarios.                              |
| `subscription_id`               | `string`       | —              | The Azure Subscription ID.                                                                           |
| `tenant_id`                     | `string`       | —              | The Azure Tenant ID.                                                                                 |
| `resource_group_name`           | `string`       | —              | Name of the resource group to deploy into.                                                           |
| `create_resource_group`         | `bool`         | `false`        | Whether to create the resource group if it doesn’t already exist.                                    |
| `server_name`                   | `string`       | —              | The name of the Azure SQL Server.                                                                    |
| `admin_login`                   | `string`       | —              | Administrator login username for the SQL Server.                                                     |
| `admin_password`                | `string`       | —              | Administrator login password for the SQL Server (sensitive).                                         |
| `enable_monitoring`             | `bool`         | `true`         | Enables monitoring and diagnostic settings via Log Analytics.                                        |
| `log_analytics_workspace_id`    | `string`       | `null`         | Log Analytics workspace ID. Required if monitoring is enabled.                                       |
| `failover_group_name`           | `string`       | `"mssql-failover-group"` | Name of the failover group for geo-redundancy.                                              |
| `key_vault_id`                 | `string`       | `null`         | Azure Key Vault resource ID for Transparent Data Encryption with Customer-Managed Keys (CMK).       |
| `tags`                          | `map(string)`  | `{}`           | Tags to assign to all deployed resources.                                                            |
| `databases`                     | `map(object)`  | —              | A map of one or more MSSQL databases to create. Each database supports the following fields:         |
| `azuread_login_username`         | `string`       | —              | Azure AD login username to assign as the SQL Server administrator.         |
| `azuread_object_id`             | `string`       | —              | Azure AD object ID of the administrator (usually a user or group).         |


### 🔹 `databases` Object Schema

Each `databases` entry is an object with these optional and required fields:

| Field Name                                          | Type          | Default                       | Description                                                                 |
|-----------------------------------------------------|---------------|-------------------------------|-----------------------------------------------------------------------------|
| `name`                                              | `string`      | —                             | Name of the database. Must be unique per server.                           |
| `sku_name`                                          | `string`      | `"S0"` (or `"GP_S_Gen5_2"`)   | SKU tier: S0, GP_S_Gen5_2, BC_Gen5_2, DW100c, etc.                         |
| `max_size_gb`                                       | `number`      | `20` or `32` depending on SKU | Max database size in GB.                                                   |
| `collation`                                         | `string`      | `"SQL_Latin1_General_CP1_CI_AS"` | SQL collation setting.                                               |
| `zone_redundant`                                    | `bool`        | `false` or `true`             | Enables zone redundancy (Business Critical SKUs only).                     |
| `geo_backup_enabled`                                | `bool`        | `false` or `true`             | Enables geo-redundant backups (DW SKUs only).                             |
| `storage_account_type`                              | `string`      | `"LRS"`                        | Redundancy type: LRS, GRS, ZRS, etc.                                       |
| `create_mode`                                       | `string`      | `"Default"`                   | Options include Restore, Copy, Recovery, etc.                              |
| `restore_point_in_time`                             | `string`      | `null`                        | ISO timestamp for point-in-time restore.                                   |
| `restore_dropped_database_id`                       | `string`      | `null`                        | Resource ID of dropped database to restore.                                |
| `recover_database_id`                               | `string`      | `null`                        | Recoverable database resource ID.                                          |
| `auto_pause_delay_in_minutes`                       | `number`      | `-1` or `60`                  | For serverless SKUs: pause delay in minutes (`-1` disables).              |
| `min_capacity`                                      | `number`      | `0.5`                         | Minimum vCores for serverless databases.                                   |
| `read_replica_count`                                | `number`      | `null`                        | For Hyperscale SKUs only.                                                  |
| `failover_group_enabled`                            | `bool`        | `false` or `true`             | Enables geo-replication via failover group.                                |
| `secondary_location`                                | `string`      | `null` or inherited           | Secondary region if `failover_group_enabled` is true.                      |
| `prevent_destroy`                                   | `bool`        | `true`                        | Prevents database deletion unless forced.                                  |
| `ledger_enabled`                                    | `bool`        | `false`                       | Enables blockchain-style ledger auditing (not for DW or Hyperscale).       |
| `read_scale`                                        | `bool`        | `false`                       | Enables read-scale-out (Premium and BusinessCritical only).                |

#### 🔸 Short-Term Retention Policy

| Field                         | Type      | Default  | Description                                                         |
|------------------------------|-----------|----------|---------------------------------------------------------------------|
| `retention_days`             | `number`  | Required | Between 1 and 35.                                                   |
| `backup_interval_in_hours`   | `number`  | `12`     | Optional. Must be `12` or `24` if provided.                         |

#### 🔸 Long-Term Retention Policy

| Field              | Type     | Default | Description                                               |
|-------------------|----------|---------|-----------------------------------------------------------|
| `weekly_retention`| `string` | `"P1W"` | ISO 8601 duration format (e.g., `P1W`, `P7D`).            |
| `monthly_retention`| `string`| `"P1M"` | ISO 8601 format (`P1M`, `P30D`, etc.).                   |
| `yearly_retention`| `string` | `"P1Y"` | ISO 8601 format (`P1Y`, `P12M`, etc.).                   |
| `week_of_year`    | `number` | `null`  | 1–52 (used for yearly retention).                         |

#### 🔸 Threat Detection Policy

| Field                   | Type            | Description                                                                 |
|------------------------|-----------------|-----------------------------------------------------------------------------|
| `state`                | `string`        | Must be `"Enabled"` or `"Disabled"`.                                       |
| `email_account_admins`| `bool`           | Send alerts to account admins.                                             |
| `email_addresses`      | `list(string)`  | Additional emails to notify.                                               |
| `disabled_alerts`      | `list(string)`  | Alert types to suppress.                                                   |
| `retention_days`       | `number`        | Number of days to retain threat logs.                                      |
| `storage_endpoint`     | `string`        | Required if enabled. Must be valid Azure blob endpoint.                    |
| `storage_account_access_key` | `string` | Optional access key for audit storage.                                     |

#### 🔸 Extended Auditing Policy

| Field                         | Type     | Description                                                                 |
|------------------------------|----------|-----------------------------------------------------------------------------|
| `storage_endpoint`           | `string` | Required. Azure Blob Storage endpoint.                                     |
| `storage_account_access_key`| `string` | Optional key for access.                                                   |
| `retention_in_days`         | `number` | Optional. Retention between `0` and `3285`.                                |
| `log_monitoring_enabled`    | `bool`   | Enables Azure Monitor integration.                                         |

#### 🔸 Transparent Data Encryption (TDE)

| Field                                                | Type     | Description                                                                 |
|-----------------------------------------------------|----------|-----------------------------------------------------------------------------|
| `transparent_data_encryption_enabled`               | `bool`   | Enables TDE. Required to be `true` unless using DW SKUs.                    |
| `transparent_data_encryption_key_vault_key_id`      | `string` | CMK Key Vault Key URI.                                                     |
| `transparent_data_encryption_key_automatic_rotation_enabled` | `bool` | If `true`, key must be CMK and valid.                                 |

#### 🔸 Tags

| Field       | Type          | Default |
|-------------|---------------|---------|
| `tags`      | `map(string)` | `{}`    | Custom tags to assign to each database.                                    |


---
### ✅ MSSQL Terraform Module – Validation Summary

| #  | Scope          | Field(s)                                                                                   | Validation Purpose                                                                                   | Key Logic or Pattern                                                                                   |
|----|----------------|---------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| 1  | General         | `resource_group_name`                                                                      | Ensure RG name is not empty                                                                           | `length(var.resource_group_name) > 0`                                                                   |
| 2  | General         | `key_vault_id`                                                                             | Validate full resource ID format without trailing slash                                                | Regex + `!endswith(...)`                                                                                 |
| 3  | General         | `log_analytics_workspace_id`                                                               | Validate full Log Analytics Workspace ID                                                              | Regex check on full path                                                                                 |
| 4  | Server Config   | `server.version`                                                                           | Allow only valid versions                                                                              | `"12.0"` and `"2.0"`                                                                                     |
| 5  | Server Config   | `server.minimum_tls_version`                                                               | Validate TLS version                                                                                    | Must be one of: `1.0`, `1.1`, `1.2`                                                                      |
| 6  | Server Config   | `server.name`                                                                              | Alphanumeric + dash only naming                                                                        | Regex and length (1–63)                                                                                  |
| 7  | Server Config   | `server.identity`                                                                          | Validate user-assigned identity and ID presence                                                       | Type-specific presence validation                                                                         |
| 8  | Server Config   | `server.user_assigned_identity_id`                                                        | Ensure identity_id is set when using UserAssigned                                                     | Logical enforcement                                                                                      |
| 9  | Server Config   | `server.failover_group_name`                                                              | Validate FOG name format and length                                                                    | Regex and 1–128 chars                                                                                    |
| 10 | Server Config   | `server.secondary_location`                                                               | Required if failover group enabled                                                                     | Non-null if `enable_failover_group`                                                                      |
| 11 | Server Config   | `azuread_administrator`                                                                    | Required always                                                                                        | Non-null                                                                                                 |
| 12 | Server Config   | `transparent_data_encryption_key_vault_key_id`                                            | Validate CMK URI                                                                                       | Must match Azure Key Vault Key URI regex                                                                 |
| 13 | Database Config | `databases.*.name`                                                                         | Name length bounds                                                                                     | 1–128 characters                                                                                          |
| 14 | Database Config | `databases.*.sku_name`                                                                     | Allow only specific SKUs                                                                               | Basic, S0/S1/S2, Gen5 SKUs, DW100c                                                                       |
| 15 | Database Config | `databases.*.max_size_gb`                                                                  | Size between 1–4096 GB                                                                                 | `> 0` and `<= 4096`                                                                                       |
| 16 | Database Config | `databases.*.collation`                                                                    | Valid format                                                                                           | Regex: `^[a-zA-Z0-9_]+$`                                                                                 |
| 17 | Database Config | `databases.*.create_mode`                                                                  | Validate allowed create_mode values                                                                    | Must be one of: `Default`, `Copy`, `Secondary`, `Restore`, etc.                                         |
| 18 | Database Config | `databases.*.create_mode` & `restore_*` fields                                             | Ensure restore fields only set when create_mode is Restore                                            | Restore-specific condition logic                                                                         |
| 19 | Database Config | `databases.*.sample_name`                                                                  | Only allowed in Default mode                                                                           | Null unless create_mode = Default                                                                        |
| 20 | Database Config | `databases.*.license_type`                                                                 | Must be LicenseIncluded or BasePrice                                                                   | Static list check                                                                                        |
| 21 | Database Config | `databases.*.prevent_destroy`                                                              | Must be boolean                                                                                        | `can(tobool(...))`                                                                                       |
| 22 | Database Config | `databases.*.read_scale`                                                                   | Allowed only for Premium/BusinessCritical                                                              | SKU-dependent                                                                                             |
| 23 | Database Config | `databases.*.zone_redundant`                                                               | Allowed only for Premium/BusinessCritical                                                              | SKU-dependent                                                                                             |
| 24 | Database Config | `databases.*.geo_backup_enabled`                                                           | Allowed only for DW SKUs                                                                               | Regex check on SKU                                                                                       |
| 25 | Database Config | `databases.*.read_replica_count`                                                           | Allowed only for Hyperscale                                                                            | SKU check                                                                                                 |
| 26 | Database Config | `databases.*.ledger_enabled`                                                               | Not supported on DW/Hyperscale                                                                         | Negative logic for DW/Hyperscale                                                                         |
| 27 | Database Config | `databases.*.transparent_data_encryption_enabled`                                          | Must be enabled unless DW                                                                              | Negative logic                                                                                           |
| 28 | Database Config | `databases.*.transparent_data_encryption_key_vault_key_id` on DW                           | CMK not supported on DW                                                                                | Null check with DW SKU                                                                                   |
| 29 | Database Config | `databases.*.transparent_data_encryption_key_automatic_rotation_enabled`                  | Must only be true if CMK is configured                                                                 | Paired condition                                                                                          |
| 30 | Database Config | `databases.*.short_term_retention_policy.retention_days`                                   | Must be 1–35                                                                                           | Numeric bounds                                                                                            |
| 31 | Database Config | `databases.*.short_term_retention_policy.backup_interval_in_hours`                         | Must be 12 or 24                                                                                       | List check                                                                                               |
| 32 | Database Config | `databases.*.short_term_retention_policy`                                                  | Interval set only when retention_days is set                                                           | Cross-field condition                                                                                     |
| 33 | Database Config | `databases.*.long_term_retention_policy.*`                                                 | Valid ISO 8601 formats + week_of_year range                                                            | Regex validation and numeric bounds                                                                      |
| 34 | Database Config | `databases.*.threat_detection_policy.*`                                                    | Enabled state must match required fields                                                               | Requires `storage_endpoint` if Enabled, `retention_days` ≥ 0                                             |
| 35 | Database Config | `databases.*.extended_auditing_policy.*`                                                   | Must have either storage_endpoint or monitoring enabled                                                | Logical presence                                                                                          |
| 36 | Database Config | `databases.*.extended_auditing_policy.retention_in_days`                                   | 0–3285 days                                                                                            | Numeric range                                                                                            |
| 37 | Database Config | `databases.*.extended_auditing_policy.storage_account_access_key_is_secondary`             | Can only be used if access key is provided                                                             | Null check combined                                                                                       |
| 38 | Server & DB     | `enclave_type`                                                                             | If set, must be Default/VBS and not used on DW/DC SKUs                                                 | SKU + allowed values check                                                                               |
| 39 | Server & DB     | `zone_redundant`, `read_scale`, `geo_backup_enabled`                                       | Combined SKU dependencies                                                                              | All must be validated together                                                                            |
| 40 | Server & DB     | `identity.type`                                                                             | Mixed identity types require identity_ids                                                              | Logic specific to SystemAssigned, UserAssigned combinations                                              |

---

## 🛠 Usage

### 📘 Example Blueprints for MSSQL Deployment

This repository includes four ready-to-use blueprint configurations under the [`/blueprints`](./blueprints) folder. Each blueprint demonstrates a specific MSSQL deployment strategy using the shared [`/atomic`](./atomic) Terraform module.

---

### **Standard Database** – [`blueprints/standard_database`](./blueprints/standard_database)

A basic configuration for deploying a single Azure SQL database under a single server, typically used for development or lightweight production workloads.

```hcl
module "standard_database" {
  source = "../../atomic"

  environment         = var.environment
  location            = var.location
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
  resource_group_name = var.resource_group_name
  key_vault_id        = var.key_vault_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  mssql_config = {
    server = {
      name                          = var.server_name
      create_resource_group         = var.create_resource_group
      version                       = "12.0"
      minimum_tls_version           = "1.2"
      public_network_access_enabled = true
      outbound_network_restriction_enabled = false
      enable_monitoring             = var.enable_monitoring
      enable_threat_detection       = true
      azuread_administrator = {
        login_username = var.azuread_login_username
        object_id      = var.azuread_object_id
      }
      tags = var.tags
    }

    databases = var.databases
  }
}
```

---

### **Serverless Database** – [`blueprints/serverless_database`](./blueprints/serverless_database)

Deploys a serverless SQL database using General Purpose (GP_S_Gen5) SKUs with auto-pause and dynamic compute scaling enabled.

```hcl
module "serverless_database" {
  source = "../../atomic"

  environment         = var.environment
  location            = var.location
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
  resource_group_name = var.resource_group_name
  key_vault_id        = var.key_vault_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  mssql_config = {
    server = {
      name                          = var.server_name
      create_resource_group         = var.create_resource_group
      version                       = "12.0"
      administrator_login           = var.admin_login
      administrator_login_password  = var.admin_password
      minimum_tls_version           = "1.2"
      public_network_access_enabled = true
      outbound_network_restriction_enabled = false
      enable_monitoring             = var.enable_monitoring
      enable_threat_detection       = true
      azuread_administrator = {
        login_username = var.azuread_login_username
        object_id      = var.azuread_object_id
      }
      tags = var.tags
    }

    databases = var.databases
  }
}
```

---

### **Geo-Redundant Database with Failover Group** – [`blueprints/geo_redundant_database`](./blueprints/geo_redundant_database)

Provisions a primary SQL server and a geo-redundant secondary in a different Azure region using a failover group.

```hcl
module "geo_redundant_mssql" {
  source = "../../atomic"

  environment         = var.environment
  location            = var.location
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
  resource_group_name = var.resource_group_name
  key_vault_id        = var.key_vault_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  mssql_config = {
    server = {
      name                          = var.server_name
      create_resource_group         = var.create_resource_group
      location                      = var.location
      secondary_location            = var.secondary_location
      version                       = "12.0"
      administrator_login           = var.admin_login
      administrator_login_password  = var.admin_password
      minimum_tls_version           = "1.2"
      public_network_access_enabled = false
      outbound_network_restriction_enabled = true
      enable_monitoring             = var.enable_monitoring
      enable_threat_detection       = true
      enable_failover_group         = true
      failover_group_name           = var.failover_group_name
      azuread_administrator = {
        login_username = var.azuread_login_username
        object_id      = var.azuread_object_id
      }
      tags = var.tags
    }

    databases = {
      for db_name, db in var.databases : db_name => merge(db, {
        failover_group_enabled = true
        secondary_location     = var.secondary_location
      })
    }
  }
}
```

### **Replication with Read-Only Replicas** – [`blueprints/replication`](./blueprints/replication)

Deploys a SQL server with optional read-only replicas and a failover group. Configurable read replica count for Hyperscale SKUs.

```hcl
module "replicated_mssql" {
  source = "../../atomic"

  environment         = var.environment
  location            = var.location
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
  resource_group_name = var.resource_group_name
  key_vault_id        = var.key_vault_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  mssql_config = {
    server = {
      name                          = var.server_name
      create_resource_group         = var.create_resource_group
      secondary_location            = var.secondary_location
      version                       = "12.0"
      administrator_login           = var.admin_login
      administrator_login_password  = var.admin_password
      minimum_tls_version           = "1.2"
      public_network_access_enabled = false
      outbound_network_restriction_enabled = true
      enable_monitoring             = var.enable_monitoring
      enable_threat_detection       = true
      enable_failover_group         = true
      failover_group_name           = var.failover_group_name
      azuread_administrator = {
        login_username = var.azuread_login_username
        object_id      = var.azuread_object_id
      }
      tags = var.tags
    }

    databases = {
      for db_name, db in var.databases : db_name => merge(db, {
        failover_group_enabled = true
        secondary_location     = var.secondary_location
      })
    }
  }
}


```
## 📤 Outputs

The following outputs are available from the module after deployment:

| Output Name                        | Type              | Description                                                                                  |
|-----------------------------------|-------------------|----------------------------------------------------------------------------------------------|
| `mssql_server_id`                 | `string`          | The ID of the primary Azure MSSQL Server.                                                    |
| `mssql_server_fqdn`              | `string`          | The Fully Qualified Domain Name (FQDN) of the primary Azure MSSQL Server.                    |
| `mssql_database_ids`             | `map(string)`     | A map of database names to their corresponding Azure MSSQL Database resource IDs.            |
| `mssql_database_names`           | `list(string)`    | A list of all MSSQL database names created in this deployment.                              |
| `mssql_server_identity`          | `object`          | The identity block for the MSSQL Server (e.g., `principal_id`, `type`, etc.), if enabled.    |
| `mssql_database_encryption_keys` | `map(string)`     | A map of database names to the Transparent Data Encryption (TDE) key URIs, if configured.    |
| `mssql_threat_detection_policies`| `map(string)`     | A map of database names to their respective threat detection policy states.                 |
| `mssql_extended_auditing_policies` | `map(string)`   | A map of database names to their extended auditing policy `storage_endpoint` values.         |
| `mssql_resource_group_name`      | `string`          | The name of the resource group in which the MSSQL Server was deployed.                       |

---

## 📞 Support

For issues, please contact the **Blue Sentry Cloud TACE Team**.

---
