CREATE TABLE [dbo].[EmployeeAddresses]
(
    Id INT NOT NULL PRIMARY KEY NONCLUSTERED,
    EmployeeId INT NOT NULL FOREIGN KEY REFERENCES Employees(Id) ON DELETE CASCADE,
    City NVARCHAR(101) NOT NULL,
    Address NVARCHAR(MAX) NOT NULL,
    PostalCode VARCHAR(22) NOT NULL
);
GO;

CREATE CLUSTERED INDEX IX_EmployeeAddresses_PostalCode ON EmployeeAddresses(PostalCode);
GO;