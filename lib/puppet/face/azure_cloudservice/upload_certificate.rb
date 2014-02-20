# encoding: UTF-8

Puppet::Face.define :azure_cloudservice, '1.0.0' do
  action :upload_certificate do

    summary 'adds a certificate to a hosted service.'

    description 'The upload_certificate action adds a certificate to a hosted service.'

    Puppet::CloudService.add_certificate_options(self)

    when_invoked do |options|
      Puppet::CloudService.initialize_env_variable(options)
      cloud_service = Azure::CloudServiceManagementService.new
      certificate = {}
      certificate[:key] = OpenSSL::PKey.read File.read(options[:private_key_file])
      certificate[:cert] = OpenSSL::X509::Certificate.new File.read(options[:certificate_file])
      cloud_service.upload_certificate(options[:cloud_service_name], certificate)
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
