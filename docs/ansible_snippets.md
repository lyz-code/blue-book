---
title: Ansible Snippets
date: 20220119
author: Lyz
---

# Set the ssh connection port using dynamic inventories
To specify a custom SSH port, you can use a `host_vars` or `group_vars` file. For example, create a `group_vars` directory and a file named `all.yaml` inside it:

```yaml
ansible_port: 2222  # Specify your SSH port here
```

# [Loop over dict fails when only one element detected](https://github.com/ansible/ansible/issues/73329)
If you see the `If you passed a list/dict of just one element, try adding wantlist=True to your lookup invocation or use q/query instead of lookup."` error in an Ansible log it means that the content of the variable is not the type you expect it to be. This can happen for example for lists that have only one or zero elements, which gets translated into a string thus breaking the `loop` structure.

So instead of:
```yaml
- name: Create filesystem on device
  community.general.filesystem:
    fstype: ext4
    dev: "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol{{ item.id | split('-') | last }}"
  loop: "{{ volumes }}"
```

You can use:

```yaml
- name: Create filesystem on device
  community.general.filesystem:
    fstype: ext4
    dev: "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol{{ item.id | split('-') | last }}"
  loop: "{{ lookup('list', volumes, wantlist=True) }}"
```

If that gives you issues you can use this other construction instead:

```yaml

- name: Save the required volume data
  set_fact:
    volumes: "{{ volume_tags_data | json_query('results[0].volumes[].{id: id, mount_point: tags.mount_point}') }}"

- name: Get result type for the volumes
  set_fact:
    volumes_type: "{{ volumes | type_debug }}"

- name: Display volumes type
  debug:
    msg: "{{ volumes_type }}"

# zero results
- name: Force list of volumes if it's a string
  set_fact:
    volumes: "{{ [] }}"
  when:
    - volumes_type == 'str'
    
# single result
- name: Force list of volumes if it's a dictionary
  set_fact:
    volumes: "{{ [volumes] }}"
  when:
    - volumes_type == 'dict'

- name: Create filesystem on device
  community.general.filesystem:
    fstype: ext4
    dev: "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol{{ item.id | split('-') | last }}"
  loop: "{{ volumes }}"
```

# [Filter json data](https://docs.ansible.com/ansible/latest/collections/community/general/docsite/filter_guide_selecting_json_data.html) 
To select a single element or a data subset from a complex data structure in JSON format (for example, Ansible facts), use the `community.general.json_query` filter. The `community.general.json_query` filter lets you query a complex JSON structure and iterate over it using a loop structure.


