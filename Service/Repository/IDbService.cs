using Service.dto;

namespace Service.Repository;

public interface IDbService
{
    Task<bool> DeleteDepartmentAsync(DeleteRequestDTO deleteRequest, CancellationToken cancellationToken);
    Task<bool> DeleteEmployeeAsync(DeleteRequestDTO deleteRequest, CancellationToken cancellationToken);
    Task<(IEnumerable<DepartmentDTO> departments, int page, int pageSize, string orderBy, string direction, int size)> GetDepartmentsAsync(
        int? id, 
        bool? isActive,
        string? name,
        DateTime? createdAtFrom,
        DateTime? createdAtTo,
        int? page,
        int? pageSize,
        string? orderBy,
        string? direction,
        CancellationToken cancellationToken
    );
    Task<(IEnumerable<EmployeeDTO> employees, int page, int pageSize, string orderBy, string direction, int Size)> GetEmployeesAsync(
        int? id,
        string? firstName,
        string? lastName,
        string? nationalCode,
        string? email,
        string? phoneNumber,
        Decimal? salaryFrom,
        Decimal? salaryTo,
        DateTime? createdAtFrom,
        DateTime? createdAtTo,
        DateTime? hireDateFrom,
        DateTime? hireDateTo,
        DateTime? updatedAtFrom,
        DateTime? updatedAtTo,
        int? departmentId,
        string? departmentName,
        DateTime? departmentCreateAtFrom,
        DateTime? departmentCreateAtTo,
        int? addressId,
        string? city,
        string? address,
        string? postalCode,
        int? skillId,
        string? skillName,
        string? level,
        bool? isActive,
        int? page,
        int? pageSize,
        string? orderBy,
        string? direction,
        CancellationToken cancellationToken
    );
    Task<(int? id, bool success)> UpsertDepartmentAsync(UpsertDepartmentDTO departmentDto, CancellationToken cancellationToken);
    Task<(int? employeeId, int? skillId, int? addressId, bool success)> UpsertEmployeeAsync(UpsertEmployeeDTO employee, CancellationToken cancellationToken);
}