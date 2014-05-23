#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
Puppet::Face.define :azure_queue, '1.0.0' do
  action :create_message do

    summary 'Creates a message in the specified queue.'
    arguments 'list'
    description <<-'EOT'
      Creates a message in the specified queue.
    EOT

    Puppet::ServiceBus.add_create_message_options(self)
    when_invoked do |options|
      Puppet::ServiceBus.initialize_env_variable(options)
      azure_queue_service = Azure::QueueService.new
      azure_queue_service.create_queue(options[:queue_name])
      azure_queue_service.create_message(options[:queue_name], options[:queue_message])
    end

    returns 'NONE'

    examples <<-'EOT'
      $  puppet azure_queue create_message --storage-account-name mystorageacc \
         --storage-access-key 'hLlPCq751UBzcfn9AR3YWHXJu4m+A=='
         --queue-name queuename  --queue-message 'Text Message'

    EOT
  end
end
