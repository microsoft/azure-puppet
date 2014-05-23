#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
Puppet::Face.define :azure_servicebus, '1.0.0' do
  action :create_topic   do

    summary 'Create topic with service bus object.'

    description <<-'EOT'
      Create topic with service bus object.
    EOT

    Puppet::ServiceBus.add_servicebus_topic_options(self)

    when_invoked do |options|
      Puppet::ServiceBus.initialize_env_variable(options)
      azure_service_bus = Azure::ServiceBusService.new
      azure_service_bus.create_topic(options[:topic_name]).inspect
    end

    returns 'NONE'

    examples <<-'EOT'
      $ puppet azure_servicebus create_topic --sb-namespace busname \
      --topic-name 'topic name' --sb-access-key 4XJib8UcKEu8VG8UVEpABOeZRc=

    EOT
  end
end
