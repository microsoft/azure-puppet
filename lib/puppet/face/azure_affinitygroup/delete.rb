
Puppet::Face.define :azure_affinitygroup, '0.0.1' do
  action :delete   do

    summary 'Delete affinity group.'

    description <<-'EOT'
      The delete action delete a affinity group.
    EOT

    Puppet::AffinityGroup.add_delete_options(self)

    when_invoked do |options|
      Puppet::AffinityGroup.initialize_env_variable(options)
      affinity_group_service = Azure::BaseManagementService.new      
      begin
        affinity_group_service.delete_affinity_group(options[:affinity_group_name])
      rescue Exception => e
        puts e.message
      end
    end

    examples <<-'EOT'
      $ puppet azure_affinitygroup delete --management-certificate path-to-azure-certificate \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID --affinity-group-name ag-name
    EOT
  end
end
