firewalld-base
=========

This Ansible role automates the configuration of Firewalld on your servers, allowing you to define specific port configurations based on your requirements.

Requirements
------------

None.

Role Variables
--------------

firewall_open_ports: A list of ports to open.
firewall_closed_ports: A list of ports to close.
firewall_open_services: A list of firewalld-configured services to open.
firewall_closed_services: A list of firewalld-configured services to close.

Dependencies
------------

None.

Example Playbook
----------------

- hosts: all
  roles:
      - role: firewalld-base
        vars:
          firewall_open_ports:
            - '80/tcp'
          firewall_open_services:
            - 'OpenSSH'
          firewall_closed_ports:
            - '443/tcp'

License
-------

All Rights Reserved.

Author Information
------------------

Nathanael Owens, 2024
