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

    Puppet::AzurePack::BootStrap.stubs(:start).with(anything)
  end

  describe 'option validation' do
    describe 'valid options' do      
    
      it 'should not raise any exception' do
        expect { subject.bootstrap(@options) }.to_not raise_error
      end
    end

    describe 'optional parameter validation' do
      describe '(winrm_user)' do
        it 'winrm_user should be optional' do
          @options.delete(:winrm_user)
          expect { subject.bootstrap(@options) }.to_not raise_error
        end
      end

      describe '(winrm_user and ssh_user)' do
        it 'should validate the ssh_user and winrm_user' do
          @options.delete(:ssh_user)
          @options.delete(:winrm_user)
          expect { subject.bootstrap(@options) }.to raise_error(
            ArgumentError,
            /winrm_user or ssh_user is required/
          )
        end
      end

      describe '(ssh_port and winrm_port)' do
        it 'should validate the ssh_port and winrm_port' do
          @options.delete(:ssh_port)
          @options.delete(:winrm_port)
          expect { subject.bootstrap(@options) }.to_not raise_error
        end
      end

      describe '(ssh_user)' do
        it 'ssh_user should be optional' do
          @options.delete(:ssh_user)
          expect { subject.bootstrap(@options) }.to_not raise_error
        end
      end
    end

  end
end