This filter is built upon jmespath, and you can use the same syntax. For examples, see [jmespath examples](http://jmespath.org/examples.html).

A complex example would be:

```yaml
"{{ ec2_facts | json_query('instances[0].block_device_mappings[?device_name!=`/dev/sda1` && device_name!=`/dev/xvda`].{device_name: device_name, id: ebs.volume_id}') }}"
```

This snippet:

- Gets all dictionaries under the block_device_mappings list which `device_name` is not equal to `/dev/sda1` or `/dev/xvda` 
- From those results it extracts and flattens only the desired values. In this case `device_name` and the `id` which is at the key `ebs.volume_id` of each of the items of the block_device_mappings list.

# [Do asserts](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/assert_module.html) 
```yaml 
- name: After version 2.7 both 'msg' and 'fail_msg' can customize failing assertion message
  ansible.builtin.assert:
    that:
      - my_param <= 100
      - my_param >= 0
    fail_msg: "'my_param' must be between 0 and 100"
    success_msg: "'my_param' is between 0 and 100"
```

# [Split a variable in ansible ](https://www.middlewareinventory.com/blog/ansible-split-examples/) 

```yaml
{{ item | split ('@') | last }}

```

# Get a list of EC2 volumes mounted on an instance an their mount points
Assuming that each volume has a tag `mount_point` you could:

```yaml
- name: Gather EC2 instance metadata facts
  amazon.aws.ec2_metadata_facts:

- name: Gather info on the mounted disks
  delegate_to: localhost
  block:
    - name: Gather information about the instance
      amazon.aws.ec2_instance_info:
        instance_ids:
          - "{{ ansible_ec2_instance_id }}"
      register: ec2_facts

    - name: Gather volume tags
      amazon.aws.ec2_vol_info:
        filters:
          volume-id: "{{ item.id }}"
      # We exclude the root disk as they are already mounted and formatted
      loop: "{{ ec2_facts | json_query('instances[0].block_device_mappings[?device_name!=`/dev/sda1` && device_name!=`/dev/xvda`].{device_name: device_name, id: ebs.volume_id}') }}"
      register: volume_tags_data

    - name: Save the required volume data
      set_fact:
        volumes: "{{ volume_tags_data | json_query('results[0].volumes[].{id: id, mount_point: tags.mount_point}') }}"

    - name: Display volumes data
      debug:
        msg: "{{ volumes }}"

    - name: Make sure that all volumes have a mount point
      assert:
        that:
          - item.mount_point is defined
          - item.mount_point|length > 0
        fail_msg: "Configure the 'mount_point' tag on the volume {{ item.id }} on the instance {{ ansible_ec2_instance_id }}"
        success_msg: "The volume {{ item.id }} has the mount_point tag well set"
      loop: "{{ volumes }}"
```
# [Create a list of dictionaries using ansible ](https://www.middlewareinventory.com/blog/ansible-dict/) 

```yaml 
- name: Create and Add items to dictionary
  set_fact: 
      userdata: "{{ userdata | default({}) | combine ({ item.key : item.value }) }}"
  with_items:
    - { 'key': 'Name' , 'value': 'SaravAK'}
    - { 'key': 'Email' , 'value': 'sarav@gritfy.com'}
    - { 'key': 'Location' , 'value': 'Coimbatore'}
    - { 'key': 'Nationality' , 'value': 'Indian'}
```
# [Merge two dictionaries on a key ](https://stackoverflow.com/questions/70627339/merging-two-list-of-dictionaries-according-to-a-key-value-in-ansible) 

If you have these two lists:

```yaml
"list1": [
  { "a": "b", "c": "d" },
  { "a": "e", "c": "f" }
]

"list2": [
  { "a": "e", "g": "h" },
  { "a": "b", "g": "i" }
]
```
And want to merge them using the value of key "a":

```yaml
"list3": [
  { "a": "b", "c": "d", "g": "i" },
  { "a": "e", "c": "f", "g": "h" }
]
```

If you can install the collection community.general use the filter lists_mergeby. The expression below gives the same result

```yaml
list3: "{{ list1|community.general.lists_mergeby(list2, 'a') }}"
```
# [Avoid arbitrary disk mount](https://forum.ansible.com/t/aws-determine-ebs-volume-physical-name-in-order-to-format-it/2510) 

Instead of using `/dev/sda` use `/dev/disk/by-id/whatever`
# [Get the user running ansible in the host ](https://stackoverflow.com/questions/26394096/how-do-i-get-a-variable-with-the-name-of-the-user-running-ansible) 

If you `gather_facts` use the `ansible_user_id` variable.

# [Set host variables using a dynamic inventory](https://stackoverflow.com/questions/40212986/ansible-ec2-dynamic-inventory-with-host-vars)
As with a normal inventory you can use the `host_vars` files with the proper name.

# Fix the `ERROR! 'become' is not a valid attribute for a IncludeRole` error


If you're trying to do something like:
```yaml
tasks:
  - name: "Install nfs"
    become: true
    ansible.builtin.include_role:
      name: nfs
```

You need to use this other syntax:

```yaml
tasks:
  - name: "Install nfs"
    ansible.builtin.include_role:
      name: nfs
      apply:
        become: true
```

# [Ansible lint skip some rules](https://ansible.readthedocs.io/projects/lint/configuring/#ansible-lint-configuration)

Add a `.ansible-lint-ignore` file with a line per rule to ignore with the syntax `path/to/file rule_to_ignore`.

# [Ansible retry a failed job](https://stackoverflow.com/questions/44134642/how-to-retry-ansible-task-that-may-fail)

```yaml
- command: /usr/bin/false
  retries: 3
  delay: 3
  register: result
  until: result.rc == 0
```

# Ansible add a sleep

```yaml
- name: Pause for 5 minutes to build app cache
  ansible.builtin.pause:
    minutes: 5
```

# Ansible condition that uses a regexp

```yaml
- name: Check if an instance name or hostname matches a regex pattern
  when: inventory_hostname is not match('molecule-.*')
  fail:
    msg: "not a molecule instance"
```

# Ansible-lint doesn't find requirements

It may be because you're using `requirements.yaml` instead of `requirements.yml`. Create a temporal link from one file to the other, run the command and then remove the link.

It will work from then on even if you remove the link. `¯\(°_o)/¯`

# [Run task only once](https://stackoverflow.com/questions/55481560/how-to-run-an-ansible-task-only-once-regardless-of-how-many-targets-there-are)

Add `run_once: true` on the task definition:

```yaml
- name: Do a thing on the first host in a group.
  debug: 
    msg: "Yay only prints once"
  run_once: true
```

# Run command on a working directory

```yaml
- name: Change the working directory to somedir/ and run the command as db_owner 
  ansible.builtin.command: /usr/bin/make_database.sh db_user db_name
  become: yes
  become_user: db_owner
  args:
    chdir: somedir/
    creates: /path/to/database
```

# [Run handlers in the middle of the tasks file](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html#controlling-when-handlers-run)

If you need handlers to run before the end of the play, add a task to flush them using the [meta module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html#meta-module), which executes Ansible actions:

```yaml
tasks:
  - name: Some tasks go here
    ansible.builtin.shell: ...

  - name: Flush handlers
    meta: flush_handlers

  - name: Some other tasks
    ansible.builtin.shell: ...
```

The `meta: flush_handlers` task triggers any handlers that have been notified at that point in the play.

Once handlers are executed, either automatically after each mentioned section or manually by the `flush_handlers meta` task, they can be notified and run again in later sections of the play.

# [Run command idempotently](https://stackoverflow.com/questions/70956356/no-changed-when-lint-warning-araise-in-the-ansible-playbook)

```yaml
- name: Register the runner in gitea
  become: true
  command: act_runner register --config config.yaml --no-interactive --instance {{ gitea_url }} --token {{ gitea_docker_runner_token }}
  args:
    creates: /var/lib/gitea_docker_runner/.runner
```

# Get the correct architecture string

If you have an `amd64` host you'll get `x86_64`, but sometimes you need the `amd64` string. On those cases you can use the next snippet:

```yaml
---
# vars/main.yaml
deb_architecture: 
  aarch64: arm64
  x86_64: amd64

---
# tasks/main.yaml
- name: Download the act runner binary
  become: True
  ansible.builtin.get_url:
    url: https://dl.gitea.com/act_runner/act_runner-linux-{{ deb_architecture[ansible_architecture] }}
    dest: /usr/bin/act_runner
    mode: '0755'
```

# [Check the instances that are going to be affected by playbook run](https://medium.com/geekculture/a-complete-overview-of-ansible-dynamic-inventory-a9ded104df4c)

Useful to list the instances of a dynamic inventory

```bash
ansible-inventory -i aws_ec2.yaml --list
```

# [Check if variable is defined or empty](https://www.shellhacks.com/ansible-when-variable-is-defined-exists-empty-true/)

In Ansible playbooks, it is often a good practice to test if a variable exists and what is its value.

Particularity this helps to avoid different “VARIABLE IS NOT DEFINED” errors in Ansible playbooks.

In this context there are several useful tests that you can apply using [Jinja2 filters](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html) in Ansible.

## Check if Ansible variable is defined (exists)

```yaml
tasks:

- shell: echo "The variable 'foo' is defined: '{{ foo }}'"
  when: foo is defined

- fail: msg="The variable 'bar' is not defined"
  when: bar is undefined
```

## Check if Ansible variable is empty

```yaml
tasks:

- fail: msg="The variable 'bar' is empty"
  when: bar|length == 0

- shell: echo "The variable 'foo' is not empty: '{{ foo }}'"
  when: foo|length > 0
```

## Check if Ansible variable is defined and not empty

```yaml
tasks:

- shell: echo "The variable 'foo' is defined and not empty"
  when: (foo is defined) and (foo|length > 0)

- fail: msg="The variable 'bar' is not defined or empty"
  when: (bar is not defined) or (bar|length == 0)
```

# Start and enable a systemd service

Typically defined in `handlers/main.yaml`:

```yaml
- name: Restart the service
  become: true
  systemd:
    name: zfs_exporter
    enabled: true
    daemon_reload: true
    state: started
```

And used in any task:

```yaml
- name: Create the systemd service
  become: true
  template:
    src: service.j2
    dest: /etc/systemd/system/zfs_exporter.service
  notify: Restart the service
```

# [Download a file](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/get_url_module.html)

```yaml
- name: Download foo.conf
  ansible.builtin.get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    mode: '0440'
```
# [Download an decompress a tar.gz](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/unarchive_module.html)

```yaml
- name: Unarchive a file that needs to be downloaded (added in 2.0)
  ansible.builtin.unarchive:
    src: https://example.com/example.zip
    dest: /usr/local/bin
    remote_src: yes
```

If you want to only extract a file you can use the `includes` arg

```yaml
- name: Download the zfs exporter
  become: true
  ansible.builtin.unarchive:
    src: https://github.com/pdf/zfs_exporter/releases/download/v{{ zfs_exporter_version }}/zfs_exporter-{{ zfs_exporter_version }}.linux-amd64.tar.gz
    dest: /usr/local/bin
    include: zfs_exporter
    remote_src: yes
    mode: 0755
```

But that snippet sometimes fail, you can alternatively download it locally and `copy` it:

```yaml
- name: Test if zfs_exporter binary exists
  stat:
    path: /usr/local/bin/zfs_exporter
  register: zfs_exporter_binary

- name: Install the zfs exporter
  block:
    - name: Download the zfs exporter
      delegate_to: localhost
      ansible.builtin.unarchive:
        src: https://github.com/pdf/zfs_exporter/releases/download/v{{ zfs_exporter_version }}/zfs_exporter-{{ zfs_exporter_version }}.linux-amd64.tar.gz
        dest: /tmp/
        remote_src: yes

    - name: Upload the zfs exporter to the server
      become: true
      copy:
        src: /tmp/zfs_exporter-{{ zfs_exporter_version }}.linux-amd64/zfs_exporter
        dest: /usr/local/bin
        mode: 0755
  when: not zfs_exporter_binary.stat.exists
```
# [Skip ansible-lint for some tasks](https://github.com/ansible/ansible-lint/pull/40)

```yaml
- name: Modify permissions
  command: >
    chmod -R g-w /home/user
  tags:
    - skip_ansible_lint
  sudo: yes
```

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
  stat: 
    path: /path/to/foo
  register: foo_stat

- name: Move foo to bar
  command: mv /path/to/foo /path/to/bar
  when: foo_stat.stat.exists
```
