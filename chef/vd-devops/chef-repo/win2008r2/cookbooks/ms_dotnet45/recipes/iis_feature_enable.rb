%w{ IIS-WebServerRole IIS-WebServer IIS-HttpErrors IIS-HttpRedirect }.each do |feature|
windows_feature feature do
    action :install
  end
end