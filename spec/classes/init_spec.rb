require 'spec_helper'

describe 'cobbler' do
  let(:facts) {
    {
      :networking => {
        :fqdn     => 'test.example.com',
        :hostname => 'test',
        :ip       => '192.168.0.1'
      },
      :os         => {
        :name   => 'RedHat',
        :family => 'RedHat'
      }
    }
  }
  context 'with defaults for all parameters' do
    it { should contain_class('cobbler') }
    it { should contain_class('cobbler::install') }
    it { should contain_class('cobbler::config').that_requires('Class[cobbler::install]') }
    it { should contain_class('cobbler::service').that_subscribes_to('Class[cobbler::config]') }
  end

end
