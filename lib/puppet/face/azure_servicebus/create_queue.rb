#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8

Puppet::Face.define :azure_servicebus, '1.0.0' do
  action :create_queue do

    summary 'Creates queue with service bus object.'

    description <<-'EOT'
      Creates queue with service bus object.
    EOT

    Puppet::ServiceBus.add_servicebus_queue_options(self)

    when_invoked do |options|
      Puppet::ServiceBus.initialize_env_variable(options)
      azure_service_bus = Azure::ServiceBusService.new
      azure_service_bus.create_queue(options[:queue_name]).inspect
    end

    returns 'NONE'

    examples <<-'EOT'
      $ puppet azure_servicebus create_queue --sb-namespace busname \
      --queue-name queuename  --sb-access-key dnD/E49P4SJG8UVEpABOeZRc=

    EOT
  end
end
