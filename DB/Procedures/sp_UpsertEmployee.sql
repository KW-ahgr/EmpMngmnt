CREATE PROCEDURE [dbo].[sp_UpsertEmployee]
    @Id INT = NULL,
    @FirstName NVARCHAR(55) = NULL,
    @LastName NVARCHAR(55) = NULL,
    @NationalCode VARCHAR(14) = NULL,
    @Email NVARCHAR(320) = NULL,
    @PhoneNumber VARCHAR(14) = NULL,
    @DepartmentId INT = NULL,
    @Salary DECIMAL(8, 8) = NULL,
    @AddrId INT = NULL,
    @City NVARCHAR(101) = NULL,
    @Address NVARCHAR(MAX) = NULL,
    @PostalCode VARCHAR(22) = NULL,
    @SklId INT = NULL,
    @SkillName NVARCHAR(55) = NULL,
    @Level VARCHAR(8) = NULL,
    @IsActive BIT = NULL,
    @RowVersion ROWVERSION = NULL,
    @InsertedEmployeeId INT OUTPUT,
    @InsertedSkillId INT OUTPUT,
    @InsertedAddressId INT OUTPUT,
    @Success BIT OUTPUT
AS
BEGIN 
    SET NOCOUNT ON;

    DECLARE @InsertedEmployees TABLE ( ID INT );
    DECLARE @InsertedSkills TABLE ( ID INT );
    DECLARE @InsertedAddress TABLE ( ID INT );
    
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    SET XACT_ABORT ON;
    
    DECLARE @CC INT = 1;
    
    WHILE @CC <= 3
    BEGIN
        BEGIN TRY
            BEGIN TRAN;
            DECLARE @RV ROWVERSION = (SELECT RowVersion FROM dbo.Employees WHERE Id = @Id);
            
            IF @RV IS NOT NULL 
            BEGIN
                IF @RowVersion <> @RV   RAISERROR('Old row_version', 16, 1);

                UPDATE dbo.Employees
                SET FirstName = ISNULL(@FirstName, emp.FirstName),
                    LastName = ISNULL(@LastName, emp.LastName),
                    NationalCode = ISNULL(@NationalCode, emp.NationalCode),
                    Email = ISNULL(@Email, emp.Email),
                    PhoneNumber = ISNULL(@PhoneNumber, emp.PhoneNumber),
                    DepartmentId = ISNULL(@DepartmentId, emp.DepartmentId),
                    Salary = ISNULL(@Salary, emp.Salary),
                    IsActive = ISNULL(@IsActive, emp.IsActive),
                    UpdatedAt = GETUTCDATE()
                WHERE Id = @Id;

                IF @AddrId IS NOT NULL
                    MERGE INTO dbo.EmployeeAddresses addr
                    USING (SELECT @AddrId AS Id) AS src
                    ON src.Id = addr.Id AND addr.EmployeeId = @Id
                    WHEN MATCHED THEN UPDATE
                                      SET addr.City = ISNULL(@City, addr.City),
                                          addr.Address = ISNULL(@Address, addr.Address),
                                          addr.PostalCode = ISNULL(@PostalCode, addr.PostalCode)
                    WHEN NOT MATCHED THEN INSERT (EmployeeId, City, Address, PostalCode)
                                          VALUES (@Id, @City, @Address, @PostalCode)
                        OUTPUT CASE WHEN $action = 'INSERT' THEN inserted.Id END INTO @InsertedAddress(ID);
                ELSE IF @City IS NOT NULL OR @Address IS NOT NULL OR @PostalCode IS NOT NULL
                    BEGIN
                        WITH C1 AS (
                            SELECT Id, ROW_NUMBER() OVER (PARTITION BY EmployeeId ORDER BY Id DESC) RN
                            FROM dbo.EmployeeAddresses
                            WHERE EmployeeId = @Id
                        )
                        DELETE C1 WHERE RN > 1;

                        MERGE INTO dbo.EmployeeAddresses addr
                        USING (SELECT @Id AS Id) AS emp
                        ON addr.EmployeeId = emp.Id
                        WHEN MATCHED THEN UPDATE
                                          SET addr.City = ISNULL(@City, addr.City),
                                              addr.Address = ISNULL(@Address, addr.Address),
                                              addr.PostalCode = ISNULL(@PostalCode, addr.PostalCode)
                        WHEN NOT MATCHED THEN INSERT (EmployeeId, City, Address, PostalCode)
                                              VALUES (@Id, @City, @Address, @PostalCode)
                            OUTPUT CASE WHEN $action = 'INSERT' THEN inserted.Id END INTO @InsertedAddress(ID);
                    END

                IF @SklId IS NOT NULL
                    MERGE INTO dbo.EmployeeSkills skl
                    USING (SELECT @SklId AS Id) AS src
                    ON src.Id = skl.Id AND skl.EmployeeId = @Id
                    WHEN MATCHED THEN UPDATE
                                      SET skl.SkillName = ISNULL(@SkillName, skl.SkillName),
                                          skl.Level = ISNULL(@Level, skl.Level)
                    WHEN NOT MATCHED THEN INSERT (EmployeeId, SkillName, Level)
                                          VALUES (@Id, @SkillName, @Level)
                        OUTPUT CASE WHEN $action = 'INSERT' THEN inserted.Id END INTO @InsertedSkills(ID);
                ELSE IF @SkillName IS NOT NULL AND @Level IS NOT NULL
                    BEGIN
                        WITH C1 AS (
                            SELECT Id, ROW_NUMBER() over (PARTITION BY EmployeeId ORDER BY Id DESC) RN
                            FROM dbo.EmployeeSkills WHERE EmployeeId = @Id
                        )
                        DELETE C1 WHERE RN > 1;

                        MERGE INTO dbo.EmployeeSkills skl
                        USING (SELECT @Id AS Id) AS emp
                        ON emp.Id = skl.EmployeeId
                        WHEN MATCHED THEN UPDATE
                                          SET skl.SkillName = ISNULL(@SkillName, skl.SkillName),
                                              skl.Level = ISNULL(@Level, skl.Level)
                        WHEN NOT MATCHED THEN INSERT (EmployeeId, SkillName, Level)
                                              VALUES (@Id, @SkillName, @Level)
                            OUTPUT CASE WHEN $action = 'INSERT' THEN inserted.Id END INTO @InsertedSkills(ID);
                    END
            END
            ELSE
            BEGIN
                INSERT INTO dbo.Employees (FirstName, LastName, NationalCode, Email, PhoneNumber, DepartmentId, Salary, IsActive)
                VALUES (@FirstName, @LastName, @NationalCode, @Email, @PhoneNumber, @DepartmentId, @Salary, @IsActive);

                SET @Id = SCOPE_IDENTITY();
                INSERT INTO @InsertedEmployees (ID) VALUES (@Id);

                IF @SkillName IS NOT NULL AND @Level IS NOT NULL
                    BEGIN
                        INSERT INTO dbo.EmployeeSkills (EmployeeId, SkillName, Level)
                        VALUES (@Id, @SkillName, @Level);

                        INSERT INTO @InsertedSkills (ID) VALUES (SCOPE_IDENTITY());
                    END

                IF @City IS NOT NULL OR @Address IS NOT NULL OR @PostalCode IS NOT NULL
                    BEGIN
                        INSERT INTO dbo.EmployeeAddresses (EmployeeId, City, Address, PostalCode)
                        VALUES (@Id, @City, @Address, @PostalCode);

                        INSERT INTO @InsertedAddress (ID) VALUES (SCOPE_IDENTITY());
                    END
            END

            SET @InsertedEmployeeId = (SELECT LAST_VALUE(ID) FROM @InsertedEmployees);
            SET @InsertedSkillId = (SELECT LAST_VALUE(ID) FROM @InsertedSkills);
            SET @InsertedAddressId = (SELECT LAST_VALUE(ID) FROM @InsertedAddress);

            COMMIT TRAN;

            IF @@ROWCOUNT > 0   SET @Success = 1;
            ELSE    SET @Success = 0;
            
            RETURN 0;
        END TRY
        BEGIN CATCH 
            IF @@ERROR <> 1205 OR @CC >= 3   THROW;
        END CATCH 
        
        SET @CC = @CC + 1;
        WAITFOR DELAY '00:00:03';
    END

    RETURN 1;
END