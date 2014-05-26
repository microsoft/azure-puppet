#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'spec_helper'
describe Puppet::Face[:azure_servicebus, :current] do
  let(:service_bus) { Azure::ServiceBusService }

  before :each do

    @options = {
      sb_namespace:  'busname',
      sb_access_key: 'nD/E49P4SJG8UVEpABOeZRc=',
      queue_name: 'queue'
    }

    Azure.configure do |config|
      config.sb_namespace  = @options[:sb_namespace]
      config.sb_access_key = @options[:sb_access_key]
    end
    service_bus.any_instance.stubs(:create_queue).with(any_parameters)
  end

  describe 'option validation' do
    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.create_queue(@options) }.to_not raise_error
      end
    end

    describe '(queue_name)' do
      it 'should validate queue name' do
        @options.delete(:queue_name)
        expect { subject.create_queue(@options) }.to raise_error(
          ArgumentError,
          /required: queue_name/
        )
      end
    end

    describe '(sb_access_key)' do
      it 'should validate service bus access key' do
        @options.delete(:sb_access_key)
        expect { subject.create_queue(@options) }.to raise_error(
          ArgumentError,
          /required: sb_access_key/
        )
      end
    end

    describe '(sb_namespace)' do
      it 'should validate service bus namespace' do
        @options.delete(:sb_namespace)
        expect { subject.create_queue(@options) }.to raise_error(
          ArgumentError,
          /required: sb_namespace/
        )
      end
    end

  end
end
