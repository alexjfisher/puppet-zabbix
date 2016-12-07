require 'spec_helper'
require 'zabbixapi'
require 'fakefs/spec_helpers'

provider_class = Puppet::Type.type(:zabbix_template).provider(:ruby)

describe provider_class do
  let(:name)     { 'my_template' }
  let(:resource) { Puppet::Type::Zabbix_template.new(resource_properties) }
  let(:provider) { provider_class.new(resource) }
  let(:zabbixapi) { mock('zabbixapi') }

  let(:resource_properties) do
    {
      name: name,
      template_source: '/path/to/template.xml',
      zabbix_url: 'example.com/api_jsonrpc.php',
      zabbix_user: 'user',
      zabbix_pass: 'pass',
      apache_use_ssl: false
    }
  end

  describe '#create' do
    let(:configurations) { ZabbixApi::Configurations.new('client') }

    it 'imports a template' do
      provider.expects(:connect).returns(zabbixapi)
      provider.expects(:template_contents).returns('some_xml')
      zabbixapi.expects(:configurations).returns(configurations)
      configurations.expects(:import).with(has_entries(format: 'xml', source: 'some_xml'))
      provider.create
    end
  end
  describe '#template_contents' do
    include FakeFS::SpecHelpers
    it 'returns the contents of \'template_source\'' do
      mock_file = '/path/to/template.xml'
      mock_content = <<-EOS
mock
file
content
      EOS
      FileUtils.mkdir_p '/path/to'
      File.open(mock_file, 'w') do |f|
        f.write mock_content
      end
      expect(provider.template_contents).to eq mock_content
    end
  end
end
