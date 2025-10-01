Role Name
=========

This role configures a Debian server with basic settings for my general usage. Installation of docker and tailscale are optional.

Requirements
------------

Server must be Debian 11 or 12, and ready to be used with ansible.

Role Variables
--------------

cloud_init: Whether cloud-init has been used to configure the node, meaning that some config features don't need to be done in ansible (default: true)

avahi: Whether or not to install install and enable the avahi-daemon for zeroconf (default: false)

networkd: Whether or not to use networkd templates to configure networking or leave the network as-is (default: false)

ifname: *eth* or *en*, the general name of the primary network interface to configure with systemd-networkd

ip: The IP to configure the system with statically

hostname: The hostname -- *non-FQDN* -- for the system

fqdn: The FQDN of the system, including the hostname

Dependencies
------------

None.

Example Playbook
----------------

- name: Basic system configuration
  hosts: all
  become: yes
  roles:
    - role: debian-base
      vars:
        networkd: true
        ifname: en
        ip: 192.168.1.12
        hostname: homeserver
        fqdn: homeserver.home.example.com

License
-------

All Rights Reserved.

Author Information
------------------

Nathanael Owens, 2024
