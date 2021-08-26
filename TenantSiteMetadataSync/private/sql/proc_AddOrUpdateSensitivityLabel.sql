IF OBJECT_ID('dbo.proc_AddOrUpdateSensitivityLabel', 'P') IS NOT NULL
   DROP PROCEDURE dbo.proc_AddOrUpdateSensitivityLabel
GO

CREATE PROCEDURE dbo.proc_AddOrUpdateSensitivityLabel
	@Id    uniqueidentifier,
	@Label nvarchar(50)
AS
BEGIN

    IF NOT EXISTS( SELECT 1 FROM  dbo.SensitivityLabel WHERE Id = @Id)
    BEGIN
        INSERT INTO dbo.SensitivityLabel (
            Id, 
            Label) 
        VALUES (
            @Id, 
            @Label)
    END
    ELSE
    BEGIN
        UPDATE 
            dbo.SensitivityLabel 
        SET 
            Label = @Label
        WHERE
            Id = @Id 
    END

END
GO
