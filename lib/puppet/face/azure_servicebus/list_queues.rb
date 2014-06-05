#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require 'tilt'
require 'puppet/core/utility'

Puppet::Face.define :azure_servicebus, '1.0.0' do
  action :list_queues do

    summary 'List queues'

    description 'List queues'

    Puppet::ServiceBus.add_default_options(self)

    when_invoked do |options|
      Puppet::ServiceBus.initialize_env_variable(options)
      azure_service_bus = Azure::ServiceBusService.new
      queues =  azure_service_bus.list_queues
      template = Tilt.new(Puppet::ServiceBus.views('queues.erb'))
      template.render(nil, queues:  queues)
    end

    returns 'NONE'

    examples <<-'EOT'
      $  puppet azure_servicebus list_queues --sb-namespace busname \
         --sb-access-key GHdnD/E49P4SJG8UVEeABOeZRc=

    EOT
  end
end
