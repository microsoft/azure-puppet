#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_cloudservice, :current] do
  let(:cloud_service) { Azure::CloudServiceManagementService }

  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      azure_subscription_id: 'Subscription-id',
      cloud_service_name: 'cloud-name',
      location: 'west us',
      description: 'Some description',
      label: 'label',
      affinity_group_name: 'ag-1'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    cloud_service.any_instance.stubs(
      :create_cloud_service
    ).with(anything, anything)
  end

  describe 'option validation' do
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(cloud_service_name)' do
      it 'should validate cloud service name' do
        @options.delete(:cloud_service_name)
        expect { subject.create(@options) }.to raise_error(
          ArgumentError,
          /required: cloud_service_name/
        )
      end
    end

    describe '(location)' do
      it 'should validate the cloud service location or affinity group' do
        @options.delete(:location)
        @options.delete(:affinity_group_name)
        expect { subject.create(@options) }.to raise_error(
          ArgumentError,
          /affinity group name or location is required/
        )
      end

      it 'should not raise any exception when only location is given' do
        @options.delete(:affinity_group_name)
        expect { subject.create(@options) }.to_not raise_error
      end

      it 'should not raise any exception when only affinity group is given' do
        @options.delete(:location)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(description)' do
      it 'should validate the cloud service description' do
        @options.delete(:description)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(label)' do
      it 'should validate the cloud service label' do
        @options.delete(:label)
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    it_behaves_like 'validate authentication credential', :create

  end
end
