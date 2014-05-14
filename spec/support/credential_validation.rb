#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

shared_examples 'validate authentication credential' do |service_method|
  describe '(management_certificate)' do
    it 'should require a management_certificate' do
      @options.delete(:management_certificate)
      expect { subject.send(service_method, @options) }.to raise_error(
        ArgumentError,
        /required: management_certificate/
      )
    end

    it 'management_certificate doesn\'t  exist' do
      @options[:management_certificate] = 'FileNotExist'
      expect { subject.send(service_method, @options) }.to raise_error(
        ArgumentError,
        /Could not find file 'FileNotExist'/
      )
    end

    it 'management_certificate extension is not valid' do
      file_path = File.expand_path('spec/fixtures/invalid_file.txt')
      @options[:management_certificate] = file_path
      expect { subject.send(service_method, @options) }.to raise_error(
        RuntimeError,
        /Management certificate expects a .pem or .pfx file/
      )
    end
  end

  describe '(azure_subscription_id)' do
    it 'should require a azure_subscription_id' do
      @options.delete(:azure_subscription_id)
      expect { subject.send(service_method, @options) }.to raise_error(
        ArgumentError,
        /required: azure_subscription_id/
      )
    end
  end

  describe '(management_endpoint)' do
    it 'management_endpoint should be optional' do
      @options.delete(:management_endpoint)
      expect { subject.send(service_method, @options) }.to_not raise_error
    end
  end
end
