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
require 'puppet/cloudpack/bootstrap'

Puppet::Face.define :database_server, '0.0.1' do
  action :create do

    summary 'Create SQL database server.'

    description <<-'EOT'
      The create action create a SQL database server.
    EOT

    Puppet::DatabasePack.add_create_options(self)

    when_invoked do |options|
      Puppet::DatabasePack.initialize_env_variable(options)
      db = Azure::Database::DatabaseService.new
      servers = db.create_server(options[:login], options[:password], options[:location])
      puts Tilt.new(Puppet::DatabasePack.views('servers.erb'), 1, :trim => '%').render(nil, :db_servers => servers) if servers
    end

    examples <<-'EOT'
      $ puppet database_server create --management-certificate ~/exp/azuremanagement.pem\
        --azure-subscription-id=ABCD1234 --login puppet --location 'West Us'\
        --management-endpoint=https://management.database.windows.net:8443/ --password Ranjan@123
    EOT
  end
end
