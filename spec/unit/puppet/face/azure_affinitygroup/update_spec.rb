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
      management_endpoint: 'management.core.windows.net',
      azure_subscription_id: 'Subscription-id',
      affinity_group_name: 'ag-name',
      label: 'Label',
      description: 'Affinity group Description'
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
  end

  describe 'option validation' do

    describe 'valid options' do
      before :each do
        base_service.any_instance.stubs(:update_affinity_group).with(
          any_parameters
        )
      end
      it 'should not raise any exception' do
        expect { subject.update(@options) }.to_not raise_error
      end

      it_behaves_like 'validate authentication credential', :update
    end

    describe '(affinity_group_name)' do
      it 'should validate the affinity group name' do
        @options.delete(:affinity_group_name)
        expect { subject.update(@options) }.to raise_error(
          ArgumentError,
          /required: affinity_group_name/
        )
      end
    end

    describe '(label)' do
      it 'should validate the label' do
        @options.delete(:label)
        expect { subject.update(@options) }.to raise_error(
          ArgumentError,
          /required: label/
        )
      end
    end

  end

  describe 'optional parameter validation' do
    before :each do
      base_service.any_instance.stubs(:update_affinity_group).with(
        any_parameters
      )
    end
    describe '(description)' do
      it 'description should be optional' do
        @options.delete(:description)
        expect { subject.update(@options) }.to_not raise_error
      end
    end
  end
end
