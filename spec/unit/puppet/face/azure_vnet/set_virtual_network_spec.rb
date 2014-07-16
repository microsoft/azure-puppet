#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_vnet, :current] do
  let(:vnet_service) { Azure::VirtualNetworkManagementService }
  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      azure_subscription_id: 'Subscription-id',
      management_endpoint: 'management.core.windows.net',
      virtual_network_name: 'login-name',
      location: 'West US',
      address_space: '172.16.0.0/12,10.0.0.0/8,192.168.0.0/24',
      dns_servers: 'dns-1:8.8.8.8,dns-2:8.8.4.4',
      subnets: 'subnet-1:172.16.0.0:12'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    vnet_service.any_instance.stubs(:set_network_configuration).with(
      any_parameters
    )
  end

  describe 'option validation' do

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.set(@options) }.to_not raise_error
      end

    end

    describe '(virtual_network_name)' do
      it 'should validate the virtual network name' do
        @options.delete(:virtual_network_name)
        expect { subject.set(@options) }.to raise_error(
          ArgumentError,
          /required: virtual_network_name/
        )
      end
    end

    describe '(location)' do
      it 'should validate the location' do
        @options.delete(:location)
        expect { subject.set(@options) }.to raise_error(
          ArgumentError,
          /required: location/
        )
      end
    end

    describe '(address_space)' do
      it 'should validate address space' do
        @options.delete(:address_space)
        expect { subject.set(@options) }.to raise_error(
          ArgumentError,
          /required: address_space/
        )
      end
    end

    it_behaves_like 'validate authentication credential', :set
  end

  describe 'optional parameter validation' do

    describe '(subnets)' do
      it 'subnets should be optional' do
        @options.delete(:subnets)
        expect { subject.set(@options) }.to_not raise_error
      end

      it 'should accept multiple value of subnet using comma seperated' do
        @options[:subnets] = 'subnet-1:172.16.0.0:12,subnet-2:192.168.0.0:29'
        expect { subject.set(@options) }.to_not raise_error
      end

      describe 'invalid subnets' do
        it 'should raise error when cidr and ip_address is missing' do
          @options[:subnets] = 'Subnet-name'
          expect { subject.set(@options) }.to raise_error(
            RuntimeError,
            /Missing argument subnet name or ip_address or cidr in subnet/
          )
        end

        it 'should raise error when cidr is missing' do
          @options[:subnets] = 'Subnet-name:192.168.1.1'
          expect { subject.set(@options) }.to raise_error(
            RuntimeError,
            /Missing argument subnet name or ip_address or cidr in subnet/
          )
        end
      end
    end

    describe '(dns_servers)' do
      it 'dns_servers should be optional' do
        @options.delete(:dns_servers)
        expect { subject.set(@options) }.to_not raise_error
      end

      it 'dns_servers and subnets should be optional' do
        @options.delete(:dns_servers)
        @options.delete(:subnets)
        expect { subject.set(@options) }.to_not raise_error
      end

      describe 'invalid dns servers' do
        it 'should raise error when dns name or ipaddress is missing' do
          @options[:dns_servers] = 'Dns-name'
          expect { subject.set(@options) }.to raise_error(
            RuntimeError,
            /Missing argument dns name or ip_address in dns/
          )
        end
      end
    end
  end

end
