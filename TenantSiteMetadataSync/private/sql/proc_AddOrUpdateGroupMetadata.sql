IF OBJECT_ID('dbo.proc_AddOrUpdateGroupMetadata', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_AddOrUpdateGroupMetadata
GO

CREATE PROCEDURE dbo.proc_AddOrUpdateGroupMetadata
    @GroupId                       uniqueidentifier,
	@DisplayName                   nvarchar(255) = NULL,
	@IsDeleted                     bit           = NULL,
    @LastActivityDate              datetime2(7)  = NULL,
    @IsPublic                      bit           = NULL,
    @MemberCount                   int           = NULL,
    @ExternalMemberCount           int           = NULL,
    @ExchangeReceivedEmailCount    int           = NULL, 
    @SharePointActiveFileCount     int           = NULL,
    @SharePointTotalFileCount      int           = NULL,
    @YammerPostedMessageCount      int           = NULL,
    @YammerReadMessageCount        int           = NULL,
    @YammerLikedMessageCount       int           = NULL,
    @ExchangeMailboxTotalItemCount int           = NULL,
    @ExchangeMailboxStorageUsed    bigint        = NULL
AS
BEGIN
    
    -- ensure there is an entry for the record with the GroupId
    IF NOT EXISTS(SELECT 1 FROM dbo.GroupMetadata WHERE GroupId = @GroupId)
    BEGIN
        INSERT INTO GroupMetadata 
        (
            GroupId,
            DisplayName,
            IsDeleted,    
            LastActivityDate,
            IsPublic,
            MemberCount,
            ExternalMemberCount,
            ExchangeReceivedEmailCount,
            SharePointActiveFileCount,   
            SharePointTotalFileCount,    
            YammerPostedMessageCount,     
            YammerReadMessageCount,     
            YammerLikedMessageCount,
            ExchangeMailboxTotalItemCount,
            ExchangeMailboxStorageUsed    
        )
            
        VALUES 
        (
            @GroupId,
	        @DisplayName,
	        @IsDeleted,
            @LastActivityDate,
            @IsPublic,
            @MemberCount,
            @ExternalMemberCount,
            @ExchangeReceivedEmailCount,
            @SharePointActiveFileCount,
            @SharePointTotalFileCount,
            @YammerPostedMessageCount,
            @YammerReadMessageCount,
            @YammerLikedMessageCount,
            @ExchangeMailboxTotalItemCount,
            @ExchangeMailboxStorageUsed
        )
    END
    ELSE
    BEGIN
        UPDATE 
            dbo.GroupMetadata 
        SET 
            DisplayName                   = ISNULL(@DisplayName,DisplayName),
            IsDeleted                     = ISNULL(@IsDeleted,IsDeleted),
            LastActivityDate              = ISNULL(@LastActivityDate,LastActivityDate),
            IsPublic                      = ISNULL(@IsPublic,IsPublic),
            MemberCount                   = ISNULL(@MemberCount,MemberCount),
            ExternalMemberCount           = ISNULL(@ExternalMemberCount,ExternalMemberCount),
            ExchangeReceivedEmailCount    = ISNULL(@ExchangeReceivedEmailCount,ExchangeReceivedEmailCount),
            SharePointActiveFileCount     = ISNULL(@SharePointActiveFileCount,SharePointActiveFileCount),
            SharePointTotalFileCount      = ISNULL(@SharePointTotalFileCount,SharePointTotalFileCount),
            YammerPostedMessageCount      = ISNULL(@YammerPostedMessageCount,YammerPostedMessageCount),
            YammerReadMessageCount        = ISNULL(@YammerReadMessageCount,YammerReadMessageCount),
            YammerLikedMessageCount       = ISNULL(@YammerLikedMessageCount,YammerLikedMessageCount),
            ExchangeMailboxTotalItemCount = ISNULL(@ExchangeMailboxTotalItemCount,ExchangeMailboxTotalItemCount),
            ExchangeMailboxStorageUsed    = ISNULL(@ExchangeMailboxStorageUsed,ExchangeMailboxStorageUsed)
        WHERE
            GroupId = @GroupId
    END
END
GO
