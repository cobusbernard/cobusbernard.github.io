# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

# Read YAML file with box details
server_configs = YAML.load_file('servers.yaml')

# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Iterate through entries in YAML file
  server_configs.each do |servers|
    config.vm.define servers["name"] do |srv|
      srv.vm.hostname = servers["name"]
      srv.vm.box = servers["box"]
      srv.vm.network "private_network", ip: servers["ip"]
      srv.vm.provider :virtualbox do |vb|
        vb.name = servers["name"]
        vb.memory = servers["ram"]
      end

      ports = servers["ports"]

	    ports.each do |prt|
		    srv.vm.network "forwarded_port", guest: prt.to_i, host: prt.to_i
	    end

      srv.vm.provision "shell", path: servers["provision_script"]
    end
  end
end
