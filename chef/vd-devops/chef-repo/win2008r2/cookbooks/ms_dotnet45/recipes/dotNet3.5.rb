powershell_script ' Dot Net 3.5 FrameWork' do
  code <<-EOH
  Import-Module ServerManager
  Add-WindowsFeature as-net-framework
  EOH
  end