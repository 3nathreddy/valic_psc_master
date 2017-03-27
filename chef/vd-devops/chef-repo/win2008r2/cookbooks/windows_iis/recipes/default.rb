%w{FS-FileServer Web-Server Web-WebServer Web-Common-Http Web-Static-Content Web-Default-Doc Web-Dir-Browsing Web-Http-Errors Web-Http-Redirect Web-App-Dev Web-Asp-Net Web-Net-Ext Web-ASP Web-CGI Web-ISAPI-Ext Web-ISAPI-Filter Web-Includes Web-Health Web-Http-Logging Web-Log-Libraries Web-Request-Monitor Web-Http-Tracing Web-Custom-Logging Web-Security Web-Basic-Auth Web-Windows-Auth Web-Client-Auth Web-Cert-Auth Web-Url-Auth Web-Filtering Web-IP-Security Web-Performance Web-Stat-Compression Web-Dyn-Compression Web-Mgmt-Tools Web-Mgmt-Console Web-Scripting-Tools Web-Mgmt-Service Web-Mgmt-Compat Web-Metabase Web-WMI Web-Lgcy-Scripting Web-Lgcy-Mgmt-Console NET-Framework NET-Framework-Core NET-Win-CFAC NET-HTTP-Activation NET-Non-HTTP-Activ }.each do |feature|
  

powershell_script feature do
  code <<-EOH
   Import-module ServerManager
   Add-WindowsFeature "#{feature}"
   EOH

 
guard_interpreter :powershell_script
not_if "(Get-WindowsFeature -Name #{feature}).Installed"
end
end