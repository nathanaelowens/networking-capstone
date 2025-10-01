Role Name
=========

This role deploys a docker-compose file to a subfolder of the ansible_user's home directory, synchronizing a specific folder to include configuration files as well. It optionally also deploys a Dockerfile in the same location and builds it for docker-compose to work with it.

Requirements
------------

Requires docker, docker-compose, and the docker and docker-compose python modules. In addition, the ansible_user must be in the docker group. Rsync must be installed on both the controller and remote.

Role Variables
--------------

service_name: The name of the image to build with the Dockerfile, and of the overall system in memory

remote_path: The directory on the remote to synchronize the configuration folder to (default: "/home/{{ ansible_user }}/{{ service_name }}")

local_path: The file path to synchronize on the controller

delete: Whether or not to delete extraneous files when synchronizing config directory. May be useful if there are other files you want to download to that directory outside of this role, so they don't get deleted when the role syncs.

build_dockerfile (optional): true/false, determines whether a dockerfile is built as part of the deployment

Dependencies
------------

None.

Example Playbook
----------------

- name: Deploy test docker-compose
  hosts: all
  vars:
    - service_name: test
    - remote_path: /home/{{ ansible_user }}/test
    - local_path: test
    - build_dockerfile: true
  roles:
    - deploy-docker-compose

License
-------

All Rights Reserved.

Author Information
------------------

Nathanael Owens, 2024
