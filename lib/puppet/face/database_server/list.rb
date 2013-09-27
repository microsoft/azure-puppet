#-------------------------------------------------------------------------
# Copyright 2013 Microsoft Open Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------
require 'puppet/face/node_azure'

Puppet::Face.define :database_server, '0.0.1' do
  action :list do

    summary 'List SQL database servers.'
    arguments 'list'
    description <<-'EOT'
      The list action obtains a list of sql database servers and
      displays them on the console output.
    EOT

    Puppet::DatabasePack.add_default_options(self)

    when_invoked do |options|
      Puppet::DatabasePack.initialize_env_variable(options)
      db_server = Azure::Database::DatabaseService.new

      servers = db_server.list_servers
      puts Tilt.new(Puppet::DatabasePack.views('servers.erb'), 1, :trim => '%').render(nil, :db_servers => servers)
    end

    returns 'Array of database server objets.'

    examples <<-'EOT'
      $ puppet database_server list --management-certificate ~/exp/azuremanagement.pem\
        --azure-subscription-id=368a3-dcd0-4cd3 --management-endpoint=https://management.database.windows.net:8443/

    Listing Servers

      Server: 1
        Server Name         : esinlp9bav
        Administrator login : puppet3
        Location            : West US

      Server: 2
        Server Name         : estkonosnv
        Administrator login : puppet
        Location            : West US

      Server: 3
        Server Name         : ezprthvj9w
        Administrator login : puppet
        Location            : West US

    EOT
  end
end
