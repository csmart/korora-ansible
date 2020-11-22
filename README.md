This is an example Ansible playbook for the [Korora Ansible
role](https://github.com/csmart/ansible-role-korora).

# What does this do?

This Ansible playbook applies settings used in the Korora distribution on
a stock Fedora install. Users can also modify the settings to their liking,
making it a simple and repeatable way to get a customised Fedora system on any
number of machines.

It will do things like:

* Configure SELinux (enable by default)
* Modify authentication (e.g. enable fingerprint readers)
* Modify the firewall (e.g. enable mDNS, SSH, Samba)
* Enable repos like RPMFusion, Flathub, Google Chrome and Copr
* Install and remove packages
* Enable and disable services
* Apply Korora system tweaks and desktop look and feel

<img src="desktop.jpg" alt="Fedora Workstation" width="640" height="480">

# Requirements

Currently this requires:

* Fedora 32 or later (Workstation and base cloud image are both supported)
* Active Internet connection
* User with sudo privileges
* SSH access to remote hosts if not running against localhost
* `git` and `ansible` packages installed:
  - `sudo dnf install ansible git`

Note that Git is installed by default in Fedora Workstation and simply running
the `ansible-playbook` command should prompt to install Ansible. So technically
you shouldn't need to manually install these packages, but they are
dependencies.

Note if you run into an error with systemd on Fedora 32 where "Service is in
unknown state" then please ensure you update systemd to >= 245.7. See here for
details:
https://github.com/ansible/ansible/issues/71528

# Getting the code

Clone this repository recursively and it will pull in the role automatically.

```bash
git clone --recursive https://github.com/csmart/korora-ansible
```

Once cloned, run the playbook from the korora-ansible directory. There is
a `run.sh` shell script to make this easy, which runs against localhost by
default using the included sample inventory file.

```bash
cd korora-ansible
./run.sh
```

## Updating the code

You can pull in updates to the playbook and role with Git.

```bash
cd korora-ansible
git pull origin master && git submodule update
```

# Ansible inventory

Ansible requires an [inventory
file](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)
which contains the details of the computers you want to run the playbook
against, as well as any custom variables for them.

There is a sample inventory file included in this repository which contains an
entry for `localhost`. So if you just want to run this playbook against your
current machine, you can use the default inventory file.

If you want to manage other machines, then you will need to add them to the
inventory file yourself.

## Sample inventory files

There is a sample `ini` style inventory file at `./inventory/hosts` and
a sample `YAML` inventory file at `./inventory/hosts.yml`.

The `ini` file is more simple and ideal if you just want to manage a number of
hosts, without much customisation.

The `YAML` file is probably easier if you want to manage a number of hosts
along with lots of customisation. This is because the playbook uses structures
such as lists for variables, which are easier to write in `YAML`.

Either way, I suggest copying the sample inventory file and then modifying it,
if required. The locations used below are ignored by Git, making it easier to
pull in new changes.

```bash
cd korora-ansible
cp ./inventory/hosts ./inventory/hosts-custom
# or YAML inventory
cp ./inventory/hosts.yml ./inventory/hosts-custom.yml
```

# Running the Ansible playbook

If you are happy with the defaults for localhost, you can simply run with the
sample `localhost` inventory file.

```bash
cd korora-ansible
ansible-playbook --inventory ./inventory/hosts korora.yml --ask-become-pass
# or YAML inventory
ansible-playbook --inventory ./inventory/hosts.yml korora.yml --ask-become-pass
```

Else, pass in your custom inventory file.

```bash
cd korora-ansible
ansible-playbook --inventory ./inventory/hosts-custom korora.yml --ask-become-pass
# or YAML inventory
ansible-playbook --inventory ./inventory/hosts-custom.yml korora.yml --ask-become-pass
```

# Overriding settings

This playbook lets you customise certain things, such as packages to install or
remove, and services to enable or disable.

While you can override the default variables for these things, there are also
some matching `custom` variables which let you do your own thing without
changing the defaults.

* korora_packages_custom
* korora_services_custom
* korora_copr_repos_custom

You can add these on the command line, or as variables for hosts in your
inventory files.

## Variables in the inventory file

Complex variables are easier in the	`YAML` inventory file, but it's also
possible in the `ini` style.

### ini style inventory

This ini inventory sets the `korora_packages_custom` variable to install and
remove some packages.

```ini
[all]
localhost ansible_connection=local korora_packages_custom='{ "install": [ "vim" ], "remove": [ "nano" ] }'

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

### YAML style inventory

This YAML inventory sets the same `korora_packages_custom` variable to install
`vim` and remove `nano`. It also ensures `dnsmasq` is installed and the service
is enabled, while then disabling `dhcpcd` service via the
`korora_services_custom` variable.

```yaml
all:
  hosts:
    localhost:
      ansible_connection: local
      korora_packages_custom:
        install:
          - vim
        remove:
          - nano
      korora_services_custom:
        packages:
          - dnsmasq
        enable:
          - dnsmasq
        disable:
          - dhcpcd
  vars:
    ansible_python_interpreter: /usr/bin/python3
```

## Variables on the command line

You can override settings on the command line, for example adding extra
packages to install and remove.

```bash
ansible-playbook --inventory ./inventory/hosts korora.yml --ask-become-pass \
--extra-vars '{ "korora_packages_custom": { "install": [ "pass", "mosquitto" ], "remove": [ "abrt" ] }}'
```
