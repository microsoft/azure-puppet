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
require 'puppet/databasepack'
require 'puppet/face'

Puppet::Face.define(:database_server, '0.0.1') do
  copyright "Windows Azure", 2013
  license   "Microsoft Open Technologies, Inc; see COPYING"

  summary "View and manage Window Azure database servers."
  description <<-'EOT'
    This subcommand provides a command line interface to work with Windows Azure
    machine instances.  The goal of these actions are to easily create new
    database servers.
  EOT

end
