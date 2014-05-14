#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

# encoding: UTF-8
require 'spec_helper'

describe Puppet::Face[:azure_vm, :current] do

  before :each do
    @options = {
      ssh_user: 'root',
      winrm_user: 'Administrator',
      password: 'ComplexPassword123',
      winrm_port: 5985,
      ssh_port: 22,
      node_ipaddress: '100.10.1.1',
      puppet_master_ip: '127.0.0.1',
      winrm_transport: 'http',
      private_key_file: File.expand_path('spec/fixtures/private_key.key')
    }
  end

  describe 'option validation' do
    before :each do
      Puppet::AzurePack::BootStrap.stubs(:start).with(anything)
    end

    describe 'valid options' do
      it 'should raise exception when ssh_user and winrm_user is present' do
        expect { subject.bootstrap(@options) }.to raise_error(
          ArgumentError,
          /Either winrm_user or ssh_user is required/
        )
      end

      it 'should not raise error when ssh_user is given' do
        @options.delete(:winrm_user)
        expect { subject.bootstrap(@options) }.to_not raise_error
      end

      it 'should not raise error when winrm_user is given' do
        @options.delete(:ssh_user)
        expect { subject.bootstrap(@options) }.to_not raise_error
      end

      it 'should raise error when winrm_user and ssh_user is empty' do
        @options.delete(:ssh_user)
        @options.delete(:winrm_user)
        expect { subject.bootstrap(@options) }.to raise_error(
          ArgumentError,
          /Either winrm_user or ssh_user is required/
        )
      end
    end

    describe 'optional parameter validation' do
      describe '(puppet_master_ip)' do
        before :each do
          Puppet::AzurePack::BootStrap.stubs(:start).with(anything)
        end
        it 'puppet_master_ip should be optional' do
          @options.delete(:puppet_master_ip)
          expect { subject.bootstrap(@options) }.to raise_error(
            ArgumentError,
            /required: puppet_master_ip/
          )
        end
      end

      describe '(node_ipaddress)' do
        before :each do
          Puppet::AzurePack::BootStrap.stubs(:start).with(anything)
        end
        it 'puppet_master_ip should be optional' do
          @options.delete(:node_ipaddress)
          expect { subject.bootstrap(@options) }.to raise_error(
            ArgumentError,
            /required: node_ipaddress/
          )
        end
      end

      describe '(linux)' do
        before :each do
          @options = {
            ssh_user: 'root',
            password: 'ComplexPassword123',
            ssh_port: 22,
            node_ipaddress: '100.10.1.1',
            puppet_master_ip: '127.0.0.1',
            private_key_file: File.expand_path('spec/fixtures/private_key.key')
          }
          Puppet::AzurePack::BootStrap.stubs(:start).with(anything)
        end

        describe '(ssh_user)' do
          it 'should be mandatory' do
            @options.delete(:ssh_user)
            expect { subject.bootstrap(@options) }.to raise_error(
              ArgumentError,
              /Either winrm_user or ssh_user is required/
            )
          end
        end

        describe '(ssh_port)' do
          it 'should validate the ssh_port' do
            expect { subject.bootstrap(@options) }.to_not raise_error
          end
        end

        describe '(agent_environment)' do
          it 'should validate the agent_environment' do
            @options.delete(:agent_environment)
            expect { subject.bootstrap(@options) }.to_not raise_error
          end

          it 'should validate the agent_environment' do
            @options[:agent_environment] = 'development'
            expect { subject.bootstrap(@options) }.to_not raise_error
          end
        end

        describe '(private_key_file)' do
          it 'should be optional' do
            @options.delete(:private_key_file)
            expect { subject.bootstrap(@options) }.to_not raise_error
          end

          it 'private key or password is required for Linux' do
            @options.delete(:password)
            @options.delete(:private_key_file)
            expect { subject.bootstrap(@options) }.to raise_error(
              ArgumentError,
              /Password or Private key is require for bootstrap/
            )
          end
        end
      end

      describe '(windows)' do
        before :each do
          @options = {
            winrm_user: 'Administrator',
            password: 'ComplexPassword123',
            winrm_port: 5985,
            node_ipaddress: '100.10.1.1',
            puppet_master_ip: '127.0.0.1',
            winrm_transport: 'http'
          }
          Puppet::AzurePack::BootStrap.stubs(:start).with(anything)
        end

        describe '(password)' do
          it 'password is required for windows' do
            @options.delete(:password)
            expect { subject.bootstrap(@options) }.to raise_error(
              ArgumentError,
              /Password is require for windows vm bootstrap/
            )
          end
        end

        describe '(winrm_user)' do
          it 'should not be optional' do
            @options.delete(:winrm_user)
            expect { subject.bootstrap(@options) }.to raise_error(
              ArgumentError,
              /Either winrm_user or ssh_user is required/
            )
          end
        end

        describe '(winrm_transport)' do
          it 'winrm_transport should be optional' do
            @options.delete(:winrm_transport)
            expect { subject.bootstrap(@options) }.to_not raise_error
          end

          it 'should validate the winrm_transport' do
            @options[:winrm_transport] = 'ftp'
            expect { subject.bootstrap(@options) }.to raise_error(
              ArgumentError,
              /The winrm transport is not valid/
            )
          end

          it 'should validate the winrm_transport' do
            @options[:winrm_transport] = 'http'
            expect { subject.bootstrap(@options) }.to_not raise_error
          end

          it 'should validate the winrm_transport' do
            @options[:winrm_transport] = 'https'
            expect { subject.bootstrap(@options) }.to_not raise_error
          end
        end

        describe '(winrm_port)' do
          it 'should validate the winrm_port' do
            @options.delete(:winrm_port)
            expect { subject.bootstrap(@options) }.to_not raise_error
          end
        end
      end
    end
  end
end
