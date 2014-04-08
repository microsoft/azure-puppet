# encoding: UTF-8

Puppet::Face.define :azure_vm, '1.0.0' do
  action :update_endpoint do

    summary 'adds a data disk to a virtual machine.'

    description <<-'EOT'
      The add_disk action adds a data disk to a windows azure node instances.
    EOT

    Puppet::VirtualMachine.update_endpoint_options(self)

    when_invoked do |options|
      Puppet::VirtualMachine.initialize_env_variable(options)
      virtual_machine_service = Azure::VirtualMachineManagementService.new
      options[:protocol] ||= 'TCP'
      unless ['tcp','udp'].include?(options[:protocol].downcase)
        fail 'Protocol is invalid. Allowed values are tcp,udp'
      end
      options[:direct_server_return] ||= 'false'
      unless ['true','false'].include?(options[:direct_server_return].downcase)
        fail 'direct_server_return is invalid. Allowed values are true,false'
      end
      ep = {
        name: options[:endpoint_name],
        public_port: options[:public_port],
        local_port: options[:local_port],
        protocol: options[:protocol],
        load_balancer_name: options[:load_balancer_name],
        direct_server_return: options[:direct_server_return],
        load_balancer: {
          port: options[:load_balancer_port],
          protocol: options[:load_balancer_protocol],
          path: options[:load_balancer_path]
        }
      }
      virtual_machine_service.update_endpoints(
        options[:vm_name],
        options[:cloud_service_name],
        ep
      )
      nil
    end

    returns 'NONE'

    examples <<-'EOT'
      $ puppet azure_vm update_endpoint --subscription-id YOUR-SUBSCRIPTION-ID \
      --cloud-service-name cloudname --vm-name vmname --endpoint-name epname \
      --local-port 90 --public-port 91 --direct-server-return true \
      --load-balancer-name lbname --protocol udp

      $ puppet azure_vm update_endpoint --subscription-id YOUR-SUBSCRIPTION-ID \
      --cloud-service-name cloudname --vm-name vmname --endpoint-name epname
      --local-port 90 --public-port 91

    EOT
  end
end
