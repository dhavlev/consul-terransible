# Consul Terransible
This reposiory will help you setup [Consul](https://www.consul.io/) Cluster (2 clients and 3 Servers) using Terraform and Ansible.

## Diagrams - Infra
![consul-infra.png](consul-infra.png)

## How to setup Consul Cluster using Terrform and Ansible Scripts
### Preparing master machine
Please refer to file - [client-setup-script.sh](client-setup-script.sh)

```
chmod 777 client-setup-script.sh
./client-setup-script.sh
```

### Screenshots
![images/consul-01.png](images/consul-01.png)
![images/consul-02.png](images/consul-02.png)
![images/consul-03.png](images/consul-03.png)
![images/consul-05.png](images/consul-05.png)

### Initialise and Plan
```
git clone https://github.com/dhavlev/consul-terransible.git
cd consul-terransible/terraform
terraform init
terraform plan
```

### Apply
```
terraform apply --auto-approve
```

### Destroy
```
terraform destroy --auto-approve
```

## How to Execute Ansible Playbook independent of Terraform
### Setup
```
ansible-playbook -i non-production master-install-consul.yaml --tags "setup"
```

### Maintenance
```
ansible-playbook -i non-production master-install-consul.yaml --tags "consul-start" | "consul-stop" | "consul-status"
```

## Troubleshoot
### Ansible
1. ansible the authenticity of host can't be established  
   Open /etc/ansible/ansible.cfg and set 'host_key_checking' to false
2. Problem while identing the config.json  
   refer to [link](https://ansiblemaster.wordpress.com/2016/07/29/jinja2-lstrip_blocks-to-manage-indentation/)

## Important Note
1. This infrastructure is deployed from a controller machine which is outside the Consul Infra and does not have access to private IPs.
2. You will see Public IPs are enabled though Instances are deployed in Private Subnet.
3. Please amend scripts to suit your requirements.

## Want to Secure Infra
1. Remove route to internet from route - "consul_rt_private"
2. Remove "map_public_ip_on_launch" from "consul_sub_private_a",  consul_sub_private_b", "consul_sub_private_c"
3. Map private ips in ansible inventoty "aws_hosts"

