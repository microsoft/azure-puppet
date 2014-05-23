#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
Puppet::Face.define :azure_queue, '1.0.0' do
  action :create do

    summary 'Creates a queue with a valid name.'
    arguments 'list'
    description <<-'EOT'
      The create action creates a queue under the given account.
    EOT

    Puppet::ServiceBus.add_create_queue_options(self)

    when_invoked do |options|
      Puppet::ServiceBus.initialize_env_variable(options)
      azure_queue_service = Azure::QueueService.new
      azure_queue_service.create_queue(options[:queue_name])
    end

    returns 'NONE'

    examples <<-'EOT'
      $  puppet azure_queue create --storage-account-name mystorageacc \
         --storage-access-key 'hLlPCq751UBzcfn9AR3YWHXJu4m+A=='
         --queue-name queuename
    EOT

  end
end
