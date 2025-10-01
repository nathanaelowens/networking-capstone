Install-Docker
=========

This role installs Docker either from the Debian/Ubuntu repositories, or from the Docker Engine official repository.

Requirements
------------

Server must be Debian, or Ubuntu, and ready to be used with ansible.

Role Variables
--------------

use_docker_repo: Whether to install docker using the docker engine repository, instead of defaulting to the distribution docker package (default: false)

Dependencies
------------

None.

Example Playbook
----------------

- name: Install docker
  hosts: all
  become: yes
  roles:
    - install-docker
      vars:
        use_docker_repo: true

License
-------

All Rights Reserved.

Author Information
------------------

Nathanael Owens, 2024
