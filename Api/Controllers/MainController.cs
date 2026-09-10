using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Service.dto;
using Service.Repository;

namespace Api.Controllers;

[ApiController]
[Route("api")]
public class MainController (IDbService dbService, IMemoryCache memoryCache, ILogger<MainController> logger) : ControllerBase
{
    private const string DepartmentsKey = "Deps", EmployeesKey = "Emps";
    
    [HttpGet("departments")]
    public async Task<IActionResult> GetDepartments(
        CancellationToken cancellationToken,
        [FromQuery] int? id = null,
        [FromQuery] bool? isActive = null,
        [FromQuery] string? name = null,
        [FromQuery] DateTime? createdAtFrom = null,
        [FromQuery] DateTime? createdAtTo = null,
        [FromQuery] int? page = null,
        [FromQuery] int? pageSize = null,
        [FromQuery] string? orderBy = null,
        [FromQuery] string? direction = null
    )
    {
        var key = JsonSerializer.Serialize(
            new
            {
                id, isActive, name, createdAtFrom, createdAtTo, page, pageSize, orderBy, direction
            }
        );
        key = DepartmentsKey + key;
        if (memoryCache
            .TryGetValue(key, out var data))
        {
            Response.Headers.Append("X-Cache-Stats", "HIT");
            logger.LogInformation($"Department -> Cache hit: {Request.QueryString}");
            return Ok(data);
        }
        
        Response.Headers.Append("X-Cache-Stats", "MISS");
        var result = await dbService.GetDepartmentsAsync(id, isActive, name, createdAtFrom, createdAtTo, page, pageSize, orderBy,
            direction, cancellationToken);
        memoryCache.Set(key, result, TimeSpan.FromMinutes(5));
        logger.LogInformation($"Get Departments: {result.pageSize}");
        return Ok(result);
    }

    [HttpPost("departments")]
    public async Task<IActionResult> AddDepartment([FromBody] UpsertDepartmentDTO upsertDepartmentDto,
        CancellationToken cancellationToken)
    {
        var result = await dbService.UpsertDepartmentAsync(upsertDepartmentDto, cancellationToken);
        logger.LogInformation($"Department Upsertion: {result.success} - {result.id}");
        return result.success ? Ok(result) : BadRequest(result);
    }

    [HttpDelete("departments")]
    public async Task<IActionResult> DeleteDepartment([FromBody] DeleteRequestDTO deleteRequestDto,
        CancellationToken cancellationToken)
    {
        var result = await dbService.DeleteDepartmentAsync(deleteRequestDto, cancellationToken);
        logger.LogInformation($"Deleting Department: {result}");
        return result ? NoContent() : BadRequest();
    }

    [HttpGet("employees")]
    public async Task<IActionResult> GetEmployees(
        CancellationToken cancellationToken,
        [FromQuery] int? id = null,
        [FromQuery] string? firstName = null,
        [FromQuery] string? lastName = null,
        [FromQuery] string? nationalCode = null,
        [FromQuery] string? email = null,
        [FromQuery] string? phoneNumber = null,
        [FromQuery] Decimal? salaryFrom = null,
        [FromQuery] Decimal? salaryTo = null,
        [FromQuery] DateTime? createdAtFrom = null,
        [FromQuery] DateTime? createdAtTo = null,
        [FromQuery] DateTime? hireDateFrom = null,
        [FromQuery] DateTime? hireDateTo = null,
        [FromQuery] DateTime? updatedAtFrom = null,
        [FromQuery] DateTime? updatedAtTo = null,
        [FromQuery] int? departmentId = null,
        [FromQuery] string? departmentName = null,
        [FromQuery] DateTime? departmentCreateAtFrom = null,
        [FromQuery] DateTime? departmentCreateAtTo = null,
        [FromQuery] int? addressId = null,
        [FromQuery] string? city = null,
        [FromQuery] string? address = null,
        [FromQuery] string? postalCode = null,
        [FromQuery] int? skillId = null,
        [FromQuery] string? skillName = null,
        [FromQuery] string? level = null,
        [FromQuery] bool? isActive = null,
        [FromQuery] int? page = null,
        [FromQuery] int? pageSize = null,
        [FromQuery] string? orderBy = null,
        [FromQuery] string? direction = null
    )
    {
        var key = JsonSerializer.Serialize(
            new
            {
                id, firstName, lastName, nationalCode, email, phoneNumber, salaryFrom, salaryTo,
                createdAtFrom, createdAtTo, hireDateFrom, hireDateTo, updatedAtFrom, updatedAtTo, departmentId, departmentName,
                departmentCreateAtFrom, departmentCreateAtTo, addressId, city, address, postalCode, skillId, skillName, level,
                isActive, page, pageSize, orderBy, direction
            }
        );
        key = EmployeesKey + key;

        if (memoryCache.TryGetValue(key, out var data))
        {
            Response.Headers.Append("X-Cache-Stats", "HIT");
            logger.LogInformation($"Employees -> Cache hit: {Request.QueryString}");
            return Ok(data);
        }
        
        Response.Headers.Append("X-Cache-Stats", "MISS");
        var employees = await dbService.GetEmployeesAsync(id, firstName, lastName, nationalCode, email, phoneNumber, salaryFrom, salaryTo,
            createdAtFrom, createdAtTo, hireDateFrom, hireDateTo, updatedAtFrom, updatedAtTo, departmentId,
            departmentName, departmentCreateAtFrom, departmentCreateAtTo, addressId, city, address, postalCode, skillId,
            skillName, level, isActive, page, pageSize, orderBy, direction, cancellationToken);
        memoryCache.Set(key, employees, TimeSpan.FromMinutes(5));
        logger.LogInformation($"Get Employees: {employees.pageSize}");
        return Ok(employees);
    }

    [HttpPost("employees")]
    public async Task<IActionResult> AddEmployee([FromBody] UpsertEmployeeDTO upsertEmployeeDto,
        CancellationToken cancellationToken)
    {
        var result = await dbService.UpsertEmployeeAsync(upsertEmployeeDto, cancellationToken);
        logger.LogInformation($"Employee Upsertion: {result.success} - {result.employeeId}");
        return result.success ? Ok(result) : BadRequest(result);
    }

    [HttpDelete("employees")]
    public async Task<IActionResult> DeleteEmployee([FromBody] DeleteRequestDTO deleteRequestDto,
        CancellationToken cancellationToken)
    {
        var result = await dbService.DeleteEmployeeAsync(deleteRequestDto, cancellationToken);
        logger.LogInformation($"Deleting Employee: {result}");
        return result ? NoContent() : BadRequest();
    }
}