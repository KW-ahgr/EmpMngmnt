CREATE PROCEDURE [dbo].[sp_UpsertDepartment]
    @Id INT = NULL,
    @Name NVARCHAR(100),
    @IsActive BIT = 1,
    @OId INT OUTPUT,
    @Success BIT OUTPUT
AS
BEGIN 
    SET NOCOUNT ON;
    
    MERGE INTO dbo.Departments AS dep
    USING (SELECT @Id AS Id) AS src
    ON src.Id = dep.Id
    WHEN MATCHED THEN UPDATE SET Name = @Name, IsActive = @IsActive
    WHEN NOT MATCHED THEN INSERT (Name, IsActive) VALUES (@Name, @IsActive);  
    
    IF @Id IS NOT NULL  SET @OId = SCOPE_IDENTITY();

    IF @@ROWCOUNT > 0   SET @Success = 1;
    ELSE    SET @Success = 0;
end