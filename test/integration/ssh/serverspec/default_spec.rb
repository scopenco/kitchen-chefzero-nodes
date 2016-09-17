require 'serverspec'
require 'json'

set :backend, :exec

describe 'sftp node' do
  let(:node) do
    JSON.parse(
      IO.read(File.join(ENV['TEMP'] || '/tmp', 'kitchen/sftp.json'))
    )
  end

  it 'has ip' do
    expect(node['automatic'].key?('ipaddress')).to eq(true)
  end

  it 'has fqdn' do
    expect(node['automatic'].key?('fqdn')).to eq(true)
  end
end

describe 'win node' do
  let(:node) do
    JSON.parse(
      IO.read(File.join(ENV['TEMP'] || '/tmp', 'kitchen/win.json'))
    )
  end

  it 'has ip' do
    expect(node['automatic'].key?('ipaddress')).to eq(true)
  end

  it 'has fqdn' do
    expect(node['automatic'].key?('fqdn')).to eq(true)
  end
end
