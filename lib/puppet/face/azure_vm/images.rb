require 'tilt'

Puppet::Face.define :azure_vm, '1.0.0' do
  action :images do

    summary 'List Windows Azure images'
    #arguments 'NONE'
    description <<-'EOT'
      The images action obtains a list of images from the cloud provider and
      displays them on the console output.  
    EOT

    Puppet::VirtualMachine.add_default_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      virtual_machine_image_service = Azure::VirtualMachineImageManagementService.new
      images = virtual_machine_image_service.list_virtual_machine_images
      puts Tilt.new(Puppet::VirtualMachine.views('images.erb'), 1, :trim => '%').render(nil, :images => images)
    end
    
    returns 'Array of attribute hashes containing information about each Azure images.'

    examples <<-'EOT'
      $ puppet azure_vm images --publish-settings-file azuremanagement.publishsettings --azure-subscription-id ID
      OS Type      OS Nmae
      Windows :  2cdc6229df6344129ee553dd3499f0d3__BizTalk-Server-2013-Beta
      Windows :  2cdc6229df6344129ee553dd3499f0d3__BizTalk-Server-2013-Beta-February-2013
      Linux   :  5112500ae3b842c8b9c604889f8753c3__OpenLogic-CentOS63JAN20130122
    EOT
  end
end
