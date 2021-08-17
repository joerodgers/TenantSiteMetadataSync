IF OBJECT_ID('dbo.proc_AddOrUpdateSiteMetadata', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_AddOrUpdateSiteMetadata
GO

CREATE PROCEDURE dbo.proc_AddOrUpdateSiteMetadata
    @SiteUrl                    nvarchar(450),
    @SiteId                     uniqueidentifier = NULL,
    @AnonymousLinkCount         int              = NULL,
    @CompanyLinkCount           int              = NULL,
    @ConditionalAccessPolicy    int              = NULL,
    @CreatedBy                  nvarchar(255)    = NULL,
    @DeletedBy                  nvarchar(255)    = NULL,
    @DenyAddAndCustomizePages   nvarchar(50)     = NULL,
    @FileViewedOrEdited         int              = NULL,
    @GroupId                    uniqueidentifier = NULL,
    @GuestLinkCount             int              = NULL,
    @HasLegalHold               bit              = NULL,
    @HubSiteId                  uniqueidentifier = NULL,
    @Initiator                  nvarchar(255)    = NULL,
    @IsGroupConnected           bit              = NULL,
    @IsTeamsConnected           bit              = NULL,
    @LastActivityOn             date             = NULL,
    @LastItemModifiedDate       datetime2(7)     = NULL,
    @LockState                  nvarchar(50)     = NULL,
    @MemberLinkCount            int              = NULL,
    @NumOfFiles                 int              = NULL, 
    @PagesVisited               int              = NULL,
    @PageViews                  int              = NULL,
    @PWAEnabled                 bit              = NULL,
    @SensitivityLabel           uniqueidentifier = NULL,
    @SharedInternallyFileCount  int              = NULL,
    @SharedExternallyyFileCount int              = NULL,
    @SharingCapability          nvarchar(50)     = NULL,
    @SiteCreationSource         uniqueidentifier = NULL,
    @SiteOwnerEmail             nvarchar(255)    = NULL,
    @SiteOwnerName              nvarchar(255)    = NULL,
    @State                      int              = NULL,
    @StorageQuota               bigint           = NULL, 
    @StorageUsed                bigint           = NULL,
    @StorageUsedPercentage      decimal(18, 0)   = NULL,
    @SyncedFileCount            int              = NULL,
    @TemplateName               nvarchar(255)    = NULL,
    @TimeCreated                datetime2(7)     = NULL,
    @TimeDeleted                datetime2(7)     = NULL,
    @Title                      nvarchar(255)    = NULL
AS
BEGIN
    
    -- remove trailing slash from SiteUrl
    IF RIGHT(@SiteUrl, 1) = '/'
    BEGIN
        SET @SiteUrl = SUBSTRING( @SiteUrl, 0, LEN(@SiteUrl))
    END

    -- lookup the SiteId value
    IF @SiteId IS NULL 
    BEGIN
        SELECT @SiteId = SiteId FROM dbo.SiteMetadata WHERE SiteUrl = @SiteUrl
    END
    ELSE -- if there was no @SiteId provided, this must be an update to an existing record and not a new record
    BEGIN
        -- ensure there is an entry for the record with the SiteId
        IF NOT EXISTS(SELECT 1 FROM dbo.SiteMetadata WHERE SiteId = @SiteId)
        BEGIN
            INSERT INTO SiteMetadata (
                SiteId, 
                SiteUrl) 
            VALUES (
                @SiteId, 
                @SiteUrl)
        END
    END
    
    UPDATE 
        dbo.SiteMetadata 
    SET 
        AnonymousLinkCount       = ISNULL(@AnonymousLinkCount, AnonymousLinkCount),
        CompanyLinkCount         = ISNULL(@CompanyLinkCount, CompanyLinkCount),
        ConditionalAccessPolicy  = ISNULL(@ConditionalAccessPolicy, ConditionalAccessPolicy),
        CreatedBy                = ISNULL(@CreatedBy, CreatedBy),
        DeletedBy                = ISNULL(@DeletedBy, DeletedBy),
        DenyAddAndCustomizePages = ISNULL(@DenyAddAndCustomizePages, DenyAddAndCustomizePages),
        FileViewedOrEdited       = ISNULL(@FileViewedOrEdited, FileViewedOrEdited),
        GroupId                  = ISNULL(@GroupId, GroupId),
        GuestLinkCount           = ISNULL(@GuestLinkCount, GuestLinkCount),
        HasLegalHold             = ISNULL(@HasLegalHold, HasLegalHold),
        HubSiteId                = ISNULL(@HubSiteId, HubSiteId),
        [Initiator]              = ISNULL(@Initiator, [Initiator]),
        IsGroupConnected         = ISNULL(@IsGroupConnected, IsGroupConnected),
        IsTeamsConnected         = ISNULL(@IsTeamsConnected, IsTeamsConnected),
        LastActivityOn           = ISNULL(@LastActivityOn, LastActivityOn),
        LastItemModifiedDate     = ISNULL(@LastItemModifiedDate, LastItemModifiedDate),
        LockState                = ISNULL(@LockState, LockState),
        MemberLinkCount          = ISNULL(@MemberLinkCount, MemberLinkCount),
        NumOfFiles               = ISNULL(@NumOfFiles, NumOfFiles), 
        PagesVisited             = ISNULL(@PagesVisited, PagesVisited),
        PageViews                = ISNULL(@PageViews, PageViews),
        PWAEnabled               = ISNULL(@PWAEnabled, PWAEnabled),
        SensitivityLabel         = ISNULL(@SensitivityLabel, SensitivityLabel),
        SharingCapability        = ISNULL(@SharingCapability, SharingCapability),
        SiteCreationSource       = ISNULL(@SiteCreationSource, SiteCreationSource),
        SiteOwnerEmail           = ISNULL(@SiteOwnerEmail, SiteOwnerEmail),
        SiteOwnerName            = ISNULL(@SiteOwnerName, SiteOwnerName),
        SiteUrl                  = ISNULL(@SiteUrl, SiteUrl),
        [State]                  = ISNULL(@State, [State]),
        StorageQuota             = ISNULL(@StorageQuota, StorageQuota), 
        StorageUsed              = ISNULL(@StorageUsed, StorageUsed),
        TemplateName             = ISNULL(@TemplateName, TemplateName),
        TimeCreated              = ISNULL(@TimeCreated, TimeCreated),
        TimeDeleted              = ISNULL(@TimeDeleted,TimeDeleted),
        Title                    = ISNULL(@Title,Title)
    WHERE
        SiteId = @SiteId

END
GO
