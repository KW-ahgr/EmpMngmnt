CREATE PROCEDURE [dbo].[sp_DeleteEmployee]
    @Id INT,
    @Success BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Employees
    SET IsActive = 0
    WHERE Id = @Id;

    IF @@ROWCOUNT > 0   SET @Success = 1;
    ELSE    SET @Success = 0;
end