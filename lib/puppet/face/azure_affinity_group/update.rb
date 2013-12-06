Puppet::Face.define :azure_affinity_group, '0.0.1' do
  action :update do

    summary 'Update affinity group.'

    description <<-'EOT'
      The update action updates a affinity group.
    EOT

    Puppet::AffinityGroup.add_update_options(self)

    when_invoked do |options|
      Puppet::AffinityGroup.initialize_env_variable(options)
      affinity_group_service = Azure::BaseManagementService.new
      others = { :description => options[:description] }
      begin
        affinity_group_service.update_affinity_group(options[:affinity_group_name], options[:label], others)
      rescue Exception => e
        puts e.message
      end
    end

    examples <<-'EOT'
      $ puppet azure_affinity_group update --management-certificate path-to-azure-certificate \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID --label aglabel \
        --affinity-group-name agname --description 'Some Description'
    EOT
  end
end
