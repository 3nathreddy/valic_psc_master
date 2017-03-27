REM Bootstrap Chef DK, since this allows much quicker initial setup
REM Quietly install, restart by default, and log out.  
REM Should not execute if at least some version is already installed.
msiexec /i C:\vagrant\binaries\chef\chefdk-1.0.3-1-x86.msi /quiet /qn /log C:\vagrant\chef-repo\win2008r2\logs\install.log

C:\opscode\chefdk\bin\chef-client --local-mode -j C:\vagrant\chef-repo\win2008r2\runlist.json -c C:\vagrant\chef-repo\win2008r2\client.rb