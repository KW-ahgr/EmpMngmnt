namespace Service.dto;

public record UpsertEmployeeDTO
(
     int?  Id ,
     string? FirstName ,
     string? LastName ,
     string? NationalCode ,
     string? Email ,
     string? PhoneNumber ,
     int? DepartmentId ,
     decimal? Salary ,
     int? AddrId ,
     string? City ,
     string? Address ,
     string? PostalCode ,
     int? SkillId ,
     string? SkillName ,
     string? Level ,
     bool? IsActive ,
     byte[]? RowVersion 
);