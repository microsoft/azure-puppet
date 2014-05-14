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
    netowork_schema = File.expand_path('spec/fixtures/vnet_schema.xml')
    @options = {
      management_certificate: mgmtcertfile,
      azure_subscription_id: 'Subscription-id',
      management_endpoint: 'management.core.windows.net',
      xml_schema_file: netowork_schema
    }
    Azure.configure do |config|
      config.management_certificate = @options[:management_certificate]
      config.subscription_id        = @options[:azure_subscription_id]
    end
    vnet_service.any_instance.stubs(:set_network_configuration).with(
      anything
    )
  end

  describe 'option validation' do

    describe 'valid options' do
      it 'should not raise any exception' do
        expect { subject.set_xml_schema(@options) }.to_not raise_error
      end
    end

    describe '(xml_schema_file)' do
      it 'should validate the xml schema file' do
        @options.delete(:xml_schema_file)
        expect { subject.set_xml_schema(@options) }.to raise_error(
          ArgumentError,
          /required: xml_schema_file/
        )
      end

      it 'xml_schema_file doesn\'t  exist' do
        @options[:xml_schema_file] = 'FileNotExist'
        expect { subject.set_xml_schema(@options) }.to raise_error(
          ArgumentError,
          /Could not find file 'FileNotExist'/
        )
      end

      it 'xml_schema_file extension is not valid' do
        file_path = File.expand_path('spec/fixtures/invalid_file.txt')
        @options[:xml_schema_file] = file_path
        expect { subject.set_xml_schema(@options) }.to raise_error(
          RuntimeError,
          /Network schema expects a .xml file/
        )
      end
    end

    it_behaves_like 'validate authentication credential', :set_xml_schema

  end
end
