CREATE PROCEDURE [dbo].[sp_GetDepartments] 
    @Id INT = NULL,
    @IsActive BIT = NULL,
    @Name NVARCHAR(100) = NULL,
    @CreatedAtFrom DATETIME2 = NULL,
    @CreatedAtTo DATETIME2 = NULL,
    @Page INT = 1 OUTPUT,
    @PageSize INT = 250 OUTPUT,
    @OrderBy NVARCHAR(45) = NULL OUTPUT,
    @Direction NVARCHAR(5) = NULL OUTPUT,
    @Size INT OUTPUT 
AS
BEGIN 
    SET NOCOUNT ON;
    
    IF @PageSize > 500   SET @PageSize = 500;
    IF @Page IS NULL OR @Page < 1   SET @Page = 1;

    IF @OrderBy NOT IN ('Name', 'IsActive', 'CreatedAt')    SET @OrderBy = 'Name';
    IF @Direction NOT IN ('DESC', 'ASC')   SET @Direction = 'ASC';
    SET @OrderBy = QUOTENAME(@OrderBy);
    SET @Direction = QUOTENAME(@Direction);
    
    DECLARE @Q NVARCHAR(MAX) = N'
        SELECT Id, Name, IsActive, CreatedAt,
               @Size = COUNT(*) OVER (  )
        FROM dbo.Departments
        WHERE (@Id IS NULL OR Id = @Id) AND
            ((@IsActive IS NULL AND IsActive = 1) OR (@IsActive IS NOT NULL AND IsActive = @IsActive)) AND
            (@Name IS NULL OR Name LIKE @Name + ''%'') AND
            (@CreatedAtFrom IS NULL OR CreatedAt >= @CreatedAtFrom) AND
            (@CreatedAtTo IS NULL OR CreatedAt <= @CreatedAtTo) 
        ORDER BY ' + @OrderBy + ' ' + @Direction + ', Id
        OFFSET (@Page - 1) * @PageSize ROWS FETCH NEXT @PageSize ROWS ONLY '; 
    
    DECLARE @Param NVARCHAR(MAX) = N'
        @Id INT = NULL,
        @IsActive BIT = NULL,
        @Name NVARCHAR(100) = NULL,
        @CreatedAtFrom DATETIME2 = NULL,
        @CreatedAtTo DATETIME2 = NULL,
        @Page INT = 1,
        @PageSize INT = 250,
        @Size INT OUTPUT ';
    
    EXEC sp_executesql @Q,
        @Param,
        @Id = @Id,
        @IsActive = @IsActive,
        @Name = @Name,
        @CreatedAtFrom = @CreatedAtFrom,
        @CreatedAtTo = @CreatedAtTo,
        @Page = @Page,
        @PageSize = @PageSize,
        @Size = @Size OUTPUT
    ;

END