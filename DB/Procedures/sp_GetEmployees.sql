CREATE PROCEDURE [dbo].[sp_GetEmployees]
    @Id INT = NULL,
    @FirstName NVARCHAR(55) = NULL,
    @LastName NVARCHAR(55) = NULL,
    @NationalCode VARCHAR(14) = NULL,
    @Email NVARCHAR(320) = NULL,
    @PhoneNumber VARCHAR(14) = NULL,
    @SalaryFrom DECIMAL(8, 8) = NULL,
    @SalaryTo DECIMAL(8, 8) = NULL,
    @CreatedAtFrom DATETIME2 = NULL,
    @CreatedAtTo DATETIME2 = NULL,
    @HireDateFrom DATETIME2 = NULL,
    @HireDateTo DATETIME2 = NULL,
    @UpdatedAtFrom DATETIME2 = NULL,
    @UpdatedAtTo DATETIME2 = NULL,
    @DepartmentId INT = NULL,
    @DepartmentName NVARCHAR(100) = NULL,
    @DepartmentCreatedAtFrom DATETIME2 = NULL,
    @DepartmentCreatedAtTo DATETIME2 = NULL,
    @AddressId INT = NULL,
    @City NVARCHAR(101) = NULL,
    @Address NVARCHAR(MAX) = NULL,
    @PostalCode VARCHAR(22) = NULL,
    @SkillId INT = NULL,
    @SkillName NVARCHAR(55) = NULL,
    @Level VARCHAR(8) = NULL,
    @IsActive BIT = NULL,
    @Page INT = 1 OUTPUT,
    @PageSize INT = 250 OUTPUT, 
    @OrderBy NVARCHAR(45) = NULL OUTPUT,
    @Direction NVARCHAR(5) = NULL OUTPUT,
    @Size INT OUTPUT 
AS
BEGIN 
    SET NOCOUNT ON;
    
    IF @Page < 1   SET @Page = 1;
    IF @PageSize NOT BETWEEN 1 AND 500   SET @PageSize = 250;
    
    IF @OrderBy NOT IN ('Id', 'FirstName', 'LastName', 'DepartmentId', 'HireDate', 'Salary', 'CreatedAt', 'UpdatedAt', 'City', 'SkillName', 'Level')
        SET @OrderBy = 'LastName';
        
    IF @OrderBy = 'SkillName' OR @OrderBy = 'Level'   SET @OrderBy = QUOTENAME('skl') + '.' + QUOTENAME(@OrderBy);
    ELSE IF @OrderBy = 'City'     SET @OrderBy = QUOTENAME('addr') + '.' + QUOTENAME(@OrderBy);
    ELSE   SET @OrderBy = QUOTENAME('emp') + '.' + QUOTENAME(@OrderBy);
    
    IF @Direction NOT IN ('DESC', 'ASC')   SET @Direction = 'ASC';
    SET @Direction = QUOTENAME(@Direction);
    
    DECLARE @Q NVARCHAR(MAX) = N'
        SELECT emp.Id,
           emp.FirstName,
           emp.LastName,
           emp.NationalCode,
           emp.Email,
           emp.PhoneNumber,
           emp.HireDate,
           emp.Salary,
           emp.CreatedAt,
           emp.UpdatedAt,
           emp.RowVersion,
           dep.Id AS DepartmentId,
           dep.Name AS DepartmentName,
           addr.Id AS AddressId,
           addr.City,
           addr.Address,
           addr.PostalCode,
           skl.Id AS SkillId,
           skl.SkillName,
           skl.Level,
           @Size = ROW_NUMBER() over ()
    FROM dbo.Employees emp
    LEFT JOIN dbo.Departments dep ON dep.Id = emp.DepartmentId AND dep.IsActive = 1
    LEFT JOIN dbo.EmployeeAddresses addr ON addr.EmployeeId = emp.Id
    LEFT JOIN dbo.EmployeeSkills skl ON emp.Id = skl.EmployeeId
    WHERE ((@IsActive IS NULL AND emp.IsActive = 1) OR (@IsActive IS NOT NULL AND emp.IsActive = @IsActive)) AND 
          (@Id IS NULL OR emp.Id = @Id) AND
          (@FirstName IS NULL OR emp.FirstName LIKE @FirstName + ''%'') AND
          (@LastName IS NULL OR emp.LastName LIKE @LastName + ''%'') AND
          (@NationalCode IS NULL OR emp.NationalCode LIKE @NationalCode + ''%'') AND
          (@Email IS NULL OR emp.Email LIKE @Email + ''%'') AND
          (@PhoneNumber IS NULL OR emp.PhoneNumber LIKE @PhoneNumber + ''%'') AND
          (@SalaryFrom IS NULL OR emp.Salary >= @SalaryFrom) AND
          (@SalaryTo IS NULL OR emp.Salary <= @SalaryTo) AND
          (@CreatedAtFrom IS NULL OR emp.CreatedAt >= @CreatedAtFrom) AND
          (@CreatedAtTo IS NULL OR emp.CreatedAt <= @CreatedAtTo) AND
          (@HireDateFrom IS NULL OR emp.HireDate >= @HireDateFrom) AND
          (@HireDateTo IS NULL OR emp.HireDate <= @HireDateTo) AND
          (@UpdatedAtFrom IS NULL OR emp.UpdatedAt >= @UpdatedAtFrom) AND
          (@UpdatedAtTo IS NULL OR emp.UpdatedAt <= @UpdatedAtTo) AND
          (@DepartmentId IS NULL OR emp.DepartmentId = @DepartmentId) AND
          (@DepartmentName IS NULL OR dep.Name LIKE @DepartmentName + ''%'') AND
          (@DepartmentCreatedAtFrom IS NULL OR dep.CreatedAt >= @DepartmentCreatedAtFrom) AND
          (@DepartmentCreatedAtTo IS NULL OR dep.CreatedAt <= @DepartmentCreatedAtTo) AND
          (@AddressId IS NULL OR addr.Id = @AddressId) AND
          (@City IS NULL OR addr.City = @City) AND
          (@Address IS NULL OR addr.Address LIKE @Address + ''%'') AND
          (@PostalCode IS NULL OR addr.PostalCode LIKE @PostalCode + ''%'') AND
          (@SkillId IS NULL OR skl.Id = @SkillId) AND
          (@SkillName IS NULL OR skl.SkillName LIKE @SkillName + ''%'') AND
          (@Level IS NULL OR skl.Level = @Level)
    ORDER BY ' + @OrderBy + ' ' + @Direction + ', emp.Id
    OFFSET (@Page - 1) * @PageSize ROWS 
    FETCH NEXT @PageSize ROWS ONLY;
    ';
    
    DECLARE @Params NVARCHAR(MAX) = N'@Id INT ,
    @FirstName NVARCHAR(55) ,
    @LastName NVARCHAR(55) ,
    @NationalCode VARCHAR(14) ,
    @Email NVARCHAR(320) ,
    @PhoneNumber VARCHAR(14) ,
    @SalaryFrom DECIMAL(8, 8) ,
    @SalaryTo DECIMAL(8, 8) ,
    @CreatedAtFrom DATETIME2 ,
    @CreatedAtTo DATETIME2 ,
    @HireDateFrom DATETIME2 ,
    @HireDateTo DATETIME2 ,
    @UpdatedAtFrom DATETIME2 ,
    @UpdatedAtTo DATETIME2 ,
    @DepartmentId INT ,
    @DepartmentName NVARCHAR(100) ,
    @DepartmentCreatedAtFrom DATETIME2 ,
    @DepartmentCreatedAtTo DATETIME2 ,
    @AddressId INT ,
    @City NVARCHAR(101) ,
    @Address NVARCHAR(MAX) ,
    @PostalCode VARCHAR(22) ,
    @SkillId INT ,
    @SkillName NVARCHAR(55) ,
    @Level VARCHAR(8) ,
    @IsActive BIT ,
    @Page INT,
    @PageSize INT, 
    @Size INT OUTPUT ';

    EXEC sp_executesql @Q,
        @Params,
        @Id = @Id,
        @FirstName = @FirstName,
        @LastName = @LastName,
        @NationalCode = @NationalCode,
        @Email = @Email,
        @PhoneNumber = @PhoneNumber,
        @SalaryFrom = @SalaryFrom,
        @SalaryTo = @SalaryTo,
        @CreatedAtFrom = @CreatedAtFrom,
        @CreatedAtTo = @CreatedAtTo,
        @HireDateFrom = @HireDateFrom,
        @HireDateTo = @HireDateTo,
        @UpdatedAtFrom = @UpdatedAtFrom,
        @UpdatedAtTo = @UpdatedAtTo,
        @DepartmentId = @DepartmentId,
        @DepartmentName = @DepartmentName,
        @DepartmentCreatedAtFrom = @DepartmentCreatedAtFrom,
        @DepartmentCreatedAtTo = @DepartmentCreatedAtTo,
        @AddressId = @AddressId,
        @City = @City,
        @Address = @Address,
        @PostalCode = @PostalCode,
        @SkillId = @SkillId,
        @SkillName = @SkillName,
        @Level = @Level,
        @IsActive = @IsActive,
        @Page = @Page,
        @PageSize = @PageSize, 
        @Size = @Size OUTPUT
    ;
    
END