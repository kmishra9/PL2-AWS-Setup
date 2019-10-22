# Provisioner Scripts Documentation

## Overview
Each of the bash scripts included as part of this folder are used to set up the EC2 analyis instance during the initial setup. As part of the terraform build, they are moved to the home directory of the "ubuntu" user on the EC2 Analysis Instance (path: `/home/ubuntu`). _They are intended to be run on the instance, not the workspace_.

## Getting Started
1. Start by SSH'ing into your analysis instance from the `Administration` Workspace.
  - **Note**: The `Administration` Workspace has direct SSH access as the "ubuntu" user (command: `ssh ubuntu@[EC2_Private_IP]`, where you can find the EC2_Private_IP for an instance from the [EC2 Management Console](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Instances:sort=desc:tag:Name)). Alternatively, if you've already set up SSH tunnels, you can use them to SSH in (command: `ssh tunnel`)

2. Scripts should be run in the following order:
  - `add_swap` (already run as part of Terraform provisioning)
  - `mount_drives` (already run as part of Terraform provisioning)
  - `add_users`
  - `install_cloudwatch_logs_agent`
  - `install_programming_software`
  - `install_updates`
  - **Note**: reference the documentation below for details on _how to run_ each script (i.e. the arguments they take, additional instructions, what they do, etc.)
  - **Note**: running `install_updates` last will kick you out of your SSH session as the instance restarts. This is expected behaviour and you should be able to SSH back into it within ~1 minute.

3. Additional, [nonprogrammatic documentation is included for installing Stata](https://docs.google.com/document/d/1PPVvi_2JXKwNhK9b5fVjQY_ua52d1a7-utZ_j7EP6fw/edit?usp=sharing) if that is of interest. This isn't an officially supported software, but other users have had success in the past and I'd be more than willing to answer any questions while you work through the documentation. 

## Script Usage & Descriptions
1. `add_swap` (already run as part of Terraform provisioning)
  - **Usage**: `sudo ./add_swap`
  - **Description**: Adds a 30GB of swap file to the disk as an overflow location for Virtual RAM. The OS requires `mount_drives` to be run to mount the swap file appropriately

2. `mount_drives` (already run as part of Terraform provisioning)
  - **Usage**: `sudo ./mount_drives [data_folder_path=/home/data]`
  - **Description**: Mounts swap, as well as a single EBS volume at `/dev/nvme1n1`. For some smaller or older instances, the EBS volume may be at `/dev/xvdf`, and running the script may result in an error. In this case, commenting out `sudo mount /dev/nvme1n1 $1` and replacing it with `sudo mount /dev/xvdf $1`. `data_folder_path` defaults to `/home/data` if left unspecified

3. `add_users`
  - **Usage**: `sudo ./add_users [data_folder_path] [num_researchers]`
  - **Description**: Creates the number of accounts specified. Each account also has a symlink (alias) to the data folder path specified, with rwx permissions, as well as the `mount_drives` script (which is assumed to be adjacent to `add_users` when it is run). The new users are named consistently as `researcher_x`, where `x` is an integer between [0, num_researchers). The accounts are also added to the `sudo` group and have SSH access enabled for them.

4. `install_cloudwatch_logs_agent`
  - **Usage**: `sudo ./install_cloudwatch_logs_agent`
  - **Description**: Installs the Amazon CloudWatch Logs Agent and requires interactive input to configure it. This will log everything happening on the EC2 instance and store it in AWS CloudWatch (useful for security audit).
  - **Interactive Input**:
    - **AWS access key ID**: Leave blank and press `Enter`
    - **AWS secret access key**: Leave blank and press `Enter`
    - **Default region name**: Ensure `us-west-2` is the default (or input `us-west-2` if it is not)
    - **Default output format**: Leave blank and press `Enter`
    - **Path of log file to upload**: Accept recommended path
    - **Destination Log Group name**: Accept recommended name
    - **Destination Log Stream name**: Accept recommended name
    - **Timestamp format**: Accept recommended timestamp format
    - **Initial Position**: Accept recommended initial position
    - **More log files to configure?** Type `N` and press `Enter` to finish
    - **Documentation**: Feel free to reference [additional documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html) on installing and configuring the CloudWatch Logs Agent
  - **Verifying Installation**: In the [CloudWatch Management Console](https://console.aws.amazon.com/cloudwatch/home), you should be able to see a new log group and stream after the agent has been running for a few moments

5. `install_programming_software`
  - **Usage**: `sudo ./install_programming_software`
  - **Description**: Installs several important linux development utilities, R, and RStudio Server (running on port `8787`). Python 2 and 3 already come preinstalled with the Amazon Machine Image (AMI) we're using. _A future version of this script will also install Anaconda and JupyterHub Server, for using Jupyter Notebooks and Python_.

6. `install_updates`
  - **Usage**: `sudo ./install_updates`
  - **Description**: Installs Linux and package updates and restarts the server. Useful for general maintenance and cleanup. The script requires interactive input in some cases but you should generally accept the default options.
