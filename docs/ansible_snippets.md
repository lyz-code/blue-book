---
title: Ansible Snippets
date: 20220119
author: Lyz
---

# [Authorize an SSH key](https://docs.ansible.com/ansible/latest/collections/ansible/posix/authorized_key_module.html)

```yaml
- name: Authorize the sender ssh key
  authorized_key:
    user: syncoid
    state: present
    key: "{{ syncoid_receive_ssh_key }}"
```

# [Create a user](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html)

The following snippet creates a user with password login disabled.

```yaml
- name: Create the syncoid user
  ansible.builtin.user:
    name: syncoid
    state: present
    password: !
    shell: /usr/sbin/nologin
```

If you don't set a password any user can do `su your_user` to set a random password use the next snippet:

```yaml
- name: Create the syncoid user
  ansible.builtin.user:
    name: syncoid
    state: present
    password: "{{ lookup('password', '/dev/null', length=50, encrypt='sha512_crypt') }}"
    shell: /bin/bash
```

This won't pass the idempotence tests as it doesn't save the password anywhere (`/dev/null`) in the controler machine.

# [Create an ssh key](https://docs.ansible.com/ansible/2.9/modules/openssh_keypair_module.html)

```yaml
- name: Create .ssh directory
  become: true
  file:
    path: /root/.ssh
    state: directory
    mode: 700

- name: Create the SSH key to directory
  become: true
  openssh_keypair:
    path: /root/.ssh/id_ed25519
    type: ed25519
  register: ssh

- name: Show public key
  debug:
    var: ssh.public_key
```

# [Get the hosts of a dynamic ansible inventory](https://www.educba.com/ansible-dynamic-inventory/)

```bash
ansible-inventory -i environments/production --graph
```

You can also use the `--list` flag to get more info of the hosts.

# [Speed up the stat module](https://justinmontgomery.com/speed-up-stat-command-in-ansible)

The `stat` module calculates the checksum and the md5 of the file in order to
get the required data. If you just want to check if the file exists use:

```yaml
- name: Verify swapfile status
  stat:
    path: "{{ common_swapfile_location }}"
    get_checksum: no
    get_md5: no
    get_mime: no
    get_attributes: no
  register: swap_status
  changed_when: not swap_status.stat.exists
```

# [Stop running docker containers](https://stackoverflow.com/questions/61680945/stopping-all-existing-docker-containers-with-ansible)

```yaml
- name: Get running containers
  docker_host_info:
    containers: yes
  register: docker_info

- name: Stop running containers
  docker_container:
    name: "{{ item }}"
    state: stopped
  loop: "{{ docker_info.containers | map(attribute='Id') | list }}"
```

# [Moving a file remotely](https://stackoverflow.com/questions/24162996/how-to-move-rename-a-file-using-an-ansible-task-on-a-remote-system)

Funnily enough, you can't without a `command`. You could use the `copy` module
with:

```yaml
- name: Copy files from foo to bar
  copy:
    remote_src: True
    src: /path/to/foo
    dest: /path/to/bar

- name: Remove old files foo
  file: path=/path/to/foo state=absent
```

But that doesn't move, it copies and removes, which is not the same.

To make the `command` idempotent you can use a `stat` task before.

```yaml
- name: stat foo
  stat: path=/path/to/foo
  register: foo_stat

- name: Move foo to bar
  command: mv /path/to/foo /path/to/bar
  when: foo_stat.stat.exists
```
