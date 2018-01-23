# -*- encoding: utf-8 -*-

#
# Author:: Andrei Skopenko (<andrei@skopenko.net>)
#
# Copyright 2015 Andrei Skopenko
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'kitchen/provisioner/chef_zero'
require 'kitchen/provisioner/base'
require 'kitchen/driver/ssh_base'
require 'kitchen/transport/ssh'
require 'kitchen/transport/winrm'

# continue loading if kitchen-sync not installed
begin
  require 'kitchen/transport/sftp'
rescue LoadError
  puts 'Ignoring sftp transport...'
end

module Kitchen
  module Driver
    class SSHBase
      # ChefZeroNodes needs to access to legacy_ssh_base_converge method
      # used by some drivers like kithen-vz. This method
      # add additional command after chef_client run complete.
      #
      # @param state [Hash] mutable instance state
      # @raise [ActionFailed] if the action could not be completed
      def converge(state)
        provisioner = instance.provisioner
        provisioner.create_sandbox
        sandbox_dirs = Util.list_directory(provisioner.sandbox_path)
        instance.transport.connection(backcompat_merged_state(state)) do |conn|
          conn.execute(env_cmd(provisioner.install_command))
          conn.execute(env_cmd(provisioner.init_command))
          info("Transferring files to #{instance.to_str}")
          conn.upload(sandbox_dirs, provisioner[:root_path])
          debug('Transfer complete')
          conn.execute(env_cmd(provisioner.prepare_command))
          conn.execute(env_cmd(provisioner.run_command))
          # Change perms for node json object, by default it has 600 perms
          int_node_file = windows_os? ? provisioner.win_int_node_file : provisioner.unix_int_node_file
          info("Change permissions for #{int_node_file}")
          conn.execute(env_cmd("sudo chmod +r #{int_node_file}"))
          # Download node json object generated by chef_client
          info("Transferring #{int_node_file} " \
               "from instance to #{provisioner.ext_node_file}")
          conn.execute(env_cmd(conn.download(int_node_file,
                                             provisioner.ext_node_file)))
          debug('Transfer complete')
        end
      rescue Kitchen::Transport::TransportFailed => ex
        raise ActionFailed, ex.message
      ensure
        instance.provisioner.cleanup_sandbox
      end
    end
  end
end

module Kitchen
  module Transport
    class Ssh
      class Connection
        # Download JSON node file from instance to
        # node_path over SCP
        #
        # @param remote [String] file path on instance
        # @param local [String] file path on host
        def download(remote, local)
          FileUtils.mkdir_p(File.dirname(local))
          session.scp.download!(remote, local, {})
          logger.debug("Downloaded #{remote} to #{local}")
        rescue Net::SSH::Exception => ex
          raise SshFailed, "SCP download failed (#{ex.message})"
        end
      end
    end
  end
end

module Kitchen
  module Transport
    class Winrm
      class Connection
        # Download JSON node file from instance to
        # node_path over Winrm
        #
        # @param remote [String] file path on instance
        # @param local [String] file path on host
        # TODO need to fix scheme
        def download(remote, local)
          FileUtils.mkdir_p(File.dirname(local))
          file_manager ||= WinRM::FS::FileManager.new(service)
          file_manager.download(remote, local)
          logger.debug("Downloaded #{remote} to #{local}")
        rescue Kitchen::Transport::WinrmFailed => ex
          raise WinrmFailed, "Winrm download failed (#{ex.message})"
        end
      end
    end
  end
end

module Kitchen
  module Provisioner
    class Base
      # ChefZeroNodes needs to access to provision of the instance
      # without invoking the behavior of Base#call because we need to
      # add additional command after chef_client run complete.
      #
      # @param state [Hash] mutable instance state
      # @raise [ActionFailed] if the action could not be completed
      def call(state)
        create_sandbox
        sandbox_dirs = Dir.glob(File.join(sandbox_path, '*'))

        instance.transport.connection(state) do |conn|
          conn.execute(install_command)
          conn.execute(init_command)
          info("Transferring files to #{instance.to_str}")
          conn.upload(sandbox_dirs, config[:root_path])
          debug('Transfer complete')
          conn.execute(prepare_command)
          conn.execute(run_command)
          # Download node json object generated by chef_client
          int_node_file = windows_os? ? win_int_node_file : unix_int_node_file
          info("Change permissions for #{int_node_file}")
          conn.execute("sudo chmod +r #{int_node_file}")
          info("Transferring #{int_node_file} " \
               "from instance to #{ext_node_file}")
          conn.download(int_node_file, ext_node_file)
          debug('Transfer complete')
        end
      rescue Kitchen::Transport::TransportFailed => ex
        raise ActionFailed, ex.message
      ensure
        cleanup_sandbox
      end
    end

    class ChefZero
      # ChefZeroNodes needs to access the base behavior of creating the
      # sandbox directory without invoking the behavior of
      # ChefZero#create_sandbox, we need to override json node.
      alias create_chefzero_sandbox create_sandbox
    end

    class ChefZeroNodes < ChefZero
      # (see ChefZero#create_sandbox)
      def create_sandbox
        if config[:nodes_path].nil?
          info("Provisioner setting 'nodes_path' is not defined! Using 'test/fixtures/nodes' for node objects!")
          config[:nodes_path] = 'test/fixtures/nodes'
        end
        FileUtils.rm(ext_node_file) if File.exist?(ext_node_file)
        create_chefzero_sandbox
      end

      def ext_node_file
        File.join(config[:nodes_path], "#{instance.name}.json")
      end

      def unix_int_node_file
        File.join(config[:root_path], 'nodes', "#{instance.name}.json")
      end

      def win_int_node_file
        File.join(config[:root_path], 'nodes', "#{instance.name}.json").tr('/', '\\')
      end
    end
  end
end
