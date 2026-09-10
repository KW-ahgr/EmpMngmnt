CREATE PROCEDURE [dbo].[sp_DeleteDepartment]
    @Id INT,
    @Success BIT OUTPUT
AS
BEGIN 
    SET NOCOUNT ON;
    
    DELETE FROM dbo.Departments WHERE Id = @Id;
    
    IF @@ROWCOUNT > 0   SET @Success = 1;
    ELSE    SET @Success = 0;
END