# -*- mode: ruby -*-
# vi: set ft=ruby :

domain = 'domain.com'
box = 'ubuntu/bionic64'
ram = 2048

puppet_nodes = [
  {:hostname => 'puppet',  :ip => '172.16.32.10', :box => box, :fwdhost => 8140, :fwdguest => 8140, :ram => ram},
  {:hostname => 'proxy', :ip => '172.16.32.12', :box => box, :ram => ram },
]

Vagrant.configure("2") do |config|
  puppet_nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|
      node_config.vm.box = node[:box]
      node_config.vm.box_url = 'https://vagrantcloud.com/' + node_config.vm.box
      node_config.vm.hostname = node[:hostname] + '.' + domain
      node_config.vm.network :private_network, ip: node[:ip]

      if node[:fwdhost]
        node_config.vm.network :forwarded_port, guest: node[:fwdguest], host: node[:fwdhost]
      end

      memory = node[:ram] ? node[:ram] : 256;
      node_config.vm.provider :virtualbox do |vb|
        vb.customize [
          'modifyvm', :id,
          '--name', node[:hostname],
          '--memory', memory.to_s
        ]
      end
      node_config.vm.provision "shell", inline: 'wget https://apt.puppetlabs.com/puppet-release-bionic.deb; dpkg -i puppet-release-bionic.deb ; apt-get update ; apt-get install -y puppet'
      node_config.vm.provision :puppet do |puppet|
        puppet.manifests_path = 'provision/manifests'
        puppet.module_path = 'provision/modules'
      end
      node_config.vm.provision "shell", inline: '/usr/bin/puppet agent --enable'
      node_config.vm.provision "shell", inline: '/usr/bin/puppet agent -t'
    end
  end
end
