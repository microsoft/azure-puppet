#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_cloudservice, '1.0.0' do
  action :delete_deployment  do

    summary 'deletes the specified deployment of hosted service.'
    description <<-'EOT'
      The delete_deployment action deletes the specified deployment of a
      hosted service.
    EOT

    Puppet::CloudService.add_delete_deployment_options(self)

    when_invoked do |options|
      Puppet::CloudService.initialize_env_variable(options)
      cloud_service = Azure::CloudServiceManagementService.new
      csn = options[:cloud_service_name]
      cloud_service.delete_cloud_service_deployment(csn) rescue nil
      nil
    end

    examples <<-'EOT'
      $ puppet azure_cloudservice upload_certificate \
        --cloud-service-name cloudservice1 \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID \
        --management-certificate path-to-azure-certificate
    EOT
  end
end
