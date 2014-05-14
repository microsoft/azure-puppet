#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_vnet, :current] do
  let(:vnet_service) { Azure::VirtualNetworkManagementService }
  let(:vnet) do
    v = Azure::VirtualNetworkManagement::VirtualNetwork.new
    v.name = 'vnet-name'
    v.affinity_group = 'test'
    v.address_space = %w(172.16.0.0/12 10.0.0.0/8 192.168.0.0/24)
    v.dns_servers = [
      { name: 'dns-1', ip_address: '8.8.8.8' },
      { name: 'dns-2', ip_address: '1.2.3.4' }
    ]
    v.subnets = [
      { name: 'Subnet-2', address_prefix: '10.0.0.0/8' },
      { name: 'Subnet-4', address_prefix: '192.168.0.0/26' }
    ]
    v
  end

  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      management_endpoint: 'management.core.windows.net',
      azure_subscription_id: 'Subscription-id'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
  end

  describe 'option validation' do
    before :each do
      vnet_service.any_instance.stubs(
        :list_virtual_networks
      ).returns([vnet])
    end

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.list(@options) }.to_not raise_error
      end

      it 'should print affinity groups details' do
        vnets = subject.list(@options)
        expect(vnets).to match(/#{"Server Name".fix(20)}: #{vnet.name}/)
        address_spaces = vnet.address_space.join(', ')
        expect(vnets).to match(/Address Space       : #{address_spaces}/)
        expect(vnets).to match(/Subnet-2          10.0.0.0\/8/)
        expect(vnets).to match(/dns-2             1.2.3.4/)
      end
    end

    it_behaves_like 'validate authentication credential', :list

  end
end
