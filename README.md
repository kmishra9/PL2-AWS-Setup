# PL2-AWS-Setup

Note: Projected completion date is January 2019. This document is still under construction.

[PL2 AWS Setup - Documentation Template for Users](https://docs.google.com/document/d/1JzAM7vR4AbKNYL_YJ6qL6J2hG3W9ePVI67BPIZvl8RU/edit?usp=sharing)
## Overview

This GitHub Repository hosts Terraform scripts that automatically set up a Protection Level 2 (PL2) High Performance Computing (HPC) environment in Amazon Web Services (AWS) for researchers working with secure big data. This environment is at use at UC Berkeley and is one of Berkeley Research Computing's IaaS solutions for researchers.

Before beginning, it is recommended that you review the [PL2 AWS Setup - Generalized Cost Estimator for HPC](https://docs.google.com/document/d/1VL2TNQnx3wHRkHMnyBUlrT7jW5uFZfDGXvzLvSkOSPw/edit?usp=sharing) which projects expenses for a setup like this.

Finally, if at any point you need assistance or would like to consult with our team on your project, please feel free to email the [BRC Consulting team](mailto:research-it-consulting@berkeley.edu). This guide is intended for the systems or security administrator of a project to use to build the setup.

---

## Getting Started

1. The first thing you'll need to do is [Set up AWS Invoicing at UC Berkeley](https://docs.google.com/document/d/1cDSv0EzEkl09FVYivsTtvel1vyenoFJCDQTiECbGqT4/edit?usp=sharing).
  - **Note**: For researchers at other institutions, this involves simply setting up an AWS account with billing -- if your instituion has a particular method of AWS invoicing, it is recommended that you get that set up.
  - **Note**: At this point, ensure that the root AWS account is attached to a Special Purpose Account (SPA), or project-specific email. This is to ensure that project members are given least-privileges access and to create a central point of administration.


2. Next, using the services tab from your root account's AWS console, go to the Identity and Access Management (IAM) console. You will need to complete a set of 5 security tasks that are good practices for securing your root account, visible on the bottom of the dashboard. The 5 tasks are:
  - **Delete your root access keys** -- this is to ensure no program or person can use the root account key credentials to authenticate and thus makes [controlling access to the account much easier](https://docs.aws.amazon.com/general/latest/gr/root-vs-iam.html). Follow the steps on the dashboard.
  - **Activate Multi-Factor Authentication (MFA) on your root account** -- this is to ensure that only the systems/security administrator has access to the root account. Follow the steps on the dashboard.
  - **Create individual IAM users** -- for now we only need to create a single IAM user to get Terraform set up. Once Terraform builds the setup, each researcher will be assigned their own individual IAM user automatically. Follow the [AWS documentation on Creating an Administrator IAM User and Group (Console)](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html). Once the user has been  created, be sure to use the `Download .csv` button to download this IAM user's credentials.
    - **Note**: you should name this user "Terraform" rather than "Administrator" for additional clarity. The group it is added should still be named "Administrators".
    - **Note**: at Step 4, rather than enable "Console access" and specify a password, you should check the box to enable "Programmatic access"
    - **Note**: if you don't download the IAM user's credentials immediately after creating them, they won't be available for download later. Instead, you would need to [Create a new Access Key](https://aws.amazon.com/blogs/security/wheres-my-secret-access-key/).
  - **Use Groups to assign permissions** -- ignore this for now -- we've created our Administrator group and Terraform will help us create a group for researcher IAM accounts and a second optional group for log analysis IAM accounts
  - **Apply an IAM Password Policy** -- ignore this for now -- Terraform will set this up to ensure that the passwords required to access the console by the researchers and admin are appropriately secure against standard brute-force and dictionary attacks.

3. If you haven't already done so, clone this GitHub repository. Then, in a text editor of your choice (such as [Atom](https://atom.io)), open `terraform.tfvars` and `variables.tf`. In `variables.tf`, you will find a set of variable definitions and descriptions for which you will be responsible for assigning values to within the empty `terraform.tfvars` file.
  - **Example**: To assign a project name, you could type `project_name = "KaiserFlu"` in `terraform.tfvars`. Then, you would skip a line, and proceed to an assignment of the next variable documented in `variables.tf`.
  - **Documentation**: Feel free to check out the `Variable Files` section of [Terraform's documentation on input variables](https://www.terraform.io/docs/configuration/variables.html#Variable_Files) for more help.
  - **Note**: This step will provide Terraform with administration access to the AWS Setup while the Terraform IAM user we created exists.

4. Install Terraform, then run some sort of Terraform verify and verify that things are working as they should be.
