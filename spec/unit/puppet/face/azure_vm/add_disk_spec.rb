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
      import: 'false',
      disk_size: '100',
      disk_label: 'Disk_label',
      disk_name: 'Disk Name'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    vms.any_instance.stubs(:add_data_disk).with(
      anything,
      anything,
      anything
    )
  end

  describe 'option validation' do
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.add_disk(@options) }.to_not raise_error
      end
    end

    describe '(vm_name)' do
      it 'should require a vm name' do
        @options.delete(:vm_name)
        expect { subject.add_disk(@options) }.to raise_error(
          ArgumentError,
          /required: vm_name/
        )
      end
    end

    describe '(cloud_service_name)' do
      it 'should require a cloud service name' do
        @options.delete(:cloud_service_name)
        expect { subject.add_disk(@options) }.to raise_error(
          ArgumentError,
          /required: cloud_service_name/
        )
      end
    end

    describe '(disk_size)' do
      it 'should validate the disk_size' do
        @options.delete(:disk_size)
        expect { subject.add_disk(@options) }.to_not raise_error
      end
    end

    describe '(disk_label)' do
      it 'should validate disk_label' do
        @options.delete(:disk_label)
        expect { subject.add_disk(@options) }.to_not raise_error
      end
    end

    describe '(disk_name)' do
      it 'should require disk_name when import is true' do
        @options[:import] = 'true'
        expect { subject.add_disk(@options) }.to_not raise_error
      end

      it 'should raise error when import is true and disk_name is empty' do
        @options[:import] = 'true'
        @options.delete(:disk_name)
        expect { subject.add_disk(@options) }.to raise_error(
          ArgumentError,
          /Disk name is required when import is true/
        )
      end
    end

    describe '(import)' do
      it 'import should be true, false or empty' do
        @options[:import] = 'wrong_value'
        expect { subject.add_disk(@options) }.to raise_error(
          ArgumentError,
          /Disk import option is not valid/
        )
      end

      it 'should validate disk_name when import is false' do
        @options.delete(:import)
        expect { subject.add_disk(@options) }.to_not raise_error
      end
    end

    it_behaves_like 'validate authentication credential', :add_disk

  end
end
