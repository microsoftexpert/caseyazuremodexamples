# Terraform Module: Azure Linux Web App (azurerm_linux_web_app)

## 📑 Table of Contents

- [🚀 Features Summary](#-features-summary)
- [📥 Input Variables](#-input-variables)
  - [`web_app_config` Object Schema](#web_app_config-object-schema)
    - [Required Base Fields](#-required-base-fields)
    - [Optional Top-Level Fields](#-optional-top-level-fields)
    - [`site_config` Sub-Object](#-site_config-sub-object)
    - [`application_stack` Sub-Object](#-application_stack-sub-object)
    - [`auto_heal_setting` Sub-Object](#-auto_heal_setting-sub-object)
      - [`triggers` Subfields](#-triggers-subfields)
      - [`actions` Subfields](#-actions-subfields)
    - [`ip_restriction` Entry Fields](#-ip_restriction-entry-fields)
    - [`identity` Object](#-identity-object)
    - [`auth_settings` (Easy Auth v1)](#-auth_settings-easy-auth-v1)
    - [`auth_settings_v2` (Easy Auth v2)](#-auth_settings_v2-easy-auth-v2)
    - [`backup` Object](#-backup-object)
      - [`schedule` Fields](#-schedule-fields)
    - [`logs` Object](#-logs-object)
      - [`application_logs` Fields](#-application_logs-fields)
      - [`http_logs` Fields](#-http_logs-fields)
    - [`connection_string` Entry Fields](#-connection_string-entry-fields)
    - [`storage_account` Entry Fields](#-storage_account-entry-fields)
    - [`slots` (Deployment Slots)](#-slots-deployment-slots)
- [✅ Validation Summary (Grouped)](#validation-summary-grouped)
- [✅ Validation Summary (Full List)](#validation-summary-full-list)
- [📤 Outputs - Azure Linux Web App Terraform Module](#-outputs---azure-linux-web-app-terraform-module)
- [📞 Support](#-support)

> ✅ **Requires:** Terraform >= 1.4.0, AzureRM Provider >= 3.93.0

This module provides a **Terraform implementation** for deploying an **Azure Linux Web App** (azurerm_linux_web_app) with **robust configuration options**, including **auth settings**, **deployment slots**, **VNet integration**, **identity**, **site config**, and **logging/backup support**.

**By Casey Wood**  
microsoftexpert@gmail.com



- [🚀 Features Summary](#features-summary)

- **Highly Configurable**:
  - Supports both **`auth_settings`** (Easy Auth v1) and **`auth_settings_v2`** (Easy Auth v2) with comprehensive provider-level configuration (Azure AD, Facebook, GitHub, Google, Microsoft, Twitter, Apple, custom OIDC) and secret management via app settings or direct values.
  - Fully configurable **deployment slots** with independent `site_config`, `identity`, `app_settings`, `connection_strings`, `auth_settings`, `logs`, `sticky_settings`, and `backup` options, supporting up to 20 slots (Azure Premium tier limit).
  - Rich **App Service `site_config`** block with support for FTPS state, auto-heal rules, managed pipeline modes, TLS settings, health checks, IP restrictions, SCM IP restrictions, CORS, default documents, HTTP/2, 32-bit workers, and application stacks (Docker, Python, Node.js, .NET, Java, PHP, Ruby, Go).
  - Supports **sticky settings** for app settings and connection strings to persist across slot swaps.

- **Security-First Design**:
  - Integrated **Managed Identity** support for `SystemAssigned`, `UserAssigned`, or both, with validation for identity IDs and Key Vault reference integration.
  - Enforces **HTTPS-only** (with warnings if disabled), optional **client certificate validation** (Required, Optional, OptionalInteractiveUser), exclusion paths, and **header-aware IP/SCM restrictions** with detailed header support (X-Forwarded-For, X-Azure-FDID, etc.).
  - Full validation for authentication modes, Easy Auth providers, secret usage, TLS versions, and VNet integration.

- **Networking & VNet Integration**:
  - Automatic **Swift VNet Integration** via `virtual_network_subnet_id`, ensuring slots inherit the same subnet with regional consistency checks.
  - Configurable **IP restrictions** and **SCM IP restrictions** with priority, action (Allow/Deny), and header-based filtering.

- **Advanced Application Configuration**:
  - Comprehensive **application settings** and **connection strings** with uniqueness enforcement across main app and slots.
  - Modular **application stack** support for Docker (with registry credentials), .NET (including isolated runtime), Node.js, Python, Java (Tomcat/JBossEAP), PHP, Ruby, and Go, with mutual exclusivity checks (e.g., Node.js vs Java).
  - **Zip deployment** support with validation for `.zip` files and required app settings (e.g., `WEBSITE_RUN_FROM_PACKAGE`).
  - **Azure Storage mounts** (Azure Files/Blob) with up to 5 mounts, validated naming, and mount path uniqueness.

- **Backup & Logging**:
  - Native **backup configuration** with schedules (hourly/daily), retention, and RFC3339 start times, restricted to supported SKUs (Standard, Premium, Isolated).
  - Configurable **application and HTTP logs** to file system or Azure Blob Storage, with retention and level settings (Verbose, Information, Warning, Error).

- **Extensive Terraform Validations**:
  - Over **200 validation rules** covering core fields, identity, auth settings, site config, auto-heal, IP restrictions, logs, backups, slots, tags, timeouts, and more.
  - Ensures **cross-field logic** (e.g., auto-heal triggers with actions), **value constraints** (e.g., TLS 1.0-1.2), **regex enforcement** (e.g., resource IDs, paths), and **Azure best practices** (e.g., SKU compatibility).

---

## 📥 Blueprints

This section describes the different deployment blueprints included with this module. Each represents a **unique, non-overlapping use case** and should remain separate for clarity and maintainability.

| Blueprint Folder                  | Why This Is a Unique Use Case                                                                 |
|----------------------------------|-----------------------------------------------------------------------------------------------|
| `blue_green_deployment_options`  | Implements a zero-downtime deployment strategy using slots and traffic routing.               |
| `cdn_frontend_webapp`            | Uses Azure CDN for frontend delivery, requiring additional edge integration and config.       |
| `enterprise_networked_webapp`    | Integrates tightly with enterprise VNets, NSGs, and private DNS—specific to secure environments. |
| `github_actions_ci_cd`           | Focused on CI/CD automation using GitHub Actions. CI/CD is an independent integration concern.|
| `high_availability_webapp`       | Designed for zone-redundancy or multi-region architecture, often involving Traffic Manager.   |
| `minimal_serverless_webapp`      | Merged blueprint for minimal + serverless + event-driven use cases. Lightweight and flexible. |
| `multitenant_webapp`             | Supports multitenancy with domain isolation, scoped auth, and app-level separation.           |
| `secured_auth_webapp`           | Implements Easy Auth v2 and provider-based login flows. Dedicated to authentication patterns.  |

---


- [📥 Input Variables](#-input-variables)

| Name             | Type          | Default | Description                                                        |
|------------------|---------------|---------|--------------------------------------------------------------------|
| `web_app_config` | `object`      | —       | Configuration object for the Azure Linux Web App and its slots.    |
| `tags`           | `map(string)` | `{}`    | Optional tags to apply to all resources.                          |

The module accepts two top-level variables: `web_app_config` for detailed Web App configuration and `tags` for resource tagging. The `web_app_config` object is highly configurable, with required and optional fields detailed below.



  - [`web_app_config` Object Schema](#web_app_config-object-schema)

    - [Required Base Fields](#required-base-fields)

| Field                 | Type     | Description                                                     |
|-----------------------|----------|-----------------------------------------------------------------|
| `name`                | `string` | Name of the Azure Web App (2-64 characters, alphanumeric with dashes). |
| `resource_group_name` | `string` | Name of the resource group to deploy into.                     |
| `location`            | `string` | Azure region where the Web App will be deployed (e.g., "eastus"). |
| `site_config`         | `object` | Main site configuration block (see below for nested structure).|

> **Note**: Either `service_plan` or `service_plan_id` must be provided (mutually exclusive) to specify the App Service Plan.



    - [Optional Top-Level Fields](#optional-top-level-fields)

| Field                                      | Type                 | Description                                                               |
|--------------------------------------------|----------------------|---------------------------------------------------------------------------|
| `service_plan`                             | `object`             | Configuration for a new App Service Plan (see `service_plan` sub-object). |
| `service_plan_id`                          | `string`             | Resource ID of an existing App Service Plan.                              |
| `identity`                                 | `object`             | Managed identity configuration (SystemAssigned/UserAssigned).             |
| `auth_settings`                            | `object`             | Legacy authentication settings (Easy Auth v1).                            |
| `auth_settings_v2`                         | `object`             | Modern authentication settings (Easy Auth v2).                            |
| `backup`                                   | `object`             | Backup configuration with schedule and storage details.                   |
| `logs`                                     | `object`             | Diagnostics logging configuration for application and HTTP logs.          |
| `app_settings`                             | `map(string)`        | Key-value pairs for application settings (max 100KB total).               |
| `connection_string`                        | `list(object)`       | List of connection strings (e.g., SQLAzure, Custom).                      |
| `storage_account`                          | `list(object)`       | Azure Storage mounts (AzureFiles or AzureBlob, max 5).                    |
| `tags`                                     | `map(string)`        | Resource-specific tags (overrides top-level `tags` if provided).          |
| `client_affinity_enabled`                  | `bool`               | Enables client affinity (sticky sessions); defaults to `true`.            |
| `client_certificate_enabled`               | `bool`               | Enables client certificate authentication; defaults to `false`.           |
| `client_certificate_mode`                  | `string`             | Certificate mode: `Required`, `Optional`, or `OptionalInteractiveUser`.   |
| `client_certificate_exclusion_paths`       | `string`             | Comma-separated paths excluded from client cert checks (max 50).          |
| `enabled`                                  | `bool`               | Whether the Web App is enabled; defaults to `true`.                       |
| `https_only`                               | `bool`               | Enforces HTTPS-only traffic; defaults to `false`.                         |
| `virtual_network_subnet_id`                | `string`             | Subnet ID for VNet integration (must match resource group).               |
| `ftp_publish_basic_authentication_enabled` | `bool`               | Enables FTP basic auth publishing; defaults to `true`.                    |
| `webdeploy_publish_basic_authentication_enabled` | `bool`         | Enables WebDeploy basic auth; defaults to `false`.                        |
| `public_network_access_enabled`            | `bool`               | Enables public network access; defaults to `true`.                        |
| `key_vault_reference_identity_id`          | `string`             | User-assigned identity ID for Key Vault references.                       |
| `zip_deploy_file`                          | `string`             | Path to a `.zip` file for deployment (requires specific app settings).    |
| `timeouts`                                 | `object`             | Custom timeouts for create, update, delete (max 2 hours).                 |
| `sticky_settings`                          | `object`             | Settings to persist across slot swaps (app settings/connection strings).  |
| `slots`                                    | `list(object)`       | List of deployment slots (mirrors `web_app_config` structure, max 20).    |



    - [`site_config` Sub-Object](#site_config-sub-object)

| Field                                      | Type                 | Description                                                  |
|--------------------------------------------|----------------------|--------------------------------------------------------------|
| `always_on`                                | `bool`               | Keeps the app running; defaults to `false` (SKU-dependent).  |
| `linux_fx_version`                         | `string`             | Runtime stack (e.g., `PYTHON|3.11`) for custom containers.   |
| `ftps_state`                               | `string`             | FTPS mode: `AllAllowed`, `FtpsOnly`, or `Disabled`.          |
| `minimum_tls_version`                      | `string`             | Minimum TLS version: `1.0`, `1.1`, or `1.2`.                 |
| `scm_minimum_tls_version`                  | `string`             | SCM TLS version: `1.0`, `1.1`, or `1.2`.                     |
| `remote_debugging_enabled`                 | `bool`               | Enables remote debugging; defaults to `false`.               |
| `remote_debugging_version`                 | `string`             | Debugging version: `VS2012`, `VS2013`, `VS2015`, `VS2017`.   |
| `websockets_enabled`                       | `bool`               | Enables WebSockets; defaults to `false`.                     |
| `vnet_route_all_enabled`                   | `bool`               | Routes all traffic through VNet; requires subnet ID.         |
| `http2_enabled`                            | `bool`               | Enables HTTP/2; defaults to `false`.                         |
| `health_check_path`                        | `string`             | Health check endpoint path (e.g., `/health`).                |
| `health_check_eviction_time_in_min`        | `number`             | Eviction time after health check failure (2-10 minutes).     |
| `managed_pipeline_mode`                    | `string`             | Pipeline mode: `Integrated` or `Classic`.                    |
| `load_balancing_mode`                      | `string`             | Load balancing: `WeightedRoundRobin`, `LeastRequests`, etc.  |
| `app_command_line`                         | `string`             | Command to run app (requires `linux_fx_version`).            |
| `container_registry_use_managed_identity`  | `bool`               | Uses managed identity for container registry auth.           |
| `container_registry_managed_identity_client_id` | `string`        | Client ID for container registry managed identity.           |
| `scm_use_main_ip_restriction`              | `bool`               | Applies main IP restrictions to SCM; defaults to `false`.    |
| `default_documents`                        | `list(string)`       | Default documents (e.g., `index.html`).                      |
| `number_of_workers`                        | `number`             | Number of workers (1-20, SKU-dependent).                     |
| `api_definition_url`                       | `string`             | HTTPS URL for API definition.                                |
| `api_management_api_id`                    | `string`             | API Management API resource ID.                              |
| `ip_restriction_default_action`            | `string`             | Default action for IP restrictions: `Allow` or `Deny`.       |
| `scm_ip_restriction_default_action`        | `string`             | Default action for SCM IP restrictions: `Allow` or `Deny`.   |
| `use_32_bit_worker`                        | `bool`               | Uses 32-bit worker process; defaults to `false`.             |
| `application_stack`                        | `object`             | Application stack configuration (see below).                 |
| `auto_heal_setting`                        | `object`             | Auto-heal trigger and action configuration (see below).      |
| `ip_restriction`                           | `list(object)`       | IP restriction rules (see below).                            |
| `scm_ip_restriction`                       | `list(object)`       | SCM IP restriction rules (see below).                        |
| `cors`                                     | `object`             | CORS configuration (see below).                              |



    - [`application_stack` Sub-Object](#application_stack-sub-object)

| Field                      | Type     | Description                                  |
|----------------------------|----------|----------------------------------------------|
| `docker_image_name`        | `string` | Docker image name (requires registry URL).   |
| `docker_registry_url`      | `string` | Docker registry URL (e.g., `https://myreg.io`). |
| `docker_registry_username` | `string` | Docker registry username.                    |
| `dotnet_version`           | `string` | .NET version: `3.1`, `5.0`, `6.0`, `7.0`, `8.0`. |
| `use_dotnet_isolated_runtime` | `bool` | Uses isolated runtime for .NET 6.0+; defaults to `false`. |
| `node_version`             | `string` | Node.js version: `12-lts`, `14-lts`, etc.    |
| `python_version`           | `string` | Python version: `3.7`, `3.8`, `3.9`, `3.10`, `3.11`. |
| `php_version`              | `string` | PHP version: `7.4`, `8.0`, `8.1`, `8.2`, `8.3`. |
| `java_version`             | `string` | Java version: `8`, `11`, `17`, `21`.         |
| `java_server`              | `string` | Java server: `JAVA`, `TOMCAT`, `JBOSSEAP`.   |
| `java_server_version`      | `string` | Java server version (e.g., `8.5`, `9.0`).    |
| `ruby_version`             | `string` | Ruby version: `2.7`.                         |
| `go_version`               | `string` | Go version: `1.18`, `1.19`.                  |



    - [`auto_heal_setting` Sub-Object](#auto_heal_setting-sub-object)

| Field      | Type   | Description                                      |
|------------|--------|--------------------------------------------------|
| `triggers` | `object` | Conditions triggering auto-heal (see below).   |
| `actions`  | `object` | Actions taken when triggered (see below).      |

      - [`triggers` Subfields](#triggers-subfields)

| Field          | Type     | Description                                  |
|----------------|----------|----------------------------------------------|
| `slow_request` | `object` | Triggers on slow requests (count, interval, time taken). |
| `status_code`  | `list(object)` | Triggers on HTTP status codes (range, count, etc.). |
| `requests`     | `object` | Triggers on request count over an interval.  |

      - [`actions` Subfields](#actions-subfields)

| Field                            | Type     | Description                                      |
|----------------------------------|----------|--------------------------------------------------|
| `action_type`                    | `string` | Action: `Recycle`, `LogEvent`, or `CustomAction`. |
| `minimum_process_execution_time` | `string` | Minimum process runtime before action (hh:mm:ss). |



    - [`ip_restriction` Entry Fields](#ip_restriction-entry-fields)

| Field                        | Type     | Description                                                    |
|------------------------------|----------|----------------------------------------------------------------|
| `name`                       | `string` | Name of the restriction rule.                                  |
| `ip_address`                 | `string` | IP address or CIDR (e.g., `192.168.1.0/24`).                  |
| `service_tag`                | `string` | Azure service tag (e.g., `AzureCloud`).                       |
| `virtual_network_subnet_id`  | `string` | Subnet ID for access control.                                  |
| `action`                     | `string` | Action: `Allow` or `Deny`.                                     |
| `priority`                   | `number` | Rule priority (100-65535, must be unique).                    |
| `headers`                    | `object` | Header-based filtering (e.g., `x_forwarded_for`).             |

> **Note**: Exactly one of `ip_address`, `service_tag`, or `virtual_network_subnet_id` must be specified per rule.



    - [`identity` Object](#identity-object)

| Field         | Type           | Description                                                           |
|---------------|----------------|-----------------------------------------------------------------------|
| `type`        | `string`       | Identity type: `SystemAssigned`, `UserAssigned`, or both combined.    |
| `identity_ids`| `list(string)` | User-assigned identity resource IDs (required for `UserAssigned`).    |



    - [`auth_settings` (Easy Auth v1)](#auth_settings-easy-auth-v1)

| Field                          | Type     | Description                                           |
|--------------------------------|----------|-------------------------------------------------------|
| `enabled`                      | `bool`   | Enables Easy Auth v1; defaults to `true`.             |
| `token_refresh_extension_hours`| `number` | Hours to extend token refresh.                        |
| `allowed_external_redirect_urls` | `list(string)` | URLs allowed for redirect after auth.           |
| `unauthenticated_client_action`| `string` | Action for unauthenticated users: `RedirectToLoginPage`, `AllowAnonymous`. |
| `default_provider`             | `string` | Default provider (e.g., `AzureActiveDirectory`).      |
| `active_directory`             | `object` | Azure AD configuration (client ID, secret, etc.).     |
| `facebook`                     | `object` | Facebook auth configuration.                          |
| `github`                       | `object` | GitHub auth configuration.                            |
| `google`                       | `object` | Google auth configuration.                            |
| `microsoft`                    | `object` | Microsoft auth configuration.                         |
| `twitter`                      | `object` | Twitter auth configuration.                           |



    - [`auth_settings_v2` (Easy Auth v2)](#auth_settings_v2-easy-auth-v2)

| Field                       | Type             | Description                                                         |
|-----------------------------|------------------|---------------------------------------------------------------------|
| `auth_enabled`              | `bool`           | Enables Easy Auth v2; defaults to `true`.                           |
| `require_authentication`    | `bool`           | Requires auth for all requests; defaults to `false`.                |
| `unauthenticated_action`    | `string`         | Action for unauthenticated: `RedirectToLoginPage`, `AllowAnonymous`.|
| `default_provider`          | `string`         | Default provider (e.g., `AzureActiveDirectory`).                    |
| `forward_proxy_convention`  | `string`         | Proxy convention: `NoProxy`, `Standard`, `Custom`.                  |
| `cookie_expiration_convention` | `string`      | Cookie expiration: `FixedTime`, `IdentityProviderDerived`.          |
| `cookie_expiration_time`    | `string`         | Fixed expiration time (hh:mm:ss).                                   |
| `nonce_expiration_time`     | `string`         | Nonce expiration time (hh:mm:ss).                                   |
| `login`                     | `object`         | Login settings (token store, redirect URLs, etc.).                  |
| `active_directory_v2`       | `object`         | Azure AD v2 configuration.                                          |
| `identity_providers`        | `list(object)`   | Custom providers (e.g., Apple, Google, custom OIDC).                |



    - [`backup` Object](#backup-object)

| Field                | Type     | Description                                                |
|----------------------|----------|------------------------------------------------------------|
| `name`               | `string` | Name of the backup configuration.                          |
| `storage_account_url`| `string` | SAS URL to blob container for backups.                     |
| `enabled`            | `bool`   | Enables backup; defaults to `true`.                        |
| `schedule`           | `object` | Backup schedule (see below).                               |

      - [`schedule` Fields](#schedule-fields)

| Field                         | Type     | Description                                      |
|-------------------------------|----------|--------------------------------------------------|
| `frequency_interval`          | `number` | Frequency of backups (1-720 hours or 1-30 days). |
| `frequency_unit`              | `string` | Unit: `Hour` or `Day`.                           |
| `retention_period_days`       | `number` | Retention period (0+ days).                      |
| `keep_at_least_one_backup`    | `bool`   | Retains at least one backup; defaults to `false`.|
| `start_time`                  | `string` | Start time in RFC3339 format (e.g., `2025-01-01T00:00:00Z`). |



    - [`logs` Object](#logs-object)

| Field              | Type   | Description                                                  |
|--------------------|--------|--------------------------------------------------------------|
| `application_logs` | `object` | Application logs configuration (see below).                |
| `http_logs`        | `object` | HTTP logs configuration (see below).                       |
| `detailed_error_messages_enabled` | `bool` | Enables detailed error logs; defaults to `false`.   |
| `failed_request_tracing_enabled`  | `bool` | Enables failed request tracing; defaults to `false`.|

      - [`application_logs` Fields](#application_logs-fields)

| Field                   | Type     | Description                                       |
|-------------------------|----------|---------------------------------------------------|
| `file_system_level`     | `string` | Logging level: `Verbose`, `Information`, etc.     |
| `azure_blob_storage`    | `object` | Blob storage config (level, SAS URL, retention).  |

      - [`http_logs` Fields](#http_logs-fields)

| Field                | Type   | Description                                         |
|----------------------|--------|-----------------------------------------------------|
| `file_system`        | `object` | File system config (retention in MB/days).         |
| `azure_blob_storage` | `object` | Blob storage config (SAS URL, retention in days).  |



    - [`connection_string` Entry Fields](#connection_string-entry-fields)

| Field  | Type     | Description                                      |
|--------|----------|--------------------------------------------------|
| `name` | `string` | Unique name (max 255 chars).                    |
| `type` | `string` | Type: `SQLAzure`, `MySQL`, `Custom`, etc.        |
| `value`| `string` | Connection string value (max 4096 chars).       |



    - [`storage_account` Entry Fields](#storage_account-entry-fields)

| Field         | Type     | Description                                         |
|---------------|----------|-----------------------------------------------------|
| `name`        | `string` | Mount name (3-63 chars, alphanumeric/dashes).      |
| `account_name`| `string` | Storage account name (3-24 chars).                 |
| `access_key`  | `string` | Access key (min 30 chars).                         |
| `share_name`  | `string` | File share or blob container name (max 63 chars).  |
| `type`        | `string` | Mount type: `AzureFiles` or `AzureBlob`.           |
| `mount_path`  | `string` | Mount path in container (starts with `/`).         |



    - [`slots` (Deployment Slots)](#-slots-deployment-slots)

Each slot entry mirrors the `web_app_config` structure with these fields:

| Field                       | Type                 | Description                                              |
|-----------------------------|----------------------|----------------------------------------------------------|
| `name`                      | `string`             | Unique slot name (1-59 chars, alphanumeric/dashes).      |
| `app_settings`              | `map(string)`        | Slot-specific app settings.                              |
| `connection_string`         | `list(object)`       | Slot-specific connection strings (see above).            |
| `site_config`               | `object`             | Slot-specific site config (subset of main `site_config`).|
| `storage_account`           | `list(object)`       | Slot-specific storage mounts (see above).                |
| `auth_settings`             | `object`             | Slot-specific Easy Auth v1 settings.                     |
| `auth_settings_v2`          | `object`             | Slot-specific Easy Auth v2 settings.                     |
| `identity`                  | `object`             | Slot-specific managed identity (see above).              |
| `tags`                      | `map(string)`        | Slot-specific tags (merged with main tags).              |
| `client_affinity_enabled`   | `bool`               | Slot-specific client affinity; inherits from main.       |
| `client_certificate_enabled`| `bool`               | Enables client certs for slot; defaults to `false`.      |
| `client_certificate_mode`   | `string`             | Slot cert mode: `Required`, `Optional`, etc.             |
| `https_only`                | `bool`               | Enforces HTTPS for slot; inherits from main.             |
| `enabled`                   | `bool`               | Enables slot; defaults to `true`.                        |
| `service_plan_id`           | `string`             | Overrides main service plan ID for slot (optional).      |
| `logs`                      | `object`             | Slot-specific logs (file system or blob).                |
| `sticky_settings`           | `object`             | Slot-specific sticky settings.                           |
| `backup`                    | `object`             | Slot-specific backup config (see above).                 |




- [✅ Validation Summary (Grouped)](#validation-summary-grouped)

The module enforces over **200 validation rules** across its configuration to ensure secure, consistent, and correct deployment of the Azure Linux Web App and related resources. These are grouped by category below:

#### 🔧 General Requirements
- `name`, `resource_group_name`, `location`, `site_config` must be non-empty; `name` must be 2–64 characters, alphanumeric with dashes only.
- Either `service_plan` or `service_plan_id` must be provided (mutually exclusive), with `service_plan_id` matching Azure resource ID format.
- `virtual_network_subnet_id` must be a valid subnet ID and match the resource group’s region if provided.
- Tag keys must be non-empty, 1–512 characters, alphanumeric with spaces/hyphens/underscores; values max 256 characters.
- Slot names must be unique, 1–59 characters, distinct from the main app name, and alphanumeric with dashes.

#### 👤 Identity Configuration
- `identity.type` must be `SystemAssigned`, `UserAssigned`, or `SystemAssigned, UserAssigned`.
- `identity_ids` required if `type` includes `UserAssigned`, must be valid resource IDs, and disallowed otherwise.
- Applies to both main app and slot `identity` configurations.

#### 🔒 Authentication – Easy Auth v1
- `default_provider` must be a valid provider (e.g., `AzureActiveDirectory`, `Facebook`).
- `unauthenticated_client_action` must be `RedirectToLoginPage` or `AllowAnonymous`.
- `default_provider` required if multiple providers are set with `RedirectToLoginPage`.
- Provider-specific fields (e.g., `client_id`, `app_id`, `consumer_key`) must be non-empty; secrets (`client_secret`, `client_secret_setting_name`) are mutually exclusive.
- `allowed_audiences` must be valid URLs.

#### 🔐 Authentication – Easy Auth v2
- `default_provider` must be from supported list (e.g., `AzureActiveDirectory`, `Google`); `unauthenticated_action` limited to `RedirectToLoginPage`, `AllowAnonymous`.
- `forward_proxy_convention` (`NoProxy`, `Standard`, `Custom`), `cookie_expiration_convention` (`FixedTime`, `IdentityProviderDerived`) must be valid.
- `cookie_expiration_time`, `nonce_expiration_time` must be `hh:mm:ss` format; required/disallowed based on `cookie_expiration_convention`.
- `require_authentication` true requires `unauthenticated_action` as `RedirectToLoginPage`.
- `active_directory_v2.client_id` required; `tenant_auth_endpoint` must be a valid Azure AD URL; secrets mutually exclusive.
- `identity_providers` providers must be valid (e.g., `Apple`, `OpenIDConnect`); custom OIDC names unique.

#### 🌐 Site Configuration
- Enum fields (e.g., `ftps_state`: `AllAllowed`, `FtpsOnly`, `Disabled`; `minimum_tls_version`: `1.0`, `1.1`, `1.2`) must match allowed values.
- `always_on` must be `false` for Free/Shared SKUs; required `true` with `health_check_path`.
- `health_check_eviction_time_in_min` (2–10) requires `health_check_path`; `health_check_path` must start with `/`.
- `vnet_route_all_enabled` requires `virtual_network_subnet_id`; `http2_enabled`, `use_32_bit_worker` must be booleans.
- `number_of_workers` (1–20); `default_documents` non-empty; `api_definition_url` HTTPS-only; `api_management_api_id` valid resource ID.
- `app_command_line` requires `linux_fx_version`.

#### 💻 Application Stack
- Valid versions enforced: `dotnet_version` (`3.1`, `5.0`, `6.0`, `7.0`, `8.0`), `python_version` (`3.7`–`3.11`), `node_version` (`12-lts`–`22-lts`), etc.
- `use_dotnet_isolated_runtime` restricted to .NET 6.0+; `node_version` and `java_version` mutually exclusive.
- `docker_image_name` requires `docker_registry_url`; `java_server` limited to `JAVA`, `TOMCAT`, `JBOSSEAP`.
- Applies to main app and slots.

#### 🔐 IP Restrictions
- Exactly one of `ip_address`, `service_tag`, or `virtual_network_subnet_id` per rule; `action` must be `Allow` or `Deny`.
- `priority` (100–65535) must be unique across rules; max 512 rules per `ip_restriction`.
- `headers` requires at least one non-empty list (e.g., `x_forwarded_for`, `x_azure_fdid`); specific formats enforced (IP/CIDR, GUIDs, hostnames).
- Applies to `site_config.ip_restriction` and `scm_ip_restriction` (main and slots).

#### ⚙️ Sticky Settings
- At least one of `app_setting_names` or `connection_string_names` required; entries must be non-empty and unique.
- Names must exist in `app_settings` or `connection_string`; no overlap between lists.
- Applies to main app and slots.

#### 🔁 Backup Configuration
- `name`, `storage_account_url`, `schedule` required; `frequency_unit` (`Day`, `Hour`), `frequency_interval` (1–720 hours or 1–30 days).
- `retention_period_days` ≥ 0; `start_time` RFC3339 format, future date relative to March 31, 2025.
- Supported only on Standard, Premium, Isolated SKUs.

#### 📜 App Settings & Connection Strings
- `app_settings` keys non-empty (max 255 chars), values non-empty (max 4096 chars), total size ≤ 100KB.
- `connection_string` names unique across app and slots (max 255 chars), values non-empty (max 4096 chars), `type` from valid list (e.g., `SQLAzure`).

#### 🧪 Logs
- `application_logs.file_system_level`, `azure_blob_storage.level` must be `Verbose`, `Information`, `Warning`, or `Error`.
- Blob storage requires `sas_url` (HTTPS) and `retention_in_days` (≥ 0); file system requires `retention_in_mb` (> 0) and `retention_in_days` (≥ 0).
- Applies to main app and slot logs.

#### 📦 Storage Accounts
- `type` must be `AzureFiles` or `AzureBlob`; max 5 mounts.
- `name` (3–63 chars, alphanumeric/dashes), `account_name` (3–24 chars), `access_key` (min 30 chars), `share_name` (max 63 chars) non-empty.
- `mount_path` starts with `/`, unique if specified.

#### 🧩 Deployment Slots
- Max 20 slots; names unique, 1–59 chars, distinct from main app name.
- Same validations as main app for `identity`, `site_config`, `application_stack`, `ip_restriction`, etc.
- `service_plan_id` optional, must be valid resource ID; slots inherit main `virtual_network_subnet_id`.

#### 🏷️ Tags
- Keys non-empty, 1–512 chars, alphanumeric with spaces/hyphens/underscores; values max 256 chars.
- Applies to top-level `tags` and resource-specific `tags`.

#### ⏱️ Timeouts
- `create`, `update`, `delete` must be in format `Xs`, `Xm`, `Xh`, or `Xd`, max 7200 seconds (2 hours).



- [✅ Validation Summary (Full List)](#validation-summary-full-list)

The module enforces over **200 individual validation rules** to ensure correct configuration. Below is the full list:

| #   | Scope                             | Field(s)                                                                                   | Validation Purpose                                                     | Key Logic or Pattern                                  |
|-----|-----------------------------------|--------------------------------------------------------------------------------------------|------------------------------------------------------------------------|-------------------------------------------------------|
| 1   | General                          | `web_app_config.name`, `resource_group_name`, `location`, `site_config`                    | Ensure required fields are non-empty                                           | Non-empty string check                                |
| 2   | General                          | `web_app_config.service_plan`, `service_plan_id`                                           | Must provide exactly one of `service_plan` or `service_plan_id`                | Mutual exclusivity                                    |
| 3   | General                          | `web_app_config.name`                                                                      | Must be 2–64 characters                                                        | Length check                                          |
| 4   | General                          | `web_app_config.name`                                                                      | Must be alphanumeric with dashes only                                          | `^[a-zA-Z0-9-]+$`                                     |
| 5   | General                          | `web_app_config.service_plan_id`                                                           | Must be a valid App Service Plan resource ID                                   | `^/subscriptions/.*/serverfarms/.+$`                  |
| 6   | General                          | `web_app_config.virtual_network_subnet_id`                                                 | Must be a valid subnet resource ID if provided                                 | `^/subscriptions/.*/subnets/.*$`                      |
| 7   | General                          | `web_app_config.virtual_network_subnet_id`                                                 | Must match resource group for regional consistency                            | Contains `resource_group_name`                        |
| 8   | General                          | `web_app_config.zip_deploy_file`                                                           | Must be a `.zip` file if provided                                              | `.*\.zip$`                                            |
| 9   | General                          | `web_app_config.zip_deploy_file` with `app_settings`                                       | Requires `WEBSITE_RUN_FROM_PACKAGE=1` or `SCM_DO_BUILD_DURING_DEPLOYMENT=true` | Conditional app settings check                        |
| 10  | General                          | `web_app_config.webdeploy_publish_basic_authentication_enabled` with `zip_deploy_file`     | Disallowed with `zip_deploy_file` if `true`                                    | Mutual exclusivity                                    |
| 11  | Identity                         | `identity.type`                                                                            | Must be `SystemAssigned`, `UserAssigned`, or `SystemAssigned, UserAssigned`    | Static list check                                     |
| 12  | Identity                         | `identity.identity_ids`                                                                    | Required if `type` includes `UserAssigned`                                     | Conditional presence                                  |
| 13  | Identity                         | `identity.identity_ids`                                                                    | Disallowed unless `type` includes `UserAssigned`                               | Cross-check logic                                     |
| 14  | Identity                         | `identity.identity_ids`                                                                    | Must be valid user-assigned identity resource IDs                              | `^/subscriptions/.*/userAssignedIdentities/.*$`       |
| 15  | Identity                         | `slots[].identity.type`                                                                    | Must be `SystemAssigned`, `UserAssigned`, or `SystemAssigned, UserAssigned`    | Static list check                                     |
| 16  | Identity                         | `slots[].identity.identity_ids`                                                            | Required if slot `type` includes `UserAssigned`                                | Conditional presence                                  |
| 17  | Identity                         | `slots[].identity.identity_ids`                                                            | Disallowed unless slot `type` includes `UserAssigned`                          | Cross-check logic                                     |
| 18  | Auth v1                          | `auth_settings.default_provider`                                                           | Must be a valid provider (e.g., `AzureActiveDirectory`)                        | Static list check                                     |
| 19  | Auth v1                          | `auth_settings.unauthenticated_client_action`                                              | Must be `RedirectToLoginPage` or `AllowAnonymous`                              | Static list check                                     |
| 20  | Auth v1                          | `auth_settings.default_provider`                                                           | Required if multiple providers with `RedirectToLoginPage`                      | Conditional count + null check                        |
| 21  | Auth v1                          | `auth_settings.active_directory.client_id`                                                 | Required if Azure AD configured                                                | Non-empty check                                       |
| 22  | Auth v1                          | `auth_settings.facebook.app_id`                                                            | Required if Facebook configured                                                | Non-empty check                                       |
| 23  | Auth v1                          | `auth_settings.github.client_id`                                                           | Required if GitHub configured                                                  | Non-empty check                                       |
| 24  | Auth v1                          | `auth_settings.google.client_id`                                                           | Required if Google configured                                                  | Non-empty check                                       |
| 25  | Auth v1                          | `auth_settings.microsoft.client_id`                                                        | Required if Microsoft configured                                               | Non-empty check                                       |
| 26  | Auth v1                          | `auth_settings.twitter.consumer_key`                                                       | Required if Twitter configured                                                 | Non-empty check                                       |
| 27  | Auth v1                          | `auth_settings.active_directory.client_secret`, `client_secret_setting_name`               | Mutually exclusive for Azure AD                                                | Mutual exclusivity                                    |
| 28  | Auth v1                          | `auth_settings.active_directory.allowed_audiences`                                         | Must be valid URLs if provided                                                 | `^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$`          |
| 29  | Auth v2                          | `auth_settings_v2.default_provider`                                                        | Must be valid (e.g., `AzureActiveDirectory`, `Google`)                         | Static list check                                     |
| 30  | Auth v2                          | `auth_settings_v2.unauthenticated_action`                                                  | Must be `RedirectToLoginPage` or `AllowAnonymous`                              | Static list check                                     |
| 31  | Auth v2                          | `auth_settings_v2.require_authentication`, `unauthenticated_action`                        | `RedirectToLoginPage` required if `require_authentication` true                | Conditional logic                                     |
| 32  | Auth v2                          | `auth_settings_v2.forward_proxy_convention`                                                | Must be `NoProxy`, `Standard`, or `Custom`                                     | Static list check                                     |
| 33  | Auth v2                          | `auth_settings_v2.cookie_expiration_convention`                                            | Must be `FixedTime` or `IdentityProviderDerived`                               | Static list check                                     |
| 34  | Auth v2                          | `auth_settings_v2.cookie_expiration_time`                                                  | Required if `cookie_expiration_convention` is `FixedTime`                      | Conditional logic                                     |
| 35  | Auth v2                          | `auth_settings_v2.cookie_expiration_time`                                                  | Disallowed if `cookie_expiration_convention` is `IdentityProviderDerived`      | Conditional logic                                     |
| 36  | Auth v2                          | `auth_settings_v2.cookie_expiration_time`, `nonce_expiration_time`                         | Must be `hh:mm:ss` format                                                      | `^[0-9]{2}:[0-9]{2}:[0-9]{2}$`                       |
| 37  | Auth v2                          | `auth_settings_v2.active_directory_v2.client_id`                                           | Required if Azure AD v2 configured                                             | Non-empty check                                       |
| 38  | Auth v2                          | `auth_settings_v2.active_directory_v2.tenant_auth_endpoint`                                | Must be valid Azure AD endpoint if provided                                    | `^https://login.microsoftonline.com/.*/v2.0$`        |
| 39  | Auth v2                          | `auth_settings_v2.active_directory_v2.client_secret_certificate_thumbprint`                | Must be 40-char hex if provided                                                | `^[0-9a-fA-F]{40}$`                                  |
| 40  | Auth v2                          | `auth_settings_v2.identity_providers[].provider`                                           | Must be valid (e.g., `Apple`, `OpenIDConnect`)                                 | Static list check                                     |
| 41  | Auth v2                          | `auth_settings_v2.identity_providers[].openid_configuration_endpoint`                       | Must be HTTPS URL if provided                                                  | `^https://.*$`                                        |
| 42  | Auth v2                          | `auth_settings_v2.login.token_store_path`                                                  | Must start with `/` if provided                                                | `^/.*$`                                               |
| 43  | Auth v2                          | `auth_settings_v2.login.token_store_sas_setting_name`                                      | Must be non-empty if provided                                                  | Trim check                                            |
| 44  | Auth v2                          | `auth_settings_v2.login.allowed_external_redirect_urls`                                    | Must be valid URLs if provided                                                 | `^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$`          |
| 45  | Auth v2                          | `auth_settings_v2.login.logout_endpoint`                                                   | Must be valid relative path if provided                                        | `^/[a-zA-Z0-9._~-]+$`                                 |
| 46  | Site Config                      | `site_config.minimum_tls_version`, `scm_minimum_tls_version`                               | Must be `1.0`, `1.1`, or `1.2`                                                | Static list check                                     |
| 47  | Site Config                      | `site_config.load_balancing_mode`                                                          | Must be valid (e.g., `WeightedRoundRobin`, `LeastRequests`)                    | Static list check                                     |
| 48  | Site Config                      | `site_config.ftps_state`                                                                   | Must be `AllAllowed`, `FtpsOnly`, or `Disabled`                                | Static list check                                     |
| 49  | Site Config                      | `site_config.number_of_workers`                                                            | Must be 1–20 if provided                                                       | Range check                                           |
| 50  | Site Config                      | `site_config.remote_debugging_version`                                                     | Must be `VS2012`, `VS2013`, `VS2015`, or `VS2017`                             | Static list check                                     |
| 51  | Site Config                      | `site_config.default_documents`                                                            | Entries must be non-empty if provided                                          | Trim + list check                                     |
| 52  | Site Config                      | `site_config.api_management_api_id`                                                        | Must be valid API Management resource ID                                       | `^/subscriptions/.*/apis/.+$`                         |
| 53  | Site Config                      | `site_config.api_definition_url`                                                           | Must start with `https://` if provided                                         | `^https://.*$`                                        |
| 54  | Site Config                      | `site_config.always_on` with `service_plan.sku_name`                                       | Must be `false` for Free/Shared SKUs (`F1`, `D1`, `Y1`)                        | Conditional logic                                     |
| 55  | Site Config                      | `site_config.always_on` with `health_check_path`                                   | Must be `true` if `health_check_path` set                                      | Conditional logic                                     |
| 56  | Site Config                      | `site_config.health_check_eviction_time_in_min`                                            | Must be 2–10 if provided, requires `health_check_path`                         | Range + conditional check                             |
| 57  | Site Config                      | `site_config.health_check_path`                                                            | Must start with `/` if provided                                                | `^/.*$`                                               |
| 58  | Site Config                      | `site_config.vnet_route_all_enabled`                                                       | Requires `virtual_network_subnet_id` if `true`                                 | Conditional logic                                     |
| 59  | Site Config                      | `site_config.http2_enabled`                                                                | Must be boolean                                                                | Static check                                          |
| 60  | Site Config                      | `site_config.managed_pipeline_mode`                                                        | Must be `Integrated` or `Classic`                                              | Static list check                                     |
| 61  | Site Config                      | `site_config.container_registry_managed_identity_client_id`                                | Requires `container_registry_use_managed_identity` true                        | Conditional logic                                     |
| 62  | Site Config                      | `site_config.use_32_bit_worker` with `service_plan.sku_name`                               | Disallowed with PremiumV3 SKUs (`P1v3`, `P2v3`, `P3v3`)                        | Conditional logic                                     |
| 63  | App Stack                        | `site_config.application_stack.dotnet_version`                                             | Must be `3.1`, `5.0`, `6.0`, `7.0`, or `8.0`                                  | Static list check                                     |
| 64  | App Stack                        | `site_config.application_stack.use_dotnet_isolated_runtime`                                | Requires `dotnet_version` 6.0+                                                 | Conditional logic                                     |
| 65  | App Stack                        | `site_config.application_stack.python_version`                                             | Must be `3.7`, `3.8`, `3.9`, `3.10`, or `3.11`                                | Static list check                                     |
| 66  | App Stack                        | `site_config.application_stack.php_version`                                                | Must be `7.4`, `8.0`, `8.1`, `8.2`, or `8.3`                                  | Static list check                                     |
| 67  | App Stack                        | `site_config.application_stack.node_version`                                               | Must be `12-lts`, `14-lts`, `16-lts`, `18-lts`, `20-lts`, or `22-lts`         | Static list check                                     |
| 68  | App Stack                        | `site_config.application_stack.java_version`                                               | Must be `8`, `11`, `17`, or `21`                                               | Static list check                                     |
| 69  | App Stack                        | `site_config.application_stack.java_server`                                                | Must be `JAVA`, `TOMCAT`, or `JBOSSEAP`                                        | Static list check                                     |
| 70  | App Stack                        | `site_config.application_stack.ruby_version`                                               | Must be `2.7`                                                                  | Static list check                                     |
| 71  | App Stack                        | `site_config.application_stack.go_version`                                                 | Must be `1.18` or `1.19`                                                       | Static list check                                     |
| 72  | App Stack                        | `site_config.application_stack.node_version`, `java_version`                               | Mutually exclusive                                                             | Mutual exclusivity                                    |
| 73  | App Stack                        | `site_config.application_stack.docker_image_name`                                          | Requires `docker_registry_url`                                                 | Conditional logic                                     |
| 74  | App Stack                        | `site_config.application_stack.docker_registry_username`                                   | Must be non-empty if provided                                                  | Trim check                                            |
| 75  | Site Config                      | `site_config.app_command_line`                                                             | Requires `linux_fx_version`                                                    | Conditional logic                                     |
| 76  | Site Config                      | `site_config.linux_fx_version`                                                             | Must start with `DOCKER|`, `JAVA|`, `NODE|`, or `PYTHON|`                      | `^(DOCKER|JAVA|NODE|PYTHON)\|.*$`                     |
| 77  | IP Restriction                   | `site_config.ip_restriction`                                                               | Max 512 rules                                                                  | Length check                                          |
| 78  | IP Restriction                   | `site_config.ip_restriction[].ip_address`, `service_tag`, `virtual_network_subnet_id`      | Exactly one must be set per rule                                               | Sum check                                             |
| 79  | IP Restriction                   | `site_config.ip_restriction[].action`                                                      | Must be `Allow` or `Deny` if provided                                          | Static list check                                     |
| 80  | IP Restriction                   | `site_config.ip_restriction[].priority`                                                    | Must be 100–65535 if provided, unique across rules                             | Range + distinct check                                |
| 81  | IP Restriction                   | `site_config.ip_restriction[].headers`                                                     | At least one list (e.g., `x_forwarded_for`) must be non-empty if provided      | Nested list presence check                            |
| 82  | IP Restriction                   | `site_config.scm_ip_restriction[].headers.x_forwarded_for`                                 | Must be valid IP/CIDR if provided                                              | `^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?$`        |
| 83  | IP Restriction                   | `site_config.scm_ip_restriction[].headers.x_forwarded_host`                                | Must be valid hostname if provided                                             | `^[a-zA-Z0-9.-]+$`                                    |
| 84  | IP Restriction                   | `site_config.scm_ip_restriction[].headers.x_azure_fdid`                                    | Must be valid GUID if provided                                                 | `^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-.*$`                 |
| 85  | IP Restriction                   | `site_config.scm_ip_restriction_default_action`                                            | Must be `Allow` or `Deny` if provided                                          | Static list check                                     |
| 86  | IP Restriction                   | `site_config.scm_ip_restriction[].action`                                                  | Must be `Allow` or `Deny` if provided                                          | Static list check                                     |
| 87  | IP Restriction                   | `site_config.scm_ip_restriction[].ip_address`, `service_tag`, `virtual_network_subnet_id`  | Exactly one must be set per rule                                               | Sum check                                             |
| 88  | Auto Heal                        | `site_config.auto_heal_setting.actions.action_type`                                        | Must be `Recycle`, `LogEvent`, or `CustomAction`                               | Static list check                                     |
| 89  | Auto Heal                        | `site_config.auto_heal_setting.triggers`                                                   | At least one trigger (`slow_request`, `status_code`, `requests`) required      | Presence check                                        |
| 90  | Auto Heal                        | `site_config.auto_heal_setting.triggers.status_code[].status_code_range`                   | Must be `xxx-yyy` format                                                       | `^[0-9]{3}-[0-9]{3}$`                                 |
| 91  | Auto Heal                        | `site_config.auto_heal_setting.triggers.slow_request.time_taken`                           | Must be `Xs`, `Xm`, or `Xh` format                                             | `^[0-9]+[smh]$`                                       |
| 92  | Auto Heal                        | `site_config.auto_heal_setting.triggers.slow_request.count`                                | Must be positive                                                               | `> 0`                                                 |
| 93  | Auto Heal                        | `site_config.auto_heal_setting.triggers.requests.interval`                                 | Must be `Xs`, `Xm`, or `Xh` format                                             | `^[0-9]+[smh]$`                                       |
| 94  | Auto Heal                        | `site_config.auto_heal_setting.triggers.requests.count`                                    | Must be positive                                                               | `> 0`                                                 |
| 95  | Auto Heal                        | `site_config.auto_heal_setting.triggers.status_code[].interval`                            | Must be `Xs`, `Xm`, or `Xh` format                                             | `^[0-9]+[smh]$`                                       |
| 96  | Auto Heal                        | `site_config.auto_heal_setting.triggers.status_code[].count`                               | Must be positive                                                               | `> 0`                                                 |
| 97  | Auto Heal                        | `site_config.auto_heal_setting.triggers.status_code[].path`                                | Must start with `/` if provided                                                | `^/.*$`                                               |
| 98  | Auto Heal                        | `site_config.auto_heal_setting.triggers.status_code[].sub_status`                          | Must be 0–999 if provided                                                      | Range check                                           |
| 99  | Auto Heal                        | `site_config.auto_heal_setting.triggers.status_code[].win32_status_code`                   | Must be 0–4294967295 if provided                                               | Range check                                           |
| 100 | Auto Heal                        | `site_config.auto_heal_setting.actions.minimum_process_execution_time`                     | Must be `hh:mm:ss` format if provided                                          | `^[0-9]{2}:[0-9]{2}:[0-9]{2}$`                       |
| 101 | Auto Heal                        | `site_config.auto_heal_enabled` with `auto_heal_setting`                                   | `auto_heal_setting` required if `auto_heal_enabled` true                       | Conditional logic                                     |
| 102 | CORS                             | `site_config.cors.allowed_origins`                                                         | Must have at least one entry if provided                                       | Length check                                          |
| 103 | CORS                             | `site_config.cors.allowed_origins`                                                         | Entries must be valid URLs or hostnames                                        | `^(https?://)?[a-zA-Z0-9.-]+(:[0-9]+)?$`             |
| 104 | Backup                           | `backup.schedule.frequency_unit`                                                           | Must be `Day` or `Hour`                                                        | Static list check                                     |
| 105 | Backup                           | `backup.schedule.frequency_interval`                                                       | Must be 1–720 for `Hour`, 1–30 for `Day`                                       | Range check                                           |
| 106 | Backup                           | `backup.schedule.retention_period_days`                                                    | Must be ≥ 0 if provided                                                        | Numeric check                                         |
| 107 | Backup                           | `backup.schedule.start_time`                                                               | Must be RFC3339 format, future date                                            | `^[0-9]{4}-[0-9]{2}-[0-9]{2}T.*Z$` + timestamp      |
| 108 | Backup                           | `backup.name`, `schedule`, `storage_account_url`                                           | Required if `backup` defined                                                   | Presence check                                        |
| 109 | Backup                           | `backup` with `service_plan.sku_name`                                                      | Supported only on Standard, Premium, Isolated SKUs                             | Static list check                                     |
| 110 | Client Cert                      | `client_certificate_enabled`, `client_certificate_mode`                                    | `client_certificate_mode` required if `client_certificate_enabled` true        | Conditional logic                                     |
| 111 | Client Cert                      | `client_certificate_mode`                                                                  | Must be `Required`, `Optional`, or `OptionalInteractiveUser`                   | Static list check                                     |
| 112 | Client Cert                      | `client_certificate_mode`                                                                  | Disallowed unless `client_certificate_enabled` true                            | Cross-check logic                                     |
| 113 | Client Cert                      | `client_certificate_exclusion_paths`                                                       | Must be valid path format if provided                                          | `^(/[a-zA-Z0-9._~-]+)+$`                             |
| 114 | Client Cert                      | `client_certificate_exclusion_paths`                                                       | Max 50 comma-separated paths                                                   | Length check                                          |
| 115 | Connection String                | `connection_string[].name`                                                                 | Must be non-empty, max 255 chars                                               | Trim + length check                                   |
| 116 | Connection String                | `connection_string[].value`                                                                | Must be non-empty, max 4096 chars                                              | Trim + length check                                   |
| 117 | Connection String                | `connection_string[].type`                                                                 | Must be valid (e.g., `SQLAzure`, `Custom`)                                     | Static list check                                     |
| 118 | Connection String                | `connection_string[].name`                                                                 | Must be unique across main app and slots                                       | `distinct(...)`                                       |
| 119 | Slots                            | `slots[].name`                                                                             | Must not match main app name                                                   | Equality check                                        |
| 120 | Slots                            | `slots[].name`                                                                             | Must be unique                                                                 | `distinct(...)`                                       |
| 121 | Slots                            | `slots[].name`                                                                             | Must be 1–59 chars, alphanumeric with dashes                                   | Length + `^[a-zA-Z0-9-]+$`                            |
| 122 | Slots                            | `slots[].app_settings`                                                                     | Keys must be unique, non-empty                                                 | `distinct(...)` + trim check                          |
| 123 | Slots                            | `slots[].app_settings`                                                                     | Values must be non-empty                                                       | Trim check                                            |
| 124 | Slots                            | `slots[].site_config.ip_restriction[].ip_address`, `service_tag`, `virtual_network_subnet_id` | Exactly one must be set per rule                                             | Sum check                                             |
| 125 | Slots                            | `slots[].site_config.ip_restriction[].action`                                              | Must be `Allow` or `Deny` if provided                                          | Static list check                                     |
| 126 | Slots                            | `slots[].site_config.ip_restriction[].priority`                                            | Must be 100–65535 if provided                                                  | Range check                                           |
| 127 | Slots                            | `slots[].site_config.ip_restriction[].headers`                                             | At least one list must be non-empty if provided                                | Nested list presence check                            |
| 128 | Slots                            | `slots[].site_config.auto_heal_setting.actions.action_type`                                | Must be `Recycle`, `LogEvent`, or `CustomAction`                               | Static list check                                     |
| 129 | Slots                            | `slots[].site_config.application_stack.node_version`, `java_version`                       | Mutually exclusive                                                             | Mutual exclusivity                                    |
| 130 | Slots                            | `slots[].logs.application_logs.file_system_level`                                          | Must be set if block exists                                                    | Presence check                                        |
| 131 | Slots                            | `slots[].logs.application_logs.azure_blob_storage.level`                                   | Must be `Verbose`, `Information`, `Warning`, or `Error`                        | Static list check                                     |
| 132 | Slots                            | `slots`                                                                                    | Max 20 slots                                                                   | Length check                                          |
| 133 | Slots                            | `slots[].service_plan_id`                                                                  | Must be valid resource ID if provided                                          | `^/subscriptions/.*/serverfarms/.+$`                  |
| 134 | Slots                            | `slots[].virtual_network_subnet_id`                                                        | Must match main app’s `virtual_network_subnet_id` or be null                   | Equality check                                        |
| 135 | Service Plan                     | `service_plan.os_type`                                                                     | Must be `Linux`                                                                | Static check                                          |
| 136 | Service Plan                     | `service_plan.sku_name`                                                                    | Must be valid Azure SKU (e.g., `S1`, `P1v3`)                                  | Static list check                                     |
| 137 | Service Plan                     | `service_plan.worker_count`                                                                | Must be ≥ 1 if provided                                                        | Numeric check                                         |
| 138 | Service Plan                     | `service_plan.app_service_environment_id`                                                  | Requires Isolated SKU (e.g., `I1v2`)                                           | Conditional logic                                     |
| 139 | Service Plan                     | `service_plan.zone_balancing_enabled`                                                      | Requires Premium V3/Elastic SKU and even `worker_count`                        | Conditional logic                                     |
| 140 | Service Plan                     | `service_plan.maximum_elastic_worker_count`                                                | Requires Elastic/Premium SKU with auto-scale                                   | Conditional logic                                     |
| 141 | Tags                             | `tags` keys                                                                                | Must be non-empty, 1–512 chars, alphanumeric with spaces/hyphens/underscores   | Trim + length + `^[a-zA-Z0-9-_ ]+$`                   |
| 142 | Tags                             | `tags` values                                                                              | Max 256 chars                                                                  | Length check                                          |
| 143 | Tags                             | `slots[].tags` keys                                                                        | Same as top-level `tags`                                                       | Trim + length + `^[a-zA-Z0-9-_ ]+$`                   |
| 144 | Logs                             | `logs.application_logs.file_system_level`                                                  | Must be `Verbose`, `Information`, `Warning`, or `Error`                        | Static list check                                     |
| 145 | Logs                             | `logs.application_logs.azure_blob_storage.level`                                           | Must be `Verbose`, `Information`, `Warning`, or `Error`                        | Static list check                                     |
| 146 | Logs                             | `logs.application_logs.azure_blob_storage.sas_url`, `retention_in_days`                    | Both required if block defined                                                 | Pair presence check                                   |
| 147 | Logs                             | `logs.application_logs.azure_blob_storage.retention_in_days`                               | Must be ≥ 0                                                                    | Numeric check                                         |
| 148 | Logs                             | `logs.http_logs.azure_blob_storage.sas_url`, `retention_in_days`                           | Both required if block defined                                                 | Pair presence check                                   |
| 149 | Logs                             | `logs.http_logs.azure_blob_storage.retention_in_days`                                      | Must be ≥ 0                                                                    | Numeric check                                         |
| 150 | Logs                             | `logs.http_logs.file_system.retention_in_mb`, `retention_in_days`                          | Both required if block defined                                                 | Pair presence check                                   |
| 151 | Logs                             | `logs.http_logs.file_system.retention_in_days`, `retention_in_mb`                          | Must be ≥ 0 and > 0 respectively                                               | Range check                                           |
| 152 | Logs                             | `logs.http_logs.azure_blob_storage.sas_url`                                                | Must start with `https://`                                                     | `^https://.*$`                                        |
| 153 | Sticky Settings                  | `sticky_settings.app_setting_names`, `connection_string_names`                             | At least one must be set if block defined                                      | Presence check                                        |
| 154 | Sticky Settings                  | `sticky_settings.app_setting_names`, `connection_string_names`                             | Must be unique, no overlap                                                     | `distinct(...)`                                       |
| 155 | Sticky Settings                  | `sticky_settings.app_setting_names`                                                        | Must exist in `app_settings`                                                   | Cross-reference                                       |
| 156 | Sticky Settings                  | `sticky_settings.connection_string_names`                                                  | Must exist in `connection_string`                                              | Cross-reference                                       |
| 157 | Sticky Settings                  | `sticky_settings.app_setting_names`                                                        | Entries must be non-empty                                                      | Trim check                                            |
| 158 | Sticky Settings                  | `sticky_settings.connection_string_names`                                                  | Entries must be non-empty                                                      | Trim check                                            |
| 159 | Sticky Settings                  | `slots[].sticky_settings.app_setting_names`, `connection_string_names`                     | At least one must be set if block defined                                      | Presence check                                        |
| 160 | Storage Account                  | `storage_account`                                                                          | Max 5 entries                                                                  | Length check                                          |
| 161 | Storage Account                  | `storage_account[].type`                                                                   | Must be `AzureFiles` or `AzureBlob`                                            | Static list check                                     |
| 162 | Storage Account                  | `storage_account[].name`, `account_name`, `access_key`, `share_name`, `type`               | Must be non-empty if block defined                                             | Trim check                                            |
| 163 | Storage Account                  | `storage_account[].mount_path`                                                             | Must start with `/` if provided, unique                                        | `^/.*$` + distinct check                              |
| 164 | Storage Account                  | `storage_account[].name`                                                                   | Must be 3–63 chars, lowercase alphanumeric/dashes                              | Length + `^[a-z0-9](?!.*--)[a-z0-9-]{1,61}[a-z0-9]$` |
| 165 | Storage Account                  | `storage_account[].account_name`                                                           | Must be 3–24 chars                                                             | Length check                                          |
| 166 | Storage Account                  | `storage_account[].share_name`                                                             | Max 63 chars                                                                   | Length check                                          |
| 167 | Storage Account                  | `storage_account[].access_key`                                                             | Min 30 chars                                                                   | Length check                                          |
| 168 | App Settings                     | `app_settings` keys                                                                        | Must be non-empty, max 255 chars                                               | Trim + length check                                   |
| 169 | App Settings                     | `app_settings` values                                                                      | Must be non-empty, max 4096 chars                                              | Trim + length check                                   |
| 170 | App Settings                     | `app_settings`                                                                             | Total size ≤ 100KB                                                             | Sum check                                             |
| 171 | General                          | `https_only`                                                                               | Must be boolean; warns if `false`                                              | Static check + warning                                |
| 172 | General                          | `client_affinity_enabled`                                                                  | Must be boolean                                                                | Static check                                          |
| 173 | General                          | `enabled`                                                                                  | Must be boolean                                                                | Static check                                          |
| 174 | General                          | `ftp_publish_basic_authentication_enabled`                                                 | Must be boolean; warns if `true`                                               | Static check + warning                                |
| 175 | General                          | `webdeploy_publish_basic_authentication_enabled`                                           | Must be boolean                                                                | Static check                                          |
| 176 | General                          | `public_network_access_enabled`                                                            | Requires `site_config` if `false`                                              | Conditional logic                                     |
| 177 | General                          | `key_vault_reference_identity_id`                                                          | Must be valid identity resource ID                                             | `^/subscriptions/.*/userAssignedIdentities/.*$`       |
| 178 | Timeouts                         | `timeouts.create`, `update`, `delete`                                                      | Must be `Xs`, `Xm`, `Xh`, or `Xd`, max 7200s                                   | `^[0-9]+[smhd]$` + calculated seconds                |


- [📤 Outputs - Azure Linux Web App Terraform Module](#outputs---azure-linux-web-app-terraform-module)

The module provides the following outputs for the Azure Linux Web App and its related resources:

| #   | Output Name                        | Description                                                              | Sensitive | Key Value or Logic                                                |
|-----|------------------------------------|--------------------------------------------------------------------------|-----------|-------------------------------------------------------------------|
| 1   | `web_app_id`                      | The ID of the primary Azure Linux Web App.                               | No        | `azurerm_linux_web_app.this.id`                                   |
| 2   | `web_app_name`                    | The name of the primary Azure Linux Web App.                             | No        | `azurerm_linux_web_app.this.name`                                 |
| 3   | `web_app_default_site_hostname`   | The default hostname of the primary Web App (e.g., `myapp.azurewebsites.net`). | No  | `azurerm_linux_web_app.this.default_hostname`                     |
| 4   | `web_app_default_site_url`        | The full URL of the default site (e.g., `https://myapp.azurewebsites.net`). | No     | `"https://${azurerm_linux_web_app.this.default_hostname}"`        |
| 5   | `web_app_identity`                | The managed identity block for the Web App (system or user-assigned).    | No        | `azurerm_linux_web_app.this.identity`                             |
| 6   | `web_app_identity_principal_id`   | The principal ID of the Web App’s managed identity, if assigned.          | No        | `try(azurerm_linux_web_app.this.identity[0].principal_id, null)`  |
| 7   | `web_app_identity_tenant_id`      | The tenant ID of the Web App’s managed identity, if assigned.             | No        | `try(azurerm_linux_web_app.this.identity[0].tenant_id, null)`     |
| 8   | `web_app_identity_ids`            | List of user-assigned identity IDs, if configured.                       | No        | `try(azurerm_linux_web_app.this.identity[0].identity_ids, null)`  |
| 9   | `web_app_outbound_ip_addresses`   | List of outbound IP addresses for the Web App.                           | No        | `azurerm_linux_web_app.this.outbound_ip_addresses`                |
| 10  | `web_app_possible_outbound_ip_addresses` | List of possible outbound IP addresses for the Web App.           | No        | `azurerm_linux_web_app.this.possible_outbound_ip_addresses`       |
| 11  | `web_app_client_certificate_enabled` | Indicates whether client certificates are enabled on the Web App.   | No        | `azurerm_linux_web_app.this.client_certificate_enabled`           |
| 12  | `web_app_slot_ids`                | Map of deployment slot names to their resource IDs.                      | No        | `{ for slot_name, slot in azurerm_linux_web_app_slot.this : slot_name => slot.id }` |
| 13  | `web_app_slot_hostnames`          | Map of deployment slot names to their default hostnames.                 | No        | `{ for slot_name, slot in azurerm_linux_web_app_slot.this : slot_name => slot.default_hostname }` |
| 14  | `vnet_integration_subnet_id`      | The subnet ID used for VNet integration, if configured.                  | No        | `try(azurerm_app_service_virtual_network_swift_connection.vnet_integration[0].subnet_id, null)` |
| 15  | `vnet_integration_enabled`        | Indicates if VNet integration is enabled.                                | No        | `length(azurerm_app_service_virtual_network_swift_connection.vnet_integration) > 0` |
| 16  | `web_app_site_credential`         | Site publishing credentials for FTP or WebDeploy (username/password).    | Yes       | `azurerm_linux_web_app.this.site_credential`                      |
| 17  | `web_app_slot_urls`               | Map of deployment slot names to their full HTTPS URLs.                   | No        | `{ for slot_name, slot in azurerm_linux_web_app_slot.this : slot_name => "https://${slot.default_hostname}" }` |
| 18  | `service_plan_id`                 | The ID of the App Service Plan used by the Web App.                      | No        | `var.web_app_config.service_plan != null ? azurerm_service_plan.this[0].id : var.web_app_config.service_plan_id` |
| 19  | `web_app_custom_domain_verification_id` | The custom domain verification ID for configuring custom domains.  | No        | `azurerm_linux_web_app.this.custom_domain_verification_id`        |
| 20  | `web_app_slot_site_credentials`   | Map of deployment slot names to their site publishing credentials.       | Yes       | `{ for slot_name, slot in azurerm_linux_web_app_slot.this : slot_name => slot.site_credential }` |
| 21  | `web_app_app_settings`            | The applied app settings for the primary Web App.                        | Yes       | `azurerm_linux_web_app.this.app_settings`                         |
| 22  | `resource_group_name`             | The resource group name containing the Web App.                          | No        | `var.web_app_config.resource_group_name`                          |
| 23  | `location`                        | The Azure region where the Web App is deployed.                          | No        | `var.web_app_config.location`                                     |
| 24  | `web_app_backup_config`           | The backup configuration details for the Web App, if configured.         | No        | `try(azurerm_linux_web_app.this.backup[0], null)`                 |
| 25  | `web_app_application_stack`       | The application stack configuration for the Web App.                     | No        | `try(azurerm_linux_web_app.this.site_config[0].application_stack[0], null)` |
| 26  | `web_app_connection_strings`      | The applied connection strings for the primary Web App.                  | Yes       | `azurerm_linux_web_app.this.connection_string`                    |
| 27  | `web_app_slot_app_settings`       | Map of deployment slot names to their applied app settings.              | Yes       | `{ for slot_name, slot in azurerm_linux_web_app_slot.this : slot_name => slot.app_settings }` |
| 28  | `web_app_slot_connection_strings` | Map of deployment slot names to their applied connection strings.        | Yes       | `{ for slot_name, slot in azurerm_linux_web_app_slot.this : slot_name => slot.connection_string }` |



- [📞 Support](#support)

For issues, please contact the **Blue Sentry Cloud TACE Team**.