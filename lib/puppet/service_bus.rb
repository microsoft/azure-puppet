module Puppet::ServiceBus

  class << self
    def initialize_env_variable(options)
      ENV['AZURE_SERVICEBUS_NAMESPACE']  = options[:sb_namespace]
      ENV['AZURE_SERVICEBUS_ACCESS_KEY'] = options[:sb_access_key]
      gem "azure", '=0.6.4'
      require 'azure'
    end

    def add_default_options(action)
      add_sb_namespace_option(action)
      add_sb_access_key_option(action)
    end
    
    def add_create_queue_options(action)
      add_default_options(action)
      add_queue_name_option(action)
    end

    def add_sb_namespace_option(action)
      action.option '--sb-namespace=' do
        summary 'The subscription identifier for the Windows Azure portal.'
        description 'The subscription identifier for the Windows Azure portal.'
        required        
      end
    end

    def add_sb_access_key_option(action)
      action.option '--sb-access-key=' do
        summary 'The subscription identifier for the Windows Azure portal.'
        description 'The subscription identifier for the Windows Azure portal.'
        required       
      end
    end

    def add_queue_name_option(action)
      action.option '--queue-name=' do
        summary 'The subscription identifier for the Windows Azure portal.'
        description 'The subscription identifier for the Windows Azure portal.'
        required
      end
    end
    
  end
end
