# PL2-AWS-Setup

## Overview

This GitHub repository hosts Terraform scripts that automatically set up a Protection Level 2 (PL2) High Performance Computing (HPC) environment in Amazon Web Services (AWS) for researchers working with secure big data. This environment is at use at UC Berkeley and is one of Berkeley Research Computing's Infrastructure-as-a-service (IaaS) solutions for researchers.

Before beginning, it is recommended that you review the [PL2 AWS Setup - Generalized Cost Estimator for HPC](https://docs.google.com/document/d/1VL2TNQnx3wHRkHMnyBUlrT7jW5uFZfDGXvzLvSkOSPw/edit?usp=sharing) which projects expenses for a setup like this. If at any point you need assistance or would like to consult with our team on your project, please feel free to email the [BRC Consulting team](mailto:research-it-consulting@berkeley.edu). This guide is intended for the systems or security administrator of a project to use to build the setup. Finally, if you're interested in looking at and understanding this project's code, start with `main.tf`, `outputs.tf`, and `variables.tf` -- the [recommended minimal module files](https://www.terraform.io/docs/modules/create.html#standard-module-structure) -- and work your way from their.

---

## Getting Started

1. The first thing you'll need to do is [Set up AWS Invoicing at UC Berkeley](https://docs.google.com/document/d/1cDSv0EzEkl09FVYivsTtvel1vyenoFJCDQTiECbGqT4/edit?usp=sharing).
  - **Note**: For researchers at other institutions, this involves simply setting up an AWS account with billing -- if your instituion has a particular method of AWS invoicing, it is recommended that you get that set up.
  - **Note**: At this point, ensure that the root AWS account is attached to a Special Purpose Account (SPA), or for non-Berkeley folks, a project-specific email. This is to ensure there is a a central point of administration and helps with the separation of permissions.


2. Once you have created a SPA account, ensure you are able to [log into it](https://calnetweb.berkeley.edu/calnet-departments/special-purpose-accounts-spa/log-spa) in an Incognito window.
  - From within your SPA, check out [bmail.berkeley.edu](bmail.berkeley.edu) and your SPA's [Google Drive](https://drive.google.com).
  - From within your SPA, make a copy of this [PL2 AWS Setup - Documentation Template](https://docs.google.com/document/d/1JzAM7vR4AbKNYL_YJ6qL6J2hG3W9ePVI67BPIZvl8RU/edit?usp=sharing), which is part of the recommended workflow for this project.
    - **Note**: As you proceed through the setup, this is a one-stop-shop for documenting pieces of the project that you have control over (such as usernames, passwords, and public keys, for example) that will be readily accessible and shareable among project members. This is useful from a systems administrator perspective and from a security audit perspective as well.
    - **Note**: You should share this document with anybody involved with the project but be careful with who has access because this document will contain sensitive data, including passwords, public keys, IP addresses, etc... Any researcher or administrator should definitely have read+write access but you should share with individual emails only (including your own, as you'll be responsible for filling it out), rather than sharing it as a link.

3. Next, log into using the services tab from your root account's AWS console, go to the Identity and Access Management (IAM) console. You will need to complete a set of 5 security tasks that are good practices for securing your root account, visible on the bottom of the dashboard. The 5 tasks are:
  - **Delete your root access keys** -- this is to ensure no program or person can use the root account key credentials to authenticate and thus makes [controlling access to the account much easier](https://docs.aws.amazon.com/general/latest/gr/root-vs-iam.html). Follow the steps on the dashboard.
  - **Activate Multi-Factor Authentication (MFA) on your root account** -- this is to ensure that only the systems/security administrator has access to the root account. Follow the steps on the dashboard.
  - **Create individual IAM users** -- for now we only need to create a single IAM user to get Terraform set up. Once Terraform builds the setup, each researcher will be assigned their own individual IAM user automatically. Follow the [AWS documentation on Creating an Administrator IAM User and Group (Console)](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html). Once the user has been  created, be sure to use the `Download .csv` button to download this IAM user's credentials.
    - **Note**: you should name this user "Terraform" rather than "Administrator" for additional clarity. The group it is added should still be named "Administrators".
    - **Note**: at Step 4, rather than enable "Console access" and specify a password, you should check the box to enable "Programmatic access"
    - **Note**: if you don't download the IAM user's credentials immediately after creating them, they won't be available for download later. Instead, you would need to [Create a new Access Key](https://aws.amazon.com/blogs/security/wheres-my-secret-access-key/).
  - **Use Groups to assign permissions** -- ignore this for now -- Terraform will help us create IAM groups for researcher, administrators, and log analysts
  - **Apply an IAM Password Policy** -- ignore this for now -- Terraform will set this up to ensure that the passwords required to access the console by the researchers and admin are appropriately secure against standard brute-force and dictionary attacks.

4. Once you've done this, open your copy of the `PL2 AWS Setup - Documentation Template` and fill in the yellow-highlighted items in the document.
  - **Note**: You should hyperlink [Account ID: <123456789012>]() as it appears here, where you replace the Account ID with your own and link to . This will be how members of the project log access the [AWS Management Console](https://console.aws.amazon.com/). Feel free to reference the [IAM Console and Sign-in Page documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/console.html).
  - **Note**: You should also rename the template document to follow the naming convention `Organization_Name PL2 AWS Setup - Documentation`.

3. In your web browser navigate to the [CIS Ubuntu Linux 16.04 LTS Benchmark Level 1 marketplace page](https://aws.amazon.com/marketplace/pp?sku=2l0khimiqztu90zd64xu99tz5) and subscribe your SPA account to the software.
  - **Note**: This step may take a few minutes to complete but the page will notify you when your account has been successfully subscribed.

4. Navigate to the AWS Workspaces console and use it to create an Amazon Linux AWS Workspace called `Administration`. To access your `Administration` workspace, you'll need to [download a Workspaces client](https://clients.amazonworkspaces.com/) for your device.
  - **Note**: Attempting to create the Terraform setup from outside the Workspace (which is within the same VPC as the EC2 instance) will fail due to a VPC security group (firewall) configured only to allow access to the instance from within the VPC. For advanced users attempting to change or modify this behaviour, see the `VPC` and `EC2` modules for more details.

## Administration From an AWS Workspace

For the remainder of this section, you should be logged into your `Administration` AWS Workspace, running Amazon Linux.
1. Install [Google Chrome](https://www.google.com/chrome/) and [Atom](https://atom.io) to function as your main Web Browser and Text Editor respectively. Then, install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html). Verify your installation is running smoothly and the behaviour mentioned in the installation docs matches what is expected.

2. Clone this GitHub repository to a directory Then, in a text editor of your choice (such as ), open `terraform.tfvars` and `variables.tf`. In `variables.tf`, you will find a set of variable definitions and descriptions for which you will be responsible for assigning values to within the empty `terraform.tfvars` file.
  - **Example**: To assign a project name, you could type `project_name = "Kaiser_Flu"` in `terraform.tfvars`. Then, you would skip a line, and proceed to an assignment of the next variable documented in `variables.tf`.
  - **Documentation**: Feel free to check out the `Variable Files` section of [Terraform's documentation on input variables](https://www.terraform.io/docs/configuration/variables.html#Variable_Files) for more help.

3. In a Terminal, navigate to this cloned GitHub repository. Then run `terraform init`

4. Next, run `terraform apply` to start the automated build.

Todo: Include instructions on changing the device name and/or manual attachment of EBS devices to the AWS_Instance
Todo: Adding a researcher or administrator after the environment has been created
Todo: Changing the size of your EBS data volume
