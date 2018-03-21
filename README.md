# Packer - Ubuntu

![circleci build status](https://circleci.com/gh/daveshepherd/packer-ubuntu.png?style=shield "circleci build status")

Builds AWS AMI images for Ubuntu LTS versions 16.04 18.04 containing customisation for use in our infrastrcuture using
[Packer](https://www.packer.io/) based on the official Ubuntu AMI image in the eu-west-1 and eu-west-2 regions.

This image is private and is built to include configuration and components required across all servers, which makes it
unsuitable for public consumption. However, feel free to use this as an example of how to do build your own AMIs.

The reason for this is for implementing the idea of immutable infrastructure, where updates and upgrade a baked into the
AMI and the updated version is deployed to replace the existing servers. This means if there is a problem the original
servers can continue to be used. Note that you have to ensure the applications being built on top of this image support
this idea.

## Configuration

The following environment variables are required to build this image

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY	
* IRELAND_VPC - The ID of a VPC to use in Ireland (eu-west-1), e.g. vpc-abcd1234
* IRELAND_SUBNET - The ID of the subnet to use in Ireland (eu-west-1), e.g. subnet-efgh5678
* LONDON_VPC - The ID of a VPC to use in London (eu-west-1), e.g. vpc-12345abcd
* ANSIBLE_VAULT_PASSWORD - The password used to encrypt the secrets in the ansible configuration

## AWS IAM policy

The AWS access key id and secret access key should have the following permissions, for each region:

```
{
     "Version": "2012-10-17",
     "Statement": [
         {
             "Sid": "NonResourceLevelPermissions",
             "Action": [
                 "ec2:Describe*",
                 "ec2:CreateVolume",
                 "ec2:CreateKeypair",
                 "ec2:DeleteKeypair",
                 "ec2:CreateSecurityGroup",
                 "ec2:AuthorizeSecurityGroupIngress",
                 "ec2:CreateImage",
                 "ec2:CreateSnapshot",
                 "ec2:DeleteSnapshot",
                 "ec2:RegisterImage",
                 "ec2:CreateTags",
                 "ec2:ModifyImageAttribute",
                 "ec2:RequestSpotInstances",
                 "ec2:CancelSpotInstanceRequests"
             ],
             "Effect": "Allow",
             "Resource": "*"
         },
         {
             "Sid": "AllowInstanceActions",
             "Effect": "Allow",
             "Action": [
                 "ec2:StopInstances",
                 "ec2:TerminateInstances",
                 "ec2:AttachVolume",
                 "ec2:DetachVolume",
                 "ec2:DeleteVolume"
             ],
             "Resource": [
                 "arn:aws:ec2:eu-west-1:123456789012:instance/*",
                 "arn:aws:ec2:eu-west-1:123456789012:volume/*",
                 "arn:aws:ec2:eu-west-1:123456789012:security-group/*"
             ],
             "Condition": {
                 "StringEquals": {
                     "ec2:ResourceTag/Name": "Packer Builder"
                 }
             }
         },
         {
             "Sid": "EC2RunInstancesSubnet",
             "Effect": "Allow",
             "Action": [
                 "ec2:RunInstances"
             ],
             "Resource": [
                 "arn:aws:ec2:eu-west-1::image/*",
                 "arn:aws:ec2:eu-west-1:123456789012:key-pair/*",
                 "arn:aws:ec2:eu-west-1:123456789012:network-interface/*",
                 "arn:aws:ec2:eu-west-1:123456789012:security-group/*",
                 "arn:aws:ec2:eu-west-1:123456789012:volume/*",
                 "arn:aws:ec2:eu-west-1:123456789012:instance/*",
                 "arn:aws:ec2:eu-west-1:123456789012:subnet/subnet-efgh5678",
                 "arn:aws:ec2:eu-west-1:123456789012:vpc/vpc-*"
             ]
         },
         {
             "Sid": "SGVPCDelete",
             "Effect": "Allow",
             "Action": [
                 "ec2:DeleteSecurityGroup"
             ],
             "Resource": [
                 "*"
             ],
             "Condition": {
                 "StringEquals": {
                     "ec2:vpc": [
                         "arn:aws:ec2:eu-west-1:123456789012:vpc/vpc-abcd1234"
                     ]
                 }
             }
         }
     ]
 }
```

## Ansible encrypted value


The users' password is already encrypted, but I decided to encrypt it in this repo because
someone could use this definition and brute force the resulting image to find the real password.
Whereas, now a private password is required to do this. 

See the Ansible documentation for details on using Ansible Vault for encrypting values in Ansible:
https://docs.ansible.com/ansible/2.4/vault.html

Example: 

```
ansible-vault encrypt_string --vault-id @prompt 'ssh-rsa XXXXX user@machine.local' --name 'sshkey'
```