using System.Data;
using Dapper;
using Service.dto;

namespace Service.Repository;

public class DbService (IDbConnection connection) : IDbService 
{
    public async Task<bool> DeleteDepartmentAsync(DeleteRequestDTO deleteRequest, CancellationToken cancellationToken)
    {
        var parameters = new DynamicParameters();
        parameters.Add("@Id",  deleteRequest.Id);
        parameters.Add(
            "@Success",
            dbType: DbType.Boolean,
            direction: ParameterDirection.Output
        );
        
        cancellationToken.ThrowIfCancellationRequested();
        
        await connection.ExecuteAsync(
            "dbo.sp_DeleteDepartment",
            parameters,
            commandType: CommandType.StoredProcedure
        );
        
        return parameters.Get<int>("@Success") == 1;
    }

    public async Task<bool> DeleteEmployeeAsync(DeleteRequestDTO deleteRequest, CancellationToken cancellationToken)
    {
        var parameters = new DynamicParameters();
        parameters.Add("@Id",  deleteRequest.Id);
        parameters.Add(
            "@Success",
            dbType: DbType.Boolean,
            direction: ParameterDirection.Output
        );
        
        cancellationToken.ThrowIfCancellationRequested();
        
        await connection.ExecuteAsync(
            "dbo.sp_DeleteEmployee",
            parameters,
            commandType: CommandType.StoredProcedure
        );
        
        return parameters.Get<bool?>("@Success") == true;
    }

    public async Task<(IEnumerable<DepartmentDTO> departments, int page, int pageSize, string orderBy, string direction, int size)> GetDepartmentsAsync(int? id, bool? isActive, string? name, DateTime? createdAtFrom, DateTime? createdAtTo,
        int? page, int? pageSize, string? orderBy, string? direction, CancellationToken cancellationToken)
    {
        var options = new DynamicParameters();
        options.Add("@Id", id);
        options.Add("@IsActive",  isActive);
        options.Add("@Name", name);
        options.Add("@CreatedAtFrom", createdAtFrom);
        options.Add("@CreatedAtTo", createdAtTo);
        options.Add("@Page", dbType:DbType.Int32, direction:ParameterDirection.InputOutput, value: page);
        options.Add("@PageSize", dbType:DbType.Int32, direction:ParameterDirection.InputOutput, value: pageSize);
        options.Add("@OrderBy", dbType:DbType.String, direction:ParameterDirection.InputOutput, value: orderBy);
        options.Add("@Direction", dbType:DbType.String, direction:ParameterDirection.InputOutput, value: direction);
        options.Add("@Size", dbType:DbType.Int32, direction: ParameterDirection.Output);

        cancellationToken.ThrowIfCancellationRequested();
        
        var departments =
            await connection.QueryAsync<DepartmentDTO>(
                "dbo.sp_GetDepartments",
                options,
                commandType: CommandType.StoredProcedure
            );
        
        return (
            departments,
            options.Get<int>("@Page"),
            options.Get<int>("@PageSize"),
            options.Get<string>("@OrderBy"),
            options.Get<string>("@Direction"),
            options.Get<int>("@Size")
        );
    }

    public async Task<(IEnumerable<EmployeeDTO> employees, int page, int pageSize, string orderBy, string direction, int Size)> GetEmployeesAsync(int? id, string? firstName, string? lastName, string? nationalCode, string? email,
        string? phoneNumber, decimal? salaryFrom, decimal? salaryTo, DateTime? createdAtFrom, DateTime? createdAtTo,
        DateTime? hireDateFrom, DateTime? hireDateTo, DateTime? updatedAtFrom, DateTime? updatedAtTo, int? departmentId,
        string? departmentName, DateTime? departmentCreateAtFrom, DateTime? departmentCreateAtTo, int? addressId,
        string? city, string? address, string? postalCode, int? skillId, string? skillName, string? level, bool? isActive,
        int? page, int? pageSize, string? orderBy, string? direction, CancellationToken cancellationToken)
    {
        var parameters = new DynamicParameters();
        parameters.Add("@Id", id);
        parameters.Add("@FirstName", firstName);
        parameters.Add("@LastName", lastName);
        parameters.Add("@NationalCode", nationalCode);
        parameters.Add("@Email", email);
        parameters.Add("@PhoneNumber", phoneNumber);
        parameters.Add("@SalaryFrom", salaryFrom);
        parameters.Add("@SalaryTo", salaryTo);
        parameters.Add("@CreatedAtFrom", createdAtFrom);
        parameters.Add("@CreatedAtTo", createdAtTo);
        parameters.Add("@HireDateFrom", hireDateFrom);
        parameters.Add("@HireDateTo", hireDateTo);
        parameters.Add("@UpdatedAtFrom", updatedAtFrom);
        parameters.Add("@UpdatedAtTo", updatedAtTo);
        parameters.Add("@DepartmentId", departmentId);
        parameters.Add("@DepartmentName", departmentName);
        parameters.Add("@DepartmentCreateAtFrom", departmentCreateAtFrom);
        parameters.Add("@DepartmentCreateAtTo", departmentCreateAtTo);
        parameters.Add("@AddressId", addressId);
        parameters.Add("@City", city);
        parameters.Add("@Address", address);
        parameters.Add("@PostalCode", postalCode);
        parameters.Add("@SkillId", skillId);
        parameters.Add("@SkillName", skillName);
        parameters.Add("@Level", level);
        parameters.Add("@IsActive", isActive);
        parameters.Add("@Page", dbType:DbType.Int32, direction:ParameterDirection.InputOutput, value: page);
        parameters.Add("@PageSize", dbType:DbType.Int32, direction:ParameterDirection.InputOutput, value: pageSize);
        parameters.Add("@OrderBy", dbType:DbType.String, direction:ParameterDirection.InputOutput, value: orderBy);
        parameters.Add("@Direction", dbType:DbType.String, direction:ParameterDirection.InputOutput, value: direction);
        parameters.Add("@Size", dbType:DbType.Int32, direction: ParameterDirection.Output);
        
        cancellationToken.ThrowIfCancellationRequested();
        
        var departments =
            await connection.QueryAsync<EmployeeDTO>(
                "dbo.sp_GetEmployees",
                parameters,
                commandType: CommandType.StoredProcedure
            );
        
        return (
            departments,
            parameters.Get<int>("@Page"),
            parameters.Get<int>("@PageSize"),
            parameters.Get<string>("@OrderBy"),
            parameters.Get<string>("@Direction"),
            parameters.Get<int>("@Size")
        );
    }

    public async Task<(int? id, bool success)> UpsertDepartmentAsync(UpsertDepartmentDTO departmentDto, CancellationToken cancellationToken)
    {
        var parameters = new DynamicParameters();
        parameters.Add("@Id", departmentDto.Id);
        parameters.Add("@IsActive", departmentDto.IsActive);
        parameters.Add("@Name", departmentDto.Name);
        parameters.Add("@OId", dbType: DbType.Int32, direction: ParameterDirection.Output);
        parameters.Add("@Success", dbType:DbType.Boolean, direction: ParameterDirection.Output);
        
        cancellationToken.ThrowIfCancellationRequested();
        
        await connection.ExecuteAsync(
            "dbo.sp_UpsertDepartment",
            parameters,
            commandType: CommandType.StoredProcedure
        );

        return (parameters.Get<int?>("@Id"), parameters.Get<bool>("@Success"));
    }

    public async Task<(int? employeeId, int? skillId, int? addressId, bool success)> UpsertEmployeeAsync(UpsertEmployeeDTO employee, CancellationToken cancellationToken)
    {
        var parameters = new DynamicParameters();
        parameters.Add("@Id", employee.Id);
        parameters.Add("@FirstName", employee.FirstName);
        parameters.Add("@LastName", employee.LastName);
        parameters.Add("@NationalCode", employee.NationalCode);
        parameters.Add("@Email",  employee.Email);
        parameters.Add("@PhoneNumber", employee.PhoneNumber);
        parameters.Add("@DepartmentId", employee.DepartmentId);
        parameters.Add("@Salary",  employee.Salary);
        parameters.Add("@AddrId", employee.AddrId);
        parameters.Add("@City", employee.City);
        parameters.Add("@Address",  employee.Address);
        parameters.Add("@PostalCode", employee.PostalCode);
        parameters.Add("@SklId", employee.SkillId);
        parameters.Add("@SkillName", employee.SkillName);
        parameters.Add("@Level", employee.Level);
        parameters.Add("@IsActive", employee.IsActive);
        parameters.Add("@RowVersion", employee.RowVersion);
        parameters.Add("@InsertedEmployeeId", dbType:DbType.Int32, direction:ParameterDirection.Output);
        parameters.Add("@InsertedSkillId", dbType:DbType.Int32, direction:ParameterDirection.Output);
        parameters.Add("@InsertedAddressId", dbType:DbType.Int32, direction:ParameterDirection.Output);
        parameters.Add("@Success", dbType:DbType.Boolean, direction:ParameterDirection.Output);
        
        cancellationToken.ThrowIfCancellationRequested();
        
        await connection.ExecuteAsync(
            "dbo.sp_UpsertEmployee",
            parameters,
            commandType: CommandType.StoredProcedure
        );

        return (
            parameters.Get<int?>("@InsertedEmployeeId"), 
            parameters.Get<int?>("@InsertedSkillId"), 
            parameters.Get<int?>("@InsertedAddressId"), 
            parameters.Get<bool>("@Success")
            );
    }
}