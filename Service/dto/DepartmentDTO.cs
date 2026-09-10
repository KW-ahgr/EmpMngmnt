namespace Service.dto;

public record DepartmentDTO
(
    int? Id ,
    string? Name ,
    bool? IsActive ,
    DateTime? CreatedAt
);