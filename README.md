# PL2-AWS-Setup

###### TODO
  - Create and link to an example, fake, filled-in PL2 Documentation Template
  - Create a template MSSEI
  - Create and link to documentation
  - Fill in readme for EC2/provisioner_scripts
  - Document how to create a new researcher (for workspaces, linux, and IAM)
  - Add CloudWatch Idle alarms to setup for leaving setup running too long
  - Document instructions on changing the device name and/or manual attachment of EBS devices to the AWS_Instance
  - Changing the size of your EBS data volume
  - Creating Passwords for IAM Users

## Overview

This GitHub repository hosts Terraform scripts that automatically set up a Protection Level 2 (PL2) High Performance Computing (HPC) environment in Amazon Web Services (AWS) for researchers working with secure big data. This environment is in use at UC Berkeley and is one of Berkeley Research Computing's Infrastructure-as-a-service (IaaS) solutions for researchers working with protected data.

Before beginning, it is recommended that you review the [PL2 AWS Setup - Generalized Cost Estimator for HPC](https://docs.google.com/document/d/1VL2TNQnx3wHRkHMnyBUlrT7jW5uFZfDGXvzLvSkOSPw/edit?usp=sharing) which projects expenses for a setup like this. If at any point you need assistance or would like to consult with our team on your project, please feel free to email the [BRC Consulting team](mailto:research-it-consulting@berkeley.edu). This guide is intended for the systems or security administrator of a project to use to build the setup. Finally, if you're interested in looking at and understanding this project's code, start with `main.tf`, `outputs.tf`, and `variables.tf` -- the [recommended minimal module files](https://www.terraform.io/docs/modules/create.html#standard-module-structure) -- and work your way from there.

**If at any point you run into any issues, have a question, a special use case, or need additional clarification and documentation, feel free to [file an issue on GitHub](https://github.com/kmishra9/PL2-AWS-Setup/issues) and we'll do our best to handle it.**

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
  - **Note**: You should hyperlink [Account ID: <123456789012>]() so it looks like what appears here, where you replace the Account ID with your own and link to your organization's IAM login page. This will be how members of the project log access the [AWS Management Console](https://console.aws.amazon.com/). Feel free to reference the [IAM Console and Sign-in Page documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/console.html).
  - **Note**: You should also rename the template document to follow the naming convention `Organization_Name PL2 AWS Setup - Documentation`.

5. In your web browser navigate to the [CIS Ubuntu Linux 18.04 LTS Benchmark Level 1 marketplace page](https://aws.amazon.com/marketplace/pp?sku=b1e35cepur7ecue1bq883thxr) and subscribe your SPA account to the software.
  - **Note**: This step may take a few minutes to complete but the page will notify you when your account has been successfully subscribed.

6. Navigate to the [AWS Workspaces Console](https://us-west-2.console.aws.amazon.com/workspaces/home?region=us-west-2#listworkspaces:) and use it to create a "Standard" Amazon Linux AWS Workspace called `Administration` in the US-West-2 (Oregon) region. Do not enable "Self Service Permissions" or "Amazon WorkDocs" and set the email to be your SPA email. The workspace should have a root volume capacity of 80GB and a user volume capacity of 0GB, both of which should be encrypted, and the "AutoStop (1 hour)" running mode is recommended. This can take up to 40 minutes to full create.
  - **Note**: Before you can create a Workspace, you will need to create a new `Simple AD` that will have `Size = Small`, an `Organization Name` of your choosing, `Directory DNS Name = corp.example.com` and a password for the *Directory Administrator* (which is different from the `Administration` workspace you're creating). You should generate a password using the strong random password generator linked from your copy of the Documentation Template and document the password in the *Directory Administrator* section of the AWS Workspaces credentials table. During creation of the `Simple AD` should also select the default VPC and subnets `us-west-2a` and `us-west-2b`. This will take a few minutes to create.
    - Feel free to examine additional documentation on ["What Gets Created"](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/create_details_simple.html?icmpid=docs_ds_console_help_panel) when you create a directory with `Simple AD`.
  - **Note**: Attempting to create the Terraform setup from outside the Workspace (which is within the same VPC as the EC2 instance) will fail due to a VPC security group (firewall) configured only to allow access to the instance from within the VPC. For advanced users attempting to change or modify this behaviour, see the `VPC` and `EC2` modules for more details.

## Administration From an AWS Workspace

For the remainder of this section, you should be logged into your `Administration` AWS Workspace, running Amazon Linux. To access your `Administration` workspace, you'll need to [download an AWS Workspaces client](https://clients.amazonworkspaces.com/) for your device.
1. Installations
  - Install [Google Chrome](https://www.google.com/chrome/) (main web browser).
  - Install [Atom](https://atom.io) (main text editor).
  - Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) (automated Infrastructure-as-a-service tool).
    - Verify your installation is running smoothly ensuring the behaviour in the installation documentation matches what happens on your machine.

2. Setting Up Terraform
  - Clone this GitHub repository to a directory on your Workspace.
  - Then, in Atom, create `terraform.tfvars` (at the top level of the GitHub repository i.e. `PL2-AWS-Setup/terraform.tfvars`) and open `variables.tf`.
  - In `variables.tf`, you will find a set of variable definitions, descriptions, and defaults for which you will be responsible for assigning values to within the empty `terraform.tfvars` file.
    - **Example**: To assign a project name, you could type `project_name = "Kaiser-Flu"` in `terraform.tfvars`. Then, you would skip a line, and proceed to an assignment of the next variable documented in `variables.tf`. Feel free to make a copy of `example.tfvars.example` and rename it to `terraform.tfvars` to get started.
    - **Documentation**: Feel free to check out the `Variable Files` section of [Terraform's documentation on input variables](https://www.terraform.io/docs/configuration/variables.html#Variable_Files) for more help.

3. Running terraform
  - In a Terminal, navigate to this cloned GitHub repository.
  - Initialize Terraform with the Terminal command `terraform init`.
  - Next, run `terraform apply` to start the automated build. This will take several minutes.
  -

## Final Touches

1. AWS Workspaces for Researchers
  - At this point, an `Administration` workspace has been created but individual researchers will also need their own workspaces in order to access the setup.
  - Unfortunately, Terraform is unable to provision AWS Workspaces for each individual researcher automatically so every reasearcher needs to have a seperate Workspace created for them
  - Researcher Workspace Creation
    - TODO 1
    - TODO 2

2. Creating Passwords for IAM Users
  - At this point, Terraform has generated IAM users for administrators, researchers, and log analysts, but hasn't yet assigned any of them passwords.
  - Each IAM user also follows a standardized format, such as `Administrator_2` or `Researcher_0`, meaning you'll need to assign real people to these IAM users and generate passwords for each of them to be able to access the console. Your copy of the Documentation Template should be invaluable in allowing you to cleanly organize this information.
