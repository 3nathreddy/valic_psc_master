dotnet4dir = File.join(ENV['WINDIR'], 'Microsoft.Net\\Framework64\\v4.0.30319')
aspnet_regiis_cmd = File.join(dotnet4dir, 'aspnet_regiis.exe')
appcmd = File.join(ENV['WINDIR'], 'system32\\inetsrv\\appcmd.exe')

execute 'aspnet_regiis' do
  command "#{aspnet_regiis_cmd} -i"
  action :run
  not_if do
    cmd = Mixlib::ShellOut.new("#{appcmd} list config /section:isapiCgiRestriction")
    aspnet_isapis = cmd.run_command
    Chef::Log.debug(aspnet_isapis.stdout)
    aspnet_isapis.stdout.include?('Framework64\\v4.0.30319\\aspnet_isapi.dll')
  end
end
