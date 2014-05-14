#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_vm, :current] do
  let(:image_service) { Azure::VirtualMachineImageManagementService }
  let(:image) do
    VirtualMachineImage.new do |image|
      image.os_type = 'Windows'
      image.name = 'SQL-Server-2014CTP2-CU1-12.0.1736.0-ENU-WS2012R2-CY13SU12'
      image.category = ' Microsoft SQL Server'
      image.locations = 'West US'
    end
  end

  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      management_endpoint: 'management.core.windows.net',
      azure_subscription_id: 'Subscription-id',
      location: 'west us'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
  end

  describe 'option validation' do
    before :each do
      $stdout.stubs(:write)
      image_service.any_instance.stubs(
        :list_virtual_machine_images
      ).returns([image])
    end

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.images(@options) }.to_not raise_error
      end

      it 'should print images details' do
        images = subject.images(@options)
        expect(images).to match(
          /#{image.os_type.fix} #{image.category[0..19]}      #{image.name}/
        )
      end
    end

    describe 'optional parameter validation' do
      describe '(location)' do
        it 'location should be optional' do
          @options.delete(:location)
          expect { subject.images(@options) }.to_not raise_error
        end
      end
    end

    it_behaves_like 'validate authentication credential', :images

  end
end
