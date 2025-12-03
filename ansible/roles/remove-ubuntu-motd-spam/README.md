Role Name
=========

This role removes the spam from the Ubuntu MOTD message.

Requirements
------------

None. Just using Ubuntu. ;)

Role Variables
--------------

None.

Dependencies
------------

None.

Example Playbook
----------------

- name: Clear MOTD spam
  hosts: all
  roles:
    - role: remove-ubuntu-motd-spam
      vars:
        ubuntu_motd_disable_news: true
        ubuntu_motd_disable_scripts:
          - 10-help-text
          - 50-motd-news
          - 80-livepatch
          - 91-release-upgrade
          - 95-hwe-eol
          - 99-esm
        ubuntu_motd_static_banner_enabled: false
        ubuntu_motd_static_banner_text: "Authorized access only. Activity may be monitored.\n"

License
-------

All Rights Reserved.

Author Information
------------------

A human.
