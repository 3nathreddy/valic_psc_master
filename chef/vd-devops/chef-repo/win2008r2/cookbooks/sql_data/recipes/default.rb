#
# Cookbook Name:: sql_data
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Create a path to the SQL file in the Chef cache.
create_database_script_path = win_friendly_path(File.join(Chef::Config[:file_cache_path], 'script.sql'))

# Copy the SQL file from the cookbook to the Chef cache.
cookbook_file create_database_script_path do
  source 'script.sql'
end

# Get the full path to the SQLPS module.
sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\120\Tools\PowerShell\Modules\SQLPS')
Chef::Log.info(" SQLPS path is  #{sqlps_module_path}")
# Run the SQL file only if the 'learnchef' database has not yet been created.
powershell_script 'Initialize database' do
  code <<-EOH
    Import-Module "#{sqlps_module_path}"
    Invoke-Sqlcmd -InputFile #{create_database_script_path}
  EOH
  guard_interpreter :powershell_script
  only_if <<-EOH
    Import-Module "#{sqlps_module_path}"
    (Invoke-Sqlcmd -Query "SELECT COUNT(*) AS Count FROM sys.databases WHERE name = 'PSOdb'").Count -eq 0
  EOH
end