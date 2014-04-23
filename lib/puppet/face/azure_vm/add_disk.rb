# encoding: UTF-8

Puppet::Face.define :azure_vm, '1.0.0' do
  action :add_disk do

    summary 'adds a data disk to a virtual machine.'

    description <<-'EOT'
      The add_disk action adds a data disk to a windows azure node instances.
    EOT

    Puppet::VirtualMachine.add_data_disk_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      virtual_machine_service = Azure::VirtualMachineManagementService.new
      others = {
        import: options[:import],
        disk_label: options[:disk_label],
        disk_size: options[:disk_size],
        disk_name: options[:disk_name]
      }
      others[:lun] = options[:lun] if options[:lun]
      virtual_machine_service.add_data_disk(
        options[:vm_name],
        options[:cloud_service_name],
        others
      )
      nil
    end

    returns 'NONE'

    examples <<-'EOT'
      $ puppet azure_vm add_disk --vm-name vmname --lun 5 --import true \
      --cloud-service-name cloudname --disk-name disk_name \
      --management-certificate path-to-azure-certificate \
      --subscription-id YOUR-SUBSCRIPTION-ID \

      $ puppet azure_vm add_disk --cloud-service-name cloud_name --lun 5 \
      --management-certificate path-to-azure-certificate --vm-name vmname \
      --subscription-id YOUR-SUBSCRIPTION-ID

    EOT
  end
end
