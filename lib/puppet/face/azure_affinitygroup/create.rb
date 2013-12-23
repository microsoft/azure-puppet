
Puppet::Face.define :azure_affinitygroup, '1.0.0' do
  action :create do

    summary 'Create affinity group.'

    description <<-'EOT'
      The create action create a affinity group.
    EOT

    Puppet::AffinityGroup.add_create_options(self)

    when_invoked do |options|
      Puppet::AffinityGroup.initialize_env_variable(options)
      affinity_group_service = Azure::BaseManagementService.new
      others = { description:  options[:description] }
      begin
        affinity_group_service.create_affinity_group(options[:affinity_group_name], options[:location], options[:label], others)
      rescue Exception => e
        puts e.message
      end
    end

    examples <<-'EOT'
      $ puppet azure_affinitygroup create --management-certificate path-to-azure-certificate \
        --azure-subscription-id YOUR-SUBSCRIPTION-ID --location 'West Us' --label aglabel\
        --affinity-group-name agname --description 'Some Description'
    EOT
  end
end
