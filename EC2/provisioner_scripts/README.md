# Provisioner Scripts Documentation

Each of the bash scripts included as part of this folder are used to set up the EC2 analyis instance during the initial setup. As part of the terraform build, they are moved to the home directory of the "ubuntu" user (`/home/ubuntu`). The `Administration` Workspace has direct SSH access as the "ubuntu" user.

1. `add_swap`
  - **Usage**: `sudo ./add_swap`
  - **Description**: Adds a 30GB of swap file to the disk as an overflow location for Virtual RAM.
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
4. `install_programming_software`
  - **Usage**: `sudo ./install_programming_software`
  - **Description**:
5. `install_updates`
  - **Usage**: `sudo ./install_updates`
  - **Description**:
6. `mount_drives`
  - **Usage**: `sudo ./mount_drives`
  - **Description**:
