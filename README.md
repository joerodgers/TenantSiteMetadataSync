# TenantSiteMetadataSync
 Synchronizes metadata about SharePoint Online and OneDrive for Business sites in a M365 tenant to a local SQL database.

### PowerShell Cmdlets
```
1. Import-MicrosoftGraphUsageAccountReportData
   a. Import-MicrosoftGraphUsageAccountReportData -ReportType OneDrive
   b. Import-MicrosoftGraphUsageAccountReportData -ReportType SharePoint
   c. Import-MicrosoftGraphUsageAccountReportData -ReportType SharePoint -ApiVersion "beta"  
   d. Import-MicrosoftGraphUsageAccountReportData -ReportType OneDrive -ApiVersion "beta"
   e. Import-MicrosoftGraphUsageAccountReportData -ReportType M365Group

2. Import-SiteMetadataFromTenantAdminList
   a. Import-SiteMetadataFromTenantAdminList -AdminList AggregatedSiteCollections
   b. Import-SiteMetadataFromTenantAdminList -AdminList AllSitesAggregatedSiteCollections

3. Import-DeletedSiteMetadataFromTenantAPI

4. Import-SiteMetadataFromTenantAPI
    a. Import-SiteMetadataFromTenantAPI
    b. Import-SiteMetadataFromTenantAPI -DetailedImport

5. Sync-DeletionStatus

6. Import-SensitivityLabel

7. Import-SiteCreationSources

8. Import-M365GroupOwnershipData

9. Start-SyncJobExecution

10. Stop-SyncJobExecution

```

## dbo.ConditionalAccessPolicyType Table

This table stores the Id and display name of the condition access policy applied to the SharePoint site. 

| Column Name | Column Type | Import Sources | Description |
| ----------- | ----------- | -------------- | ----------- |
| Id (PK) | int | N/A | Populated at database creation. |
| TypeName | nvarchar(50) | N/A | Populated at database creation. |

## dbo.GroupMetadata Table

This table stores metadata about all M365 groups in the tenant. 

| Column Name | Column Type | Import Sources | Description |
| ----------- | ----------- | -------------- | ----------- |
| GroupId (PK) | uniqueidentifier | 1.e | |
| DisplayName | nvarchar(255) | 1.e | |
| IsDeleted | bit | 1.e | |
| LastActivityDate | datetime2(7) | 1.e | |
| IsPublic | bit | 1.e | |
| MemberCount | int | 1.e | |
| ExternalMemberCount | int | 1.e | |
| MemberCount | int | 1.e | |
| ExchangeReceivedEmailCount | int | 1.e | |
| ExchangeReceivedEmailCount | int | 1.e | |
| SharePointActiveFileCount | int | 1.e | |
| SharePointTotalFileCount | int | 1.e | |
| YammerPostedMessageCount | int | 1.e | |
| YammerReadMessageCount | int | 1.e | |
| YammerLikedMessageCount | int | 1.e | |
| ExchangeMailboxTotalItemCount | int | 1.e | |
| ExchangeMailboxStorageUsed | int | 1.e | |
| SharePointTotalFileCount | bigint | 1.e | |

## dbo.GroupOwner Table

This table stores user principal names foreach O365 group owner. 

| Column Name | Column Type | Import Sources | Description |
| ----------- | ----------- | -------------- | ----------- |
| GroupId (PK) | uniqueidentifier | 8 | |
| UserPrincipalName | nvarchar(500) | 8 | |

## dbo.SensitivityLabel Table

This reference table stores the Id (GUID) and name of the published sensitivity labels.

| Column Name | Column Type | Import Sources | Description |
| ----------- | ----------- | -------------- | ----------- |
| Id (PK) | uniqueidentifier | 6 | |
| Label | nvarchar(100) | 6 | |

## dbo.SiteCreationSource Table

This reference table stores the Id (GUID) and name of the site creation sources.

