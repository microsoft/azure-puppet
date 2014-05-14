#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_cloudservice, '1.0.0' do
  action :upload_certificate do

    summary 'adds a certificate to a hosted service.'

    description <<-'EOT'
    The upload_certificate action adds a certificate to a hosted service.
    EOT

    Puppet::CloudService.add_certificate_options(self)

    when_invoked do |options|
      Puppet::CloudService.initialize_env_variable(options)
      cloud_service = Azure::CloudServiceManagementService.new
      certificate = {}
      cert_file = File.read(options[:certificate_file])
      key_file = File.read(options[:private_key_file])
      csn = options[:cloud_service_name]
      certificate[:key] = OpenSSL::PKey.read key_file
      certificate[:cert] = OpenSSL::X509::Certificate.new cert_file
      cloud_service.upload_certificate(csn, certificate)
      nil
    end

    examples <<-'EOT'
      $ puppet azure_cloudservice upload_certificate \
        --cloud-service-name cloudservice1 --certificate-file cert_file_path \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID \
        --management-certificate path-to-azure-certificate \
        --private-key-file private_key_file_path
    EOT
  end
end
