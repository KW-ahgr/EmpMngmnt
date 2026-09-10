using System.Data;
using Microsoft.Data.SqlClient;
using Serilog;
using Service.Repository;

var builder = WebApplication.CreateBuilder(args);

Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .WriteTo.File("logs/log-.txt", rollingInterval: RollingInterval.Day)
    .CreateLogger();

builder.Host.UseSerilog(); 

builder.Services.AddScoped<IDbConnection>(_ =>
    new SqlConnection(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IDbService, DbService>();

builder.Services.AddMemoryCache();
builder.Services.AddControllers();

var app = builder.Build();

app.MapControllers();

app.Run();