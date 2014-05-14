#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_cloudservice, '1.0.0' do
  action :delete do

    summary 'Delete cloud service.'

    description 'The delete action delete a cloud service.'

    Puppet::CloudService.add_delete_options(self)

    when_invoked do |options|
      Puppet::CloudService.initialize_env_variable(options)
      cloud_service = Azure::CloudServiceManagementService.new
      begin
        cloud_service.delete_cloud_service(options[:cloud_service_name])
      rescue
      end
      nil
    end

    examples <<-'EOT'
      $ puppet azure_cloudservice delete --cloud-service-name cloudservice1 \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID \
        --management-certificate path-to-azure-certificate
    EOT
  end
end
