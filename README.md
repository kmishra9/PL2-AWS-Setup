# PL2-AWS-Setup

###### TODO
  - Develop standardized email from admin => researchers in documentation
  - Stata installation instructions on Linux and how to use it
  - Create and link to an example, fake, filled-in PL2 Documentation Template
  - Create a template MSSEI + update(redact(copy(KaiserFlu MSSEI)))
  - Fill in readme for EC2/provisioner_scripts
  - Document how to create a new researcher (for workspaces, linux, and IAM)
  - Add CloudWatch Idle alarms to setup for leaving setup running too long
  - Document instructions on changing the device name and/or manual attachment of EBS devices to the AWS_Instance
  - Changing the size of your EBS data volume
  - Adapt [AWS User Setup Instructions](https://docs.google.com/document/d/1TjbceyJ2eE-uaxqfX-cccXCw3MgeO2wU54v6jOz1qj4/edit?usp=sharing) and [Flu AWS User Creation Guide](https://docs.google.com/document/d/1GA8IlGA6cBbR13UBnCRFe8TYaEjSZ3w9tMv6hGDVAj0/edit?usp=sharing)
  - Destroying your Setup + Resetting Up your Setup
  - Implement CloudWatch Alarms, GuardDuty, etc.
  - Look into whether password SSH is forbidden -- if not, maybe use a tool like this to copy the key to their username (https://docs.google.com/document/d/1JzAM7vR4AbKNYL_YJ6qL6J2hG3W9ePVI67BPIZvl8RU/edit#)

## Overview

This GitHub repository hosts Terraform scripts that automatically set up a Protection Level 2 (PL2) High Performance Computing (HPC) environment in Amazon Web Services (AWS) for researchers working with secure big data. This environment is in use at UC Berkeley and is one of Berkeley Research Computing's Infrastructure-as-a-service (IaaS) solutions for researchers working with protected data.

Before beginning, it is recommended that you review the [PL2 AWS Setup - Generalized Cost Estimator for HPC](https://docs.google.com/document/d/1VL2TNQnx3wHRkHMnyBUlrT7jW5uFZfDGXvzLvSkOSPw/edit?usp=sharing) which projects expenses for a setup like this. If at any point you need assistance or would like to consult with our team on your project, please feel free to email the [BRC Consulting team](mailto:research-it-consulting@berkeley.edu). This guide is intended for the systems or security administrator of a project to use to build the setup. Finally, if you're interested in looking at and understanding this project's code, start with `main.tf`, `outputs.tf`, and `variables.tf` -- the [recommended minimal module files](https://www.terraform.io/docs/modules/create.html#standard-module-structure) -- and work your way from there.

**If at any point you run into any issues, have a question, a special use case, or need additional clarification and documentation, feel free to [file an issue on GitHub](https://github.com/kmishra9/PL2-AWS-Setup/issues) and we'll do our best to handle it.**

---

## Getting Started

1. The first thing you'll need to do is [Set up AWS Invoicing at UC Berkeley](https://docs.google.com/document/d/1cDSv0EzEkl09FVYivsTtvel1vyenoFJCDQTiECbGqT4/edit?usp=sharing).
  - **Note**: For researchers at other institutions, this involves simply setting up an AWS account with billing -- if your instituion has a particular method of AWS invoicing, it is recommended that you get that set up.
  - **Note**: At this point, ensure that the root AWS account is attached to a [Special Purpose Account (SPA)](https://calnetweb.berkeley.edu/calnet-departments/special-purpose-accounts-spa), or for non-Berkeley folks, a project-specific email. This is to ensure there is a a central point of administration, helps with the separation of permissions, and ensures project's longevity is not tied to any one individual's account.
    - **Example**: `bcht-aws@berkeley.edu` or `brc-aws-dev@berkeley.edu`

2. Once you have created a SPA account, ensure you are able to [log into it](https://calnetweb.berkeley.edu/calnet-departments/special-purpose-accounts-spa/log-spa) in an Incognito window.
  - From within your SPA, check out [bmail.berkeley.edu](bmail.berkeley.edu) and your SPA's [Google Drive](https://drive.google.com).
  - From within your SPA, make a copy of this [PL2 AWS Setup - Documentation Template](https://docs.google.com/document/d/1JzAM7vR4AbKNYL_YJ6qL6J2hG3W9ePVI67BPIZvl8RU/edit?usp=sharing), which is part of the recommended workflow for this project.
    - **Note**: As you proceed through the setup, this is a "one-stop-shop" for documenting pieces of the project that you have control over (such as usernames, passwords, public keys, etc.) that will be readily accessible and shareable among project members. This is useful from a systems administrator perspective and from a security audit perspective as well.
    - **Note**: You should share this document with anybody involved with the project but be careful with who has access because this document will contain sensitive information. Any researcher or administrator should definitely have read+write access but you should share with individual emails only (including your own, as you'll be responsible for filling it out), rather than sharing it as a link.

3. Next, log into using the services tab from your root account's AWS console, go to the Identity and Access Management (IAM) console. You will need to complete a set of 5 security tasks that are good practices for securing your root account, visible on the bottom of the dashboard. The 5 tasks are:
  - **Delete your root access keys** -- this is to ensure no program or person can use the root account key credentials to authenticate and thus makes [controlling access to the account much easier](https://docs.aws.amazon.com/general/latest/gr/root-vs-iam.html). Follow the steps on the dashboard.
  - **Activate Multi-Factor Authentication (MFA) on your root account** -- this is to ensure that only the systems/security administrator has access to the root account. Follow the steps on the dashboard.
  - **Create individual IAM users** -- for now we only need to create a single IAM user to get Terraform set up. Once Terraform builds the setup, each researcher will be assigned their own individual IAM user automatically. Follow the [AWS documentation on Creating an Administrator IAM User and Group (Console)](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html). Once the user has been  created, be sure to use the `Download .csv` button to download this IAM user's credentials.
    - **Note**: you should name this user "Terraform" rather than "Administrator" for additional clarity. The group it is added should still be named "Administrators".
    - **Note**: at Step 4, rather than enable "Console access" and specify a password, you should check the box to enable "Programmatic access"
    - **Note**: if you don't download the IAM user's credentials immediately after creating them, they won't be available for download later. Instead, you would need to [Create a new Access Key](https://aws.amazon.com/blogs/security/wheres-my-secret-access-key/).
  - **Use Groups to assign permissions** -- ignore this for now -- Terraform will help us create IAM groups for researcher, administrators, and log analysts
  - **Apply an IAM Password Policy** -- ignore this for now -- Terraform will set this up to ensure that the passwords required to access the console by the researchers and admin are appropriately secure against standard brute-force and dictionary attacks.

4. Once you've done this, open your copy of the `PL2 AWS Setup - Documentation Template` and fill in the yellow-highlighted items in the document (some can be filled in now, others you should fill in as you work through the rest of the setup). As you fill these pieces in, unhighlight the sections.
  - **Note**: You should hyperlink [Account ID: <123456789012>]() so it looks like what appears here, where you replace the <Account ID> with your own and link to your organization's IAM login page. This will be how members of the project log in to access the [AWS Management Console](https://console.aws.amazon.com/).
    - **Documentation**: Feel free to reference the [IAM Console and Sign-in Page documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/console.html) for more help.
  - **Note**: You should also rename the template document to follow the naming convention `Organization_Name PL2 AWS Setup - Documentation`.
    - **Example**: `Colford_Group PL2 AWS Setup - Documentation` or `BCHT PL2 AWS Setup - Documentation`

5. In your web browser navigate to the [CIS Ubuntu Linux 16.04 LTS Benchmark Level 1 marketplace page](https://aws.amazon.com/marketplace/pp/B078TPPXV2?qid=1549956548098&sr=0-5&ref_=srh_res_product_title) and subscribe your SPA account to the software.
  - **Note**: This step may take a few minutes to complete but the page will notify you when your account has been successfully subscribed.

6. Navigate to the [AWS Directory Service Console](https://us-west-2.console.aws.amazon.com/directoryservicev2/home?fromOldConsole=true&region=us-west-2#!/directories) and use it to create a new `Simple AD` that will have `Size = Small`, an `Organization Name` of your choosing, `Directory DNS Name = corp.example.com` and a password for the *Directory Administrator*. You should generate a password using the strong random password generator linked from your copy of the Documentation Template and document the password in the *Directory Administrator* section of the AWS Workspaces credentials table. During creation of the `Simple AD`, you should also select the default VPC and subnets `us-west-2a` and `us-west-2b`. This will take a few minutes to create.
  - **Documentation**: Feel free to reference additional documentation on ["What Gets Created"](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/create_details_simple.html?icmpid=docs_ds_console_help_panel) when you create a directory with `Simple AD`.

7. Navigate to the [AWS Workspaces Console](https://us-west-2.console.aws.amazon.com/workspaces/home?region=us-west-2#listworkspaces:) and use it to create a "Standard" Windows 10 AWS Workspace called `Administration` in the US-West-2 (Oregon) region. Enable "Self Service Permissions" and "Amazon WorkDocs" and set the email to be your SPA email. The workspace should have a root volume capacity of 80GB and a user volume capacity of 0GB, both of which should be encrypted, and the "AutoStop (1 hour)" running mode is recommended. This can take up to 40 minutes to full create.
  - **Note**: Attempting to create the Terraform setup from outside the Workspace (which is within the same VPC as the EC2 instance) will fail due to a VPC security group (firewall) configured only to allow access to the instance from within the VPC. Similarly, this ensures _your instance cannot be accessed from anywhere except one of the AWS workspaces that you set up_, and this is in an intentional design decision to ensure the data and instance stay secure. For advanced users attempting to change or modify this behaviour, see the `VPC` and `EC2` modules for more details.

8. As you wait for the Workspaces to initialize, navigate to the [`Directories` tab](https://us-west-2.console.aws.amazon.com/workspaces/home?region=us-west-2#directories:directories). You should see the directory you created earlier. Select the directory and `Update Details`. Select `Access to Internet` and enable internet access, if it is currently disabled.
  - **Note**: if you get the error `Internet Gateway not attached to your Amazon VPC`, navigate to the [AWS VPC Console](https://us-west-2.console.aws.amazon.com/vpc/home?region=us-west-2#igws:sort=internetGatewayId) and create a new internet gateway. Leave the `Name tag` field blank. Then, select the newly created internet gateway and attach it to the default VPC to which your directory is also attached to. Finally, ensure the [VPC's route table](https://us-west-2.console.aws.amazon.com/vpc/home?region=us-west-2#RouteTables:sort=routeTableId) to `Destination=0.0.0.0/0` targets the internet gateway you just spun up and its status is "Active".
    - **Documentation**: Feel free to reference additional documentation on [Creating a VPC, Internet Gateway and Subnet](https://campus.barracuda.com/product/emailsecuritygateway/doc/41099104/creating-a-vpc-internet-gateway-and-subnet/) and [AWS Routing 101](https://medium.com/@mda590/aws-routing-101-67879d23014d) for more help.


## Administration From an AWS Workspace

For the remainder of this section, you should be logged into your `Administration` AWS Workspace, which will be running Windows 10. To access your `Administration` workspace, you'll need to complete your user profile, [download an AWS Workspaces client](https://clients.amazonworkspaces.com/) for _your own device_ (i.e. a MacBook), and then login with username `Administration` and the password you've set (which you should record in the Documentation Template). See the email sent to your SPA email for more details and exact instructions.

1. **Workspace Setup**
  - Install [Google Chrome](https://www.google.com/chrome/) (main web browser).
  - Install [Atom](https://atom.io) (main text editor).
  - Install [GitBash](https://gitforwindows.org/) (version control & Terminal emulation).
  - Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) (automated Infrastructure-as-a-service tool).
    - **Note**: Verify your installation is running smoothly by ensuring the behaviour in the installation documentation matches what happens on your machine.
      - **Documentation** Feel free to reference a step-by-step tutorial on [Installing Terraform on Windows 10](https://www.vasos-koupparis.com/terraform-getting-started-install/) for more help.
  - In a GitBash Terminal, type `ssh-keygen` to generate an SSH key pair for your `Administration` workspace
    - **Note**: The ssh key will be generated by default at the path `~/.ssh/id_rsa` and the public key at `~/.ssh/id_rsa.pub`
    - **Documentation**:Feel free to reference documentation on [Generating a New Key with ssh-keygen](https://www.ssh.com/ssh/keygen/) for more help.

2. **Setting Up Terraform**
  - From a GitBash Terminal, clone this GitHub repository on your Workspace (command: `git clone https://github.com/kmishra9/PL2-AWS-Setup.git`).
    - **Note**: This will create a folder called `PL2-AWS-Setup` in the same directory where you are when you run the clone command. To get back to the top level of your home directory (that's generally the best place to clone this GitHub repo), just type `cd`.
  - Then, in Atom, create a file and save it as `terraform.tfvars` at the top level of the GitHub repository (i.e. `PL2-AWS-Setup/terraform.tfvars`) and open the existing file, `variables.tf`.
  - In `variables.tf`, you will find a set of variable definitions, descriptions, and defaults. You will be responsible for assigning values to these variables, within the empty `terraform.tfvars` file.
    - **Note**: The specific values you are responsible for assigning can have somewhat rigid requirements -- _read the documentation for each variable to prevent errors from occurring later_
    - **Example**: To assign a project name, you could type `project_name = "Kaiser-Flu"` in `terraform.tfvars`. Then, you would skip a line, and proceed to an assignment of the next variable documented in `variables.tf`. Feel free to make a copy of `example.tfvars.example` and rename it to `terraform.tfvars` to get started.
    - **Documentation**: Feel free to reference the "Variable Files" section of [Terraform's documentation on input variables](https://www.terraform.io/docs/configuration/variables.html#Variable_Files) for more help.

3. **Running Terraform**
  - In a GitBash Terminal, navigate to this cloned GitHub repository.
  - Initialize Terraform (command: `terraform init`).
  - Next, start the automated build (command: `terraform apply`). This will take several minutes.
    - **Note**: if you get the error `* module.EC2.aws_instance.EC2_analysis_instance: timeout - last error: dial tcp 12.345.678.901:22: i/o timeout` try rerunning the command.
    - **Note**: if you get any other types of errors regarding resource creation or provisioning try running `terraform apply` once again, but if the issue doesn't resolve itself, report the issue on GitHub.
    - **Note**: Any files contained in `EC2/provisioner_scripts` will be copied to the EC2 Analysis instance at the path `/home/ubuntu/` (the home directory of the first user, "Ubuntu") during Terraform's setup. _A future version of this software will also begin setup by running these scripts_. However, you will need to manually install them when you log in for the first time.
    - **Note**: If you'd like to add any of your own installation scripts or modify the existing ones in any way, you should

4. **Finishing Setup of your `Administration` Workspace**
  - **SSH Public Keys**
    - Document the ssh public key of `Administration` in your copy of the Documentation Template. It can generally be found at the path `~/.ssh/id_rsa.pub` and can be printed to the console with the `cat` command (example: `cat ~/.ssh/id_rsa.pub`). Because the key is long, you should shrink the public key down to a size 4 font once it has been pasted into the table.
  - **Configuring SSH Tunnels**
    - An SSH tunnel is similar to an HTTPS connection in that a port on your local machine mirrors a port on the server. This is useful, for example, in encrypting a connection to RStudio-Server or JupyterHub (running on the EC2 analysis instance) from a Workspace via SSH. It also quickly allows you to SSH into the analyis instance from Terminal.
      - You can read additional documentation that is a [Basic Introduction motivating the use of SSH tunnels](https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding)
    - Edit `~/.ssh/config ` (or create the file if one does not yet exist) and add an entry based on the following configuration:
    ```
    Host [name]
          Hostname [ip-address]
          User [username]
          LocalForward [from_remote_port] [to_local_port]
    ```
      - **Note**: When you use the terminal command `ssh [name]`, an ssh connection from the current machine is initialized to [username@ip-address] and the [127.0.0.1:to_local_port] on the current machine mirrors [username@ip-address:from_remote_port]. This is an encrypted connection (substituting for HTTPS)
      - **Note**: I recommend using `name = tunnel` -- it makes it simple to call `ssh tunnel` to initiate an ssh tunnel.
      - **Note**: The `[ip-address]` should be the _private ip_ address of the EC2 Analysis Instance. You can find out what this is from the EC2 management console.
      - **Note**: The `[from-remote-port]` needs to be running something that can be forwarded. RStudio-Server, for example, can be installed and configured to run on port 8000. Until something is running, however, tunnelling the port will be futile (_see next section to install stuff that can be tunelled_)
      - **Example**:
      ```
      Host tunnel
            Hostname 172.31.16.129
            User ubuntu
            LocalForward 8000 127.0.0.1:80
      ```
    - Restart your Terminal when complete (you can do so by exiting and opening a new one) and try initializing an ssh tunnel (command: `ssh [name]`, substituting `[name]` for the actual name you chose). The expected behaviour is for
    - To SSH normally, try typing `ssh [username]@[ip-address]` replacing with the actual values. You should have a successful SSH connection
      -  **Note**: You can't have an SSH tunnel to Ubuntu and a regular ssh connection to Ubuntu going at the same time.

5. **Finishing Setup of your EC2 Analysis Instance**

  - You can read documentation for each of the following functions in the `EC2/provisioner_scripts/README.md`. All of them are necessary components to a completed setup and should be run _on the EC2 Analysis Instance_ after SSH'ing in from the `Administration` Workspace (command: `ssh tunnel`).
    - Adding Researcher Accounts
    - Installing Programming Software
    - Installing Updates
    - Installing the Cloudwatch Logs Agent
    - Mounting Drives
  - **Other Installations**
    - If you have anything else you'd like to install, follow external instructions for installing things on `Ubuntu 16.04 LTS`, the OS the EC2 Analysis Instance is running
  - Once you've SSH'd into the EC2 Analysis Instance, you should also document the SSH public keys of each user, including Ubuntu, the "sudo" user. These will be at `/home/username/.ssh/id_rsa.pub`. If that path doesn't exist yet, you will need to switch users (example: `sudo su researcher_0`) and run `ssh-keygen`, at which point a key pair should be generated for you to access and document. To become `ubuntu` again, simply type `exit` or `logout`.
    - **Note**: if you forget to switch users and run ssh-keygen as `ubuntu`, even fro m within the home directory of another user, you'll just be resetting `ubuntu`'s ssh keys.

## Final Touches

1. **AWS Workspaces for Researchers**
  - At this point, an `Administration` workspace has been created but individual researchers will also need their own workspaces in order to access the setup.
  - Unfortunately, Terraform is unable to provision AWS Workspaces for each individual researcher automatically so you will need to create a separate Workspace for each researcher
  - Follow the same steps you used to create the `Administration` Workspace to create Workspaces for each researcher. Researchers will receive an email asking them to set a password, just as the SPA email received one for the `Administration` Workspace. Ensure the researchers know to set passwords using the Strong Random Password Generator linked from your copy of the Documentation Template and to document the Workspaces passwords they generate there as well (there is a table associating a real name, workspaces username, and password where they should place their password). Researchers should also generate ssh keys and document their Workspaces ssh public key in the provided table as well.
    - **Note**: Each Workspaces username also follows a standardized format, such as `Researcher_0` or `Researcher_11`, meaning you'll need to assign real people to these usernames in your copy of the Documentation Template as you create Workspaces for them.
  -

2. **Credentials for IAM User**
  - At this point, Terraform has generated IAM users for administrators, researchers, and log analysts, but hasn't yet assigned any of them passwords.
  - You will need to enable password access for each researcher from the IAM Management Console. Set passwords using the Strong Random Password Generator linked from your copy of the Documentation Template
  - You will need to enable programmatic access for the `Log_Analyst` IAM user, download the `secret_key` and `access_key`, and send them to UC Berkeley's Log Analysis Team
  - **Note**: Each IAM username also follows a standardized format, such as `Administrator_2` or `Researcher_0`, meaning you'll need to assign real people to these IAM users and generate passwords for each of them to be able to access the console. Your copy of the Documentation Template should be invaluable in allowing you to cleanly organize this information.

3. **Adding New Researchers after Terraform has been built**

4. **Importing Data Into your AWS setup**
  - The recommended workflow for importing data involves transferring the data to a new `Data_Acquisition` AWS Workspace that you create especially for this purpose There are a variety of ways to do this such as Box, Google Drive, AWS WorkdDocs scp, sftp, etc. Then, from `Data_Acquisition` you could transfer the data to your EC2 instance via [SCP (a terminal command)](http://www.hypexr.org/linux_scp_help.php) or something like [Cyberduck (a GUI)](https://cyberduck.io/).
    - **Note**: It is important to remember is that this "hop" through the workspace is necessary because everything within the VPC (besides the Workspace itself) is isolated from the outside. A security group is applied to the EC2 Analysis Instance preventing any connections made from IPs outside of the VPC. Thus, directly connecting to the instance isn't an option.
  - **Note**: I highly recommend you make a snapshot of both your root AWS EBS volume and the EBS volume containing sensitive data _prior_ to making large changes as well as a snapshot _after_ you successfully make the change. This will help keep things running smoothly in the event that accidents happen (which they do). Bricking an instance by accident, consequently, is only really bad if you don't have a straightforward path to recovery
  - **Note**: A reminder to run `./mount_drives` pretty much any time you start the EC2 instance up. You don't want to acidentally store the data on the root volume of the EC2 instance at the path /home/[data-folder-name] (which is unencrypted) instead of its correct place on an encrypted, attached, mounted EBS volume at the same path.

5. **MSSEI**
  - For PL2 projects only, you will also need to complete a document outlining your project and declaring that it fulfills the [Minimum Security Standards for Electronic Information (MSSEI)](https://security.berkeley.edu/minimum-security-standards-electronic-information) that your data must abide by.
  - You can find a Template MSSEI to begin filling out [here]().
  - An example of a similar, completed MSSEI can be found [here](https://docs.google.com/document/d/1YqaoR8Z0DrhGTk2_UBGsBcFsrapPVFUzkLbekPCxrOU/edit?usp=sharing).
