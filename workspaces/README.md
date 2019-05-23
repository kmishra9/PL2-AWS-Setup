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
      LocalForward [to_local_port] [from_remote_port]
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
        LocalForward 80 127.0.0.1:8787
  ```
- Save your entry (command: `Ctrl-X` while in the Nano text editor)
- Restart your Terminal when complete (you can do so by exiting and opening a new one) and try initializing an ssh tunnel (command: `ssh [name]`, substituting `[name]` for the actual name you chose).
- To SSH normally, try typing `ssh [username]@[ip-address]` replacing with the actual values. You should have a successful SSH connection
  - **Example**: `ssh ubuntu@172.31.16.129`
  - **Note**: You can't have an SSH tunnel to and a regular ssh connection to Ubuntu going at the same time.

## What Happens Next
If you've documented your SSH public key in your project's AWS documentation for your administrator, they will need to copy the key in the `/home/[researcher_account_username]/.ssh/authorized_keys` file of your researcher account on the server to "enable" SSH and tunneling. Please let them know that you've documented your public key and they should get back to you with an email when they're done doing so, at which point you'll have access to the setup.

## Using Your SSH Tunnel to connect to RStudio Server
Once you've gone through the set of steps above, your administrator has enabled SSH and tunnelling, and you've initialized an SSH tunnel from your Workspace (command: `ssh tunnel`), using the tunnel is simple. By default, the tunnel you've set up is connected to RStudio Server (if you've followed the example, changing only the `Hostname` and `User`, according to the setup and your Linux username). Simply open your Chrome browser and type `localhost` to start using RStudio Server, which is running on the analysis instance.

## Debugging Problems with SSH
If SSH'ing normally or creating a tunnel doesn't work, there are a couple of things to check:
1. Is the EC2 Analysis Instance running? You can check this from the EC2 Management Console (see your documentation template for more details on how to access the console)
2. You can't initiate an SSH connection to a user if you already have an SSH tunnel going to that user (and vice versa). Thus, ensure that you only have one GitBash window open.
3. After creating an entry in `~/.ssh/config` for your ssh tunnel, you need to restart your terminal (close and open again).
4. Make absolutely sure that the public key you documented is identical to the output of `cat ~/.ssh/id_rsa.pub`. If it is not, run through the steps of SSH setup from the beginning.
5. Did you misspell anything in the `~/.ssh/config`? Is the casing of the `hostname` correct?
6. Has your administrator confirmed that they've authorized the public key you documented?
7. If none of those apply, it might be a permissions issue. Contact your systems administrator
