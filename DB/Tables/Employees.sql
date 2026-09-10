CREATE TABLE [dbo].[Employees]
(
    Id INT NOT NULL PRIMARY KEY,
    FirstName NVARCHAR(55) NOT NULL CHECK (LEN(FirstName) >= 2),
    LastName NVARCHAR(55) NOT NULL CHECK (LEN(LastName) >= 2),
    NationalCode VARCHAR(14) NOT NULL UNIQUE CHECK (NationalCode LIKE '[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    Email NVARCHAR(320) NOT NULL CHECK (
                                        Email LIKE '%@%.[a-z,A-Z,0-9][a-z,A-Z,0-9]%'
                                            AND Email NOT LIKE '% %'
                                            AND Email NOT LIKE '%@%@%'
                                            AND Email NOT LIKE '%..%'
                                        ),
    PhoneNumber VARCHAR(14) NOT NULL UNIQUE,
    DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) ON DELETE SET DEFAULT,
    HireDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    Salary DECIMAL(8, 8) NOT NULL DEFAULT 0.0 CHECK (Salary > 0),
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    RowVersion ROWVERSION
);
GO;

CREATE UNIQUE NONCLUSTERED INDEX IX_Employees_NationalCode ON Employees(NationalCode) 
    INCLUDE(LastName) 
    WHERE IsActive = 1;
GO;

CREATE TRIGGER trg_Employees 
ON dbo.Employees
AFTER UPDATE, INSERT 
AS
BEGIN 
    IF EXISTS(
        SELECT 1 
        FROM inserted nw
        JOIN dbo.Departments dep ON dep.Id = nw.DepartmentId AND dep.IsActive <> 1
    )
        RAISERROR('Inactive Department', 16, 1);
    
    IF EXISTS(
        SELECT DepartmentId
        FROM inserted
    ) AND IsActive <> 1
        RAISERROR('Inactive Employee', 16, 1);
END;
GO;