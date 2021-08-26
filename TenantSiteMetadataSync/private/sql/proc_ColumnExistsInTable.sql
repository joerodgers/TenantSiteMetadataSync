IF OBJECT_ID('dbo.proc_ColumnExistsInTable', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_ColumnExistsInTable
GO

CREATE PROCEDURE [dbo].[proc_ColumnExistsInTable]
    @TableName  nvarchar(500),
    @ColumnName nvarchar(500)
AS
BEGIN

	IF EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TableName AND COLUMN_NAME = @ColumnName)
	BEGIN
		RETURN 1
	END

	RETURN 0
END

GO