#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_vm, '1.0.0' do
  action :images do

    summary 'List Microsoft Azure images'

    description <<-'EOT'
      The images action obtains a list of images from the cloud provider and
      displays them on the console output.
    EOT

    Puppet::VirtualMachine.add_list_images_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      image_service = Azure::VirtualMachineImageManagementService.new
      images = image_service.list_virtual_machine_images
      location = options[:location]
      images = images.select { |x| x.locations =~ /#{location}/i } if location
      template = Tilt.new(Puppet::VirtualMachine.views('images.erb'))
      template.render(nil, images:  images)
    end

    returns 'List containing information about each Azure images.'

    examples <<-'EOT'
      $ puppet azure_vm images --azure-subscription-id YOUR-SUBSCRIPTION-ID \
        --management-certificate path-to-azure-certificate

      Listing Virtual Machine Images

      OS Type    Category                  Name
      Linux      RightScale with Linu      RightImage-CentOS-6.2-x64-v5.8.8.1
      Linux      RightScale with Linu      RightImage-CentOS-6.3-x64-v5.8.8
    EOT
  end
end
