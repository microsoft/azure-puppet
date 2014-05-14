#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_vm, :current] do
  let(:vms) { Azure::VirtualMachineManagementService }

  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      azure_subscription_id: 'Subscription-id',
      vm_name: 'test-vm',
      cloud_service_name: 'cloud-name',
      endpoint_name: 'endpoint_name',
      public_port: '8080',
      local_port: '8080',
      protocol: 'tcp',
      direct_server_return: 'false',
      load_balancer_name: 'lb-name',
      load_balancer_protocol: 'tcp',
      load_balancer_port: '100'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    vms.any_instance.stubs(:update_endpoints).with(
      anything,
      anything,
      anything
    )
  end

  describe 'option validation' do
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.update_endpoint(@options) }.to_not raise_error
      end
    end

    describe '(vm_name)' do
      it 'should require a vm name' do
        @options.delete(:vm_name)
        expect { subject.update_endpoint(@options) }.to raise_error(
          ArgumentError,
          /required: vm_name/
        )
      end
    end

    describe '(cloud_service_name)' do
      it 'should require a cloud service name' do
        @options.delete(:cloud_service_name)
        expect { subject.update_endpoint(@options) }.to raise_error(
          ArgumentError,
          /required: cloud_service_name/
        )
      end
    end

    describe '(endpoint_name)' do
      it 'should require endpoint name' do
        @options.delete(:endpoint_name)
        expect { subject.update_endpoint(@options) }.to raise_error(
          ArgumentError,
          /required: endpoint_name/
        )
      end
    end

    describe '(public_port)' do
      it 'should require public port' do
        @options.delete(:public_port)
        expect { subject.update_endpoint(@options) }.to raise_error(
          ArgumentError,
          /required: public_port/
        )
      end
    end

    describe '(local_port)' do
      it 'should require local port' do
        @options.delete(:local_port)
        expect { subject.update_endpoint(@options) }.to raise_error(
          ArgumentError,
          /required: local_port/
        )
      end
    end

    describe '(protocol)' do
      it 'should validate the protocol' do
        @options.delete(:protocol)
        expect { subject.update_endpoint(@options) }.to_not raise_error
      end

      it 'should not allow wrong protocol value' do
        @options[:protocol] = 'wrong-value'
        expect { subject.update_endpoint(@options) }.to raise_error(
          RuntimeError,
          /Protocol is invalid. Allowed values are tcp,udp/
        )
      end
    end

    describe '(load_balancer_name)' do
      it 'should validate the load_balancer_name' do
        @options.delete(:load_balancer_name)
        expect { subject.update_endpoint(@options) }.to_not raise_error
      end
    end

    describe '(direct_server_return)' do
      it 'should validate direct_server_return' do
        @options.delete(:direct_server_return)
        expect { subject.update_endpoint(@options) }.to_not raise_error
      end

      it 'should not allow wrong direct_server_return value' do
        @options[:direct_server_return] = 'wrong-value'
        expect { subject.update_endpoint(@options) }.to raise_error(
          RuntimeError,
          /direct_server_return is invalid. Allowed values are true,false/
        )
      end
    end

    describe '(load_balancer_protocol)' do
      it 'should validate load_balancer_protocol' do
        @options.delete(:load_balancer_protocol)
        expect { subject.update_endpoint(@options) }.to_not raise_error
      end
    end

    describe '(load_balancer_port)' do
      it 'should validate load_balancer_port' do
        @options.delete(:load_balancer_port)
        expect { subject.update_endpoint(@options) }.to_not raise_error
      end
    end

    describe '(load_balancer_path)' do
      it 'should require load_balancer_path when protocol is http' do
        @options[:load_balancer_protocol] = 'http'
        @options.delete(:load_balancer_path)
        expect { subject.update_endpoint(@options) }.to raise_error(
          RuntimeError,
          /Load balancer path is required if load balancer protocol is http/
        )
      end

      it 'should not required load_balancer_path when protocol is tcp' do
        @options[:load_balancer_protocol] = 'tcp'
        @options.delete(:load_balancer_path)
        expect { subject.update_endpoint(@options) }.to_not raise_error
      end

      it 'should validate load_balancer_ protocol' do
        @options[:load_balancer_protocol] = 'wrong-value'
        expect { subject.update_endpoint(@options) }.to raise_error(
          RuntimeError,
          /Load balancer protocol is invalid. Allowed values are http,tcp/
        )
      end
    end

    it_behaves_like 'validate authentication credential', :update_endpoint

  end
end
