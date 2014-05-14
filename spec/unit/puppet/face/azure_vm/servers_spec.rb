#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_vm, :current] do
  let(:vms) { Azure::VirtualMachineManagementService }
  let(:vm) { Azure::VirtualMachineManagement::VirtualMachine }
  let(:vm_name) { 'windows-instance' }
  let(:ip_address) { '192.168.1.1' }
  let(:os_type) { 'Windows' }
  let(:virtual_machine_obj) do
    vm.new do |virtual_machine|
      virtual_machine.vm_name = vm_name
      virtual_machine.ipaddress = ip_address
      virtual_machine.os_type = os_type
    end
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
      vms.any_instance.stubs(:list_virtual_machines).with(
        anything,
        anything
      ).returns([virtual_machine_obj])
    end

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.servers(@options) }.to_not raise_error
      end

      it 'should print server details' do
        servers = subject.servers(@options)
        expect(servers).to match(/Role              : #{vm_name}/)
        expect(servers).to match(/IP Address        : #{ip_address}/)
      end
    end

    it_behaves_like 'validate authentication credential', :servers
  end
end
