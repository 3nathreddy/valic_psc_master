require 'serverspec'

set :backend, :exec


describe file('/opt/aem/author/license.properties') do
  it { should exist }
end

describe command('service aem-author status') do
  its(:stdout) { should match /running/ }
end

describe port(4502) do
  it { should be_listening }
end


describe command('curl -is -u admin:admin http://localhost:4502/etc/workflow.json | head -1') do
  its(:stdout) { should match /200 OK/ }
end