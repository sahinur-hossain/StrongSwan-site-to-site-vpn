# StrongSwan-site-to-site-vpn
This repo contains the Automated site to site vpn configuration with (VPGW + StrongSwan).

**Prerequisite: -**

Platform for executing terraform (local or server).

We assume Ubuntu OS for ONPREM for Customer gateway.

ONPREM or CGW servers Elastic IP.

<h3>Clone the repo with terraform files and bash script.</h3>

```bash
git clone https://github.com/sahinur-hossain/StrongSwan-site-to-site-vpn.git
cd StrongSwan-site-to-site-vpn
```
Here we have the terraform files for the VPGW and Site to Site VPN deployment.
```bash
terraform init
```
Variables required for the terraform resource creation/deployment which will be passed in <code>variables.auto.tfvars</code>.
You can edit the variables in <code>variables.auto.tfvars</code> file and add the values there.
We can also add the access keys here, if required.
```bash
vpc_id                    VPC ID of AWS site (e.g. vpc-0eb24075490d4c793)
customer_gateway_ip       Your on-prem device public IP (e.g. 3.108.208.184)
customer_gateway_bgp_asn  Change only if required else just enter
vpn_static_routes         CIDR range for the on prem site. (e.g. 10.10.0.0/16)
#You can add the access keys as well
aws_region                Region for the deployment
access_key                Access Key 
secret_key                Secret Key
```

```bash
terraform plan
```

Once we confirm everything to be fine we can proceed with resource creation

```bash
terraform apply --auto-approve
```

This should create the resources for the VPN at the AWS Side. Now we need to download the configuration file and configure the StrongSwan VPN at the on prem side.
Go to AWS VPC console, at the left side Navigate to <code> Virtual private network (VPN) </code> and then under <code> Site-to-Site VPN connections </code>. Select the Created Site to Site VPN and the download the configuration file With Vendor as <code>StrongSwan</code>. We can leave the Platform & Software as default. We need to change the IKE version to **ikev2** and then download the configuration file.

<h2> Once we have the VPN configuration file from AWS, now we will configure the onprem side</h2>
Once we have the server access. Copy this VPN configuration file and then also place the StrongSwan.sh script available in this directory.

Once we have the **VPN configuration file** & **StrongSwan.sh** bash script in place. We need to make the bash Script executable.
```bash
chmod +x StrongSwan.sh
./StrongSwan.sh
```
**StrongSwan.sh** is an automated bash script which will configure all the things for us. It will require few of the inputs: -

Name of the VPN configuration file.
On-premises CIDR Range (e.g. 192.168.1.0/24)
AWS VPC CIDR Range (e.g. 10.0.0.0/16)

Once the script is successfully executed, we can check the status of the VPN.
```bash
ipsec statusall
```


