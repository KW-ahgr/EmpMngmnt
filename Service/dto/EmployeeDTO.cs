namespace Service.dto;

public record EmployeeDTO
(
    int? Id,
    string? FirstName,
    string? LastName,
    string? NationalCode,
    string? Email,
    string? PhoneNumber,
    DateTime? HireDate,
    Decimal? Salary,
    DateTime? CreatedAt,
    DateTime? UpdatedAt,
    byte[]? RowVersion,
    int? DepartmentId,
    string? DepartmentName,
    int? AddressId,
    string? City,
    string? Address,
    string? PostalCode,
    int? SkillId,
    string? SkillName,
    string? Level
);