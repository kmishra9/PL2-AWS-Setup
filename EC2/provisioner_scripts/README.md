# Provisioner Scripts Documentation

Each of the bash scripts included as part of this folder are used to set up the EC2 analyis instance during the initial setup. As part of the terraform build, they are moved to the home directory of the "ubuntu" user (`/home/ubuntu`). The `Administration` Workspace has direct SSH access as the "ubuntu" user.

1. `add_swap`
  - **Usage**: `sudo ./add_swap`
  - **Description**: Adds a 30GB of swap file to the disk as an overflow location for Virtual RAM. The OS requires `mount_drives` to be run to mount the swap file appropriately

2. `add_users`
  - **Usage**: `sudo ./add_users [data_folder_path] [num_researchers]`
  - **Description**: Creates the number of accounts specified. Each account also has a symlink (alias) to the data folder path specified, with rwx permissions. The new users are named consistently as `researcher_x`, where `x` is an integer between [0, num_researchers).

3. `install_cloudwatch_logs_agent`
  - **Usage**: `sudo ./install_cloudwatch_logs_agent`
  - **Description**: Installs the Amazon CloudWatch Logs Agent and requires interactive input to configure it. This will log everything happening on the EC2 instance and store it in AWS CloudWatch (useful for security audit).
  - **Interactive Input**:
    - **AWS access key ID**: Leave blank and press `Enter`
    - **AWS secret access key**: Leave blank and press `Enter`
    - **Default region name**: Set to `us-west-2`
    - **Default output format**: Leave blank and press `Enter`
    - **Path of log file to upload**: Accept recommended path
    - **Destination Log Group name**: Accept recommended name
    - **Destination Log Stream name**: Accept recommended name
    - **Timestamp format**: Specify the format of the time stamp within the specified log file. Choose custom to specify your own format.
    - **Initial Position**: Set to `start_of_file`
    - **Documentation**: Feel free to reference [additional documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html) on installing and configuring the CloudWatch Logs Agent
  - **Verifying Installation**: In the [CloudWatch Management Console](CloudWatch - AWS Console - Amazon.com
https://console.aws.amazon.com/cloudwatch/home), you should be able to see a new log group and stream after the agent has been running for a few moments

4. `install_programming_software`
  - **Usage**: `sudo ./install_programming_software`
  - **Description**: Installs several important linux development utilities, R, and RStudio Server. Python 2 and 3 already come preinstalled with the Amazon Machine Image (AMI) we're using. _A future version of this script will also install Anaconda and JupyterHub Server, for using Jupyter Notebooks and Python_.

5. `install_updates`
  - **Usage**: `sudo ./install_updates`
  - **Description**: Installs Linux and package updates and restarts the server. Useful for general maintenance and cleanup.

6. `mount_drives`
  - **Usage**: `sudo ./mount_drives [data_folder_path]`
  - **Description**: Mounts swap, as well as a single EBS volume at `/dev/xvdf`. For some large instances, the EBS volume may be at `/dev/nvme1n1`, and running the script may result in an error. In this case, commenting out `sudo mount /dev/xvdf $1` and replacing it with `sudo mount /dev/nvme1n1 $1`.
