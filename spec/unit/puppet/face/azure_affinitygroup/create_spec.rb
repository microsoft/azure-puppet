#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_affinitygroup, :current] do
  let(:base_service) { Azure::BaseManagementService }
  before :each do
    mgmtcertfile = File.expand_path('spec/fixtures/management_certificate.pem')
    @options = {
      management_certificate: mgmtcertfile,
      azure_subscription_id: 'Subscription-id',
      management_endpoint: 'management.core.windows.net',
      affinity_group_name: 'ag-name',
      location: 'West US',
      label: 'Affinity group label',
      description: 'Affinity group Description'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end

  end

  describe 'option validation' do
    before :each do
      base_service.any_instance.stubs(:create_affinity_group).with(
        any_parameters
      )
    end

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.create(@options) }.to_not raise_error
      end
    end

    describe '(affinity_group_name)' do
      it 'should validate the affinity group name' do
        @options.delete(:affinity_group_name)
        expect { subject.create(@options) }.to raise_error(
          ArgumentError,
          /required: affinity_group_name/
        )
      end
    end

    describe '(location)' do
      it 'should validate the location' do
        @options.delete(:location)
        expect { subject.create(@options) }.to raise_error(
          ArgumentError,
          /required: location/
        )
      end
    end

    describe '(label)' do
      it 'should validate cloud service name' do
        @options.delete(:label)
        expect { subject.create(@options) }.to raise_error(
          ArgumentError,
          /required: label/
        )
      end
    end

    it_behaves_like 'validate authentication credential', :create
  end

  describe 'optional parameter validation' do
    before :each do
      base_service.any_instance.stubs(:create_affinity_group).with(
        any_parameters
      )
    end

    describe '(description)' do
      it 'description should be optional' do
        @options.delete(:description)
        expect { subject.create(@options) }.to_not raise_error
      end
    end
  end

end
