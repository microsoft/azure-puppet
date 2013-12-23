require 'tilt'

Puppet::Face.define :azure_vm, '1.0.0' do
  action :images do

    summary 'List Windows Azure images'

    description <<-'EOT'
      The images action obtains a list of images from the cloud provider and
      displays them on the console output.
    EOT

    Puppet::VirtualMachine.add_default_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      virtual_machine_image_service = Azure::VirtualMachineImageManagementService.new
      images = virtual_machine_image_service.list_virtual_machine_images
      template = Tilt.new(Puppet::VirtualMachine.views('images.erb'))
      template.render(nil, images:  images)
    end

    returns 'List containing information about each Azure images.'

    examples <<-'EOT'
      $ puppet azure_vm images --management-certificate path-to-azure-certificate \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID
      Listing Virtual Machine Images

      OS Type            Category                  Name

      Linux              RightScale with Linu      0b11de9248dd4d87b18621318e037d37__RightImage-CentOS-6.2-x64-v5.8.8.1

      Linux              RightScale with Linu      0b11de9248dd4d87b18621318e037d37__RightImage-CentOS-6.3-x64-v5.8.8

      Linux              RightScale with Linu      0b11de9248dd4d87b18621318e037d37__RightImage-CentOS-6.3-x64-v5.8.8.5

      Linux              RightScale with Linu      0b11de9248dd4d87b18621318e037d37__RightImage-CentOS-6.3-x64-v5.8.8.6

      Linux              RightScale with Linu      0b11de9248dd4d87b18621318e037d37__RightImage-CentOS-6.3-x64-v5.8.8.7
    EOT
  end
end
