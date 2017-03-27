windows_package "NUnit #{node['nunit']['version']}" do
  #source "http://github.com/nunit/nunitv2/releases/download/#{node['nunit']['version']}/NUnit-#{node['nunit']['version']}.msi"
  source node['nunit']['version']
end
