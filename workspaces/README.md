# Configuring SSH Tunnels

## Overview
- An SSH tunnel is similar to an HTTPS connection in that a port on your local machine mirrors a port on the server. This is useful, for example, in encrypting a connection to RStudio-Server or JupyterHub (running on the EC2 Analysis Instance) from a Workspace via SSH. It also quickly allows you to SSH into the instance from Terminal.

Feel free to reference additional documentation on [Motivating the use of SSH tunnels](https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding)

## Getting Started
- Edit `~/.ssh/config` on your Workspace (command: `nano ~/.ssh/config`) and add an entry based on the following configuration:
```
Host [name]
      Hostname [ip-address]
      User [username]
      LocalForward [from_remote_port] [to_local_port]
```
  - **Note**: When you use the terminal command `ssh [name]`, an ssh connection from the current machine is initialized to `username@ip-address` and the `127.0.0.1:to_local_port` on the current machine mirrors `username@ip-address:from_remote_port`. This is an encrypted connection (substituting for HTTPS).
  - **Note**: I recommend using `name = tunnel` -- it makes it simple to call `ssh tunnel` to initiate an ssh tunnel.
  - **Note**: The `[ip-address]` should be the _private ip_ address of the EC2 Analysis Instance. You can find out what this is from the EC2 management console.
  - **Note**: The `[from-remote-port]` needs to be running something that can be forwarded. RStudio-Server, for example, can be installed and configured to run on port 8787. Until something is running, however, tunnelling the port will be futile (_see next section to install stuff that can be tunelled_)
  - **Example**:
  ```
  Host tunnel
        Hostname 172.31.16.129
        User ubuntu
        LocalForward 8787 127.0.0.1:80
  ```
- Restart your Terminal when complete (you can do so by exiting and opening a new one) and try initializing an ssh tunnel (command: `ssh [name]`, substituting `[name]` for the actual name you chose).
- To SSH normally, try typing `ssh [username]@[ip-address]` replacing with the actual values. You should have a successful SSH connection
  -  **Note**: You can't have an SSH tunnel to and a regular ssh connection to Ubuntu going at the same time.