| Column Name | Column Type | Import Sources | Description |
| ----------- | ----------- | -------------- | ----------- |
| Id (PK) | uniqueidentifier | 7 | |
| Source | nvarchar(50) | 7 | |


## dbo.SiteMetadata Table

This table stores the metadata about the site collections in SPO and OD4B tenant.

| Column Name | Column Type | Import Sources | Description |
| ----------- | ----------- | -------------- | ----------- |
| SiteId (PK) | uniqueidentifier | 1.b, 1.c, 2.a, 4.b | | 
| AnonymousLinkCount | int | 1.c | |
| CompanyLinkCount | int | 1.c | |
| ConditionalAccessPolicy | int | 2.b, 4.b | |
| CreatedBy | nvarchar(255) | 2.b | |
| DeletedBy | nvarchar(255) | 2.b | |
| DenyAddAndCustomizePages | nvarchar(50) | 4.a, 4.b | |
| FileViewedOrEdited | int | 2.a | |
| GroupId | uniqueidentifier | 2.a, 4.a, 4.b  |
| GuestLinkCount | int | 1.c | |
| HubSiteId | uniqueidentifier | 2.a, 4.a, 4.b | |
| Initiator | nvarchar(255) | 2.a  |
| IsGroupConnected | bit | 2.a  |
| IsTeamsConnected | bit | 2.a, 4.a, 4.b | |
| LastActivityOn | date | 1.a, 1.b, 1.c, 1.d, 2.a | |
| LastItemModifiedDate | datetime2(7) | 2.a, 4.a, 4.b  |
| LockState | nvarchar(50) | 4.a, 4.b | |
| MemberLinkCount | int | 1.c | |
| NumOfFiles | int | 1.a, 1.b, 1.c, 1.d, 2.a | |
| PagesVisited | int | 1.b, 1.c, 2.a | |
| PageViews | int | 1.b, 1.c, 2.a | |
| PWAEnabled | bit | 4.a, 4.b | |
| RelatedGroupId | uniqueidentifier | 4.b | |
| SensitivityLabel | uniqueidentifier | 1.c, 2.a, 4.b | |
| SharingCapability | nvarchar(50) | 4.a | |
| SiteCreationSource | uniqueidentifier | 2.a | |
| SiteOwnerEmail | nvarchar(255) | 2.b, 4.b | |
| SiteOwnerName | nvarchar(255) | 1.a, 1.b, 1.c, 1.d, 2.b, 4.b | |
| SiteUrl | nvarchar(450) | 3, 1.a, 1.b, 1.c, 1.d, 2.a, 2.b, 4.a, 4.b, 5 | |
| State | int | 2.a, 4.a, 4.b | |
| StorageQuota | bigint | 1.a, 1.b, 1.c, 1.d, 2.b, 4.a, 4.b | |
| StorageUsed | bigint | 1.a, 1.b, 1.c, 1.d, 2.a, 4.a, 4.b | |
| TemplateName |  nvarchar(255) | 2.b, 4.a, 4.b | |
| TimeCreated |  datetime2(7) | 2.b,  4.b, 5 | |
| TimeDeleted |  datetime2(7) | 3, 2.a | |
| Title | nvarchar(255) | 2.b, 4.a, 4.b | |

## dbo.SiteState Table

This reference table stores the Id (GUID) and name of the site state.

| Column Name | Column Type | Import Sources | Description |
| ----------- | ----------- | -------------- | ----------- |
| Id (PK) | int | N/A | Populated at database creation. |
| State | nvarchar(50) | N/A  | Populated at database creation. |

## dbo.SyncJob Table

This table basic status and execution timings being run by in the Start-TenantSiteMetadataSync.ps1 script.

| Column Name | Column Type | Import Sources | Description |
| ----------- | ----------- | -------------- | ----------- |
| Name |  nvarchar(100) | 9, 10 | |
| Started | smalldatetime | 9, 10 | |
| Finished | smalldatetime | 9, 10 | |
| LastFinished | smalldatetime | 9, 10 | |
| ErrorCount | int | 9, 10 | |
