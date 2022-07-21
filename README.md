# cms-cvmfs-docker: A docker container for the CMS user

This project was setup to allow local access to the CernVM File System (CernVM-FS or CVMFS). Users may want access to CVMFS for a multitude of reasons, not the least of which are offline access to CMSSW, local access to grid tools, or a sandboxed environment. Whatever the reason is, this container was built with a couple of requirements in mind:

1. Local access to CVMFS
2. A Linux environment in which to work with the CMSSW and OSG tools
3. X11 and VNC support for using GUIs and ImageMagic
4. Doesn't trip the Fermilab network security policies
   - Don't ssh into the container using a password
   - Don't open unnecessary ports
   - Don't allow the use of passwords to login
   - Simply put, don't use Ubuntu or Centos unless you want to configure a lot of the software yourself
5. UID and GID mapping for using the grid certificate on the localhost
6. Use of a lightweight container system like Docker rather than a full virtual machine
7. The use of GitHub Actions as a build system

Branch|Build|Image Size|Pulls|Docker Hub
---|---|---|---|---
latest | [![Docker Build Status](https://github.com/aperloff/cms-cvmfs-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/aperloff/cms-cvmfs-docker/actions/workflows/docker-publish.yml) | [![Docker Image Size](https://img.shields.io/docker/image-size/aperloff/cms-cvmfs-docker?sort=semver)](https://hub.docker.com/r/aperloff/cms-cvmfs-docker "Click to view the image on Docker Hub") | [![](https://img.shields.io/docker/pulls/aperloff/cms-cvmfs-docker.svg)](https://img.shields.io/docker/pulls/aperloff/cms-cvmfs-docker.svg) | [cms-cvmfs-docker](https://hub.docker.com/r/aperloff/cms-cvmfs-docker/)

--------------------------------------------
## Setting up the Docker image

There are two ways to access this container, build it yourself or pull the image from DockerHub. Below we will describe both methods.

### Building the image

In the directory containing the Dockerfile file, run this command
```bash
docker build -t <name>[:<tag>]
```

For example:
```bash
docker build -t cms-cvmfs-docker:latest
```
The name and tag choice are up to you.

### Pulling a pre-build image

If you would rather not build the image yourself, you can always check it out (pull) from DockerHub.
```
docker pull aperloff/cms-cvmfs-docker[:tag]
```

The number of tags varies from time to time based on the current number of branches in GitHub. There will always be a `latest` tag, which is built from the master branch.

--------------------------------------------
## Recommended configuration changes for the Docker daemon
To reduce the attack surface for bad actors we highly recommend that you modify your Docker daemon (dockerd) configuration to bind container ports to localhost by default. This means that for any container you run, the port forwarding will only connect to the host computer, as long as no other IP is specified. This change has the added benefit of preventing your computer from being flagged by FNAL security scanners.

If you have Docker Desktop, make this change by going to *Preferences* -> *Docker Engine* and adding the line:
```json
"ip": "<ip_address>"
```
It’s a good practice to bind ports to the `localhost`, which is address `127.0.0.1`.

You can also use the daemon directly by using the command `dockerd --ip <ip_address>`.

--------------------------------------------
## Container basics

### Starting the container (for the first time)

To run the container use a command similar to:
```bash
docker run -it -P --device /dev/fuse --cap-add SYS_ADMIN -e DISPLAY=host.docker.internal:0 <name>[:<tag>]
```
where the name and tag will be dependent on if your accessing a local image or the pre-built from DockerHub. For information about the name and tag choices, see the previous section on setting up the image.

You may also customize the run command with some additional options. These options and their effect are described below:
- If you would like the container to be removed immediately upon exiting the container, simply add `--rm` to the command.
- If you would like to limit the number of CVMFS mount points, you can add `-e CVMFS_MOUNTS="<mounts>"`, where `<mounts>` is a space separated list of mount points. The accessible mount points are:
   - cms.cern.ch
   - cms-ib.cern.ch
   - oasis.opensciencegrid.org
   - cms-lpc.opensciencegrid.org
   - sft.cern.ch
   - cms-bril.cern.ch
   - cms-opendata-conddb.cern.ch
   - ilc.desy.de
   - unpacked.cern.ch
- To access a grid certificate on the host computer you will need to not only mount the directory containing the certificate files, but also map the host user's UID and GID to that of the remote user. To do this you will need to append the commands: `-e MY_UID=$(id -u) -e MY_GID=$(id -g) -v ~/.globus:/home/cmsusr/.globus`. Though technically the local `.globus` folder doesn't need to be in the local users home area.
- To mount other local folders, simply add `-v <path to local folder>:<path to remote folder>`.
- To name the container, add the `--name <name>` option. If you don't name the container, Docker will assign a random string name to the container. You can find the name of the container by entering the command `docker ps -a` on the host computer.
- To run a VNC server inside the container you will need to open two ports using the options `-p 5901:5901 -p 6080:6080`.

A full command may look something like:
```bash
docker run --rm -it -P -p 5901:5901 -p 6080:6080 --device /dev/fuse --cap-add SYS_ADMIN -e CVMFS_MOUNTS="cms.cern.ch oasis.opensciencegrid.org" -e DISPLAY=host.docker.internal:0 -e MY_UID=$(id -u) -e MY_GID=$(id -g) -v ~/.globus:/home/cmsusr/.globus aperloff/cms-cvmfs-docker:latest
```

**Note:** On certain Linux distributions (i.e. Ubuntu) you will need to turn off `apparmor` in order for CVMFS to be mounted successfully. Simply add the option `--security-opt apparmor:unconfined` to your `docker run` command.

### Stopping a container

If you've added the `--rm` option to the run command, then the container will be removed once you enter the `exit` command from within the container and the pseudo-tty is closed.

However, if you haven't added that option, then you will need to explicitly shutdown the container. Exit as described above and then use the following command to temporarily stop the container daemon:
```bash
docker stop <container name>
```

### Restarting a container

You can restart a container after it had been stopped by doing
```bash
docker start <container name>
```

You may need to remount the CVMFS folders by running the command:
```bash
~/run.sh
```

### Removing a container

If you decide you no longer need that particular container (perhaps you want to start another fresh one), you can delete that container instance by doing
```bash
docker rm <container name>
```

### Opening another instance into the same container

If you find you need multiple instances withing the same container you can use the following command to open a new shell in the container:
```bash
docker exec -it <container name> bash -i
```

The starting path will be `/`. Without the `-i` command the shell will start without loading any of the interactive login scripts.

### Running a shell script upon startup (will not be interactive)

If all you'd like to do is run a single shell script or command within bash, you may pass this as the docker run "[COMMAND] [ARG...]" options. This will, in fact, be gobbled up by the `su` command in the run.sh script which started the bash shell owned by the cmsusr user. In order to run a command, use the syntax:
```bash
docker run <options> aperloff/cms-cvmfs-docker:latest -c <command>
```
where all of the docker run options have been omitted for clarity. You may run multiple commands if they are separated by `&&` and surrounded by quotes. For example:
```bash
-c "<command> && <command>"
```
The `-c` option is passed to `su` and tells it to run the command once the shell has started up. If instead you would like to run a shell script with arguments, simply use:
```bash
docker run <options> aperloff/cms-cvmfs-docker:latest <script> <arguments>
```
Please note, you cannot run multiple shell scripts as all of the scripts will be passed as arguments to the first script.

### Starting and connecting to a VNC server

First of all, remember to map ports 5901 and 6080 when starting the container (see the options above). Once in the container, run the command `start_vnc`. You can use the option `verbose` to increase the verbosity of the printouts. The first time you start a server, or after a cleanup, you will be asked to setup a password. It must be at least six characters in length.

Configuration Options:
* You can use the GEOMETRY environment variable to set the size of the VNC window. By default it is set to 1920x1080.
* If you run multiple VNC servers you can switch desktops by changing the DISPLAY environment variable like so: `export DISPLAY=myvnc:1`, which will set the display of the remote machine to that of the VNC server.

At this point, you can connect to the VNC server with your favorte VNC viewer (RealVNC, TightVNC, OSX built-in VNC viewer, etc.). The following are the connection addresses:
  1. VNC viewer address: 127.0.0.1:5901
  2. OSX built-in VNC viewer command: `open vnc://127.0.0.1:5901`
  3. Web browser URL: http://127.0.0.1:6080/vnc.html?host=127.0.0.1&port=6080

Note: On OSX you will need to go to System Preferences > Sharing and turn on "Screen Sharing" if using a VNC viewer, built-in or otherwise. You will not need to do this if using the browser.

There are two additional helper functions:
  1. `stop_vnc`: Kills all of the running vnc servers and the noVNC+WebSockify instance
  2. `clean_vnc`: In additional to running `stop_vnc`, this will clear all of the temporary files associated with the previous vnc servers

If you'd like more manual control you can use the following commands:
  1. `vncserver -list`: Will list the available VNC servers running on the remote machine.
  2. `vncserver -kill :1`: Will kill a currently running VNC server using. `:1` is the "X DISPLAY #".
  3. `pkill -9 -P <process>`: Will kill the noVNC+WebSockify process if you use the PID given when running `start_vnc` or when starting manually.

**Note:** Do not leave the VNC server listening or the container running for extended periods of time. Running a VNC server for an extended period of time increases the attack surface for bad actors unnecessarily.

### Using X11

You will need to have a properly configured X Window System on the host system. For OSX we recommend XQuartz. For Windows popular options are xming and VcXsrv, though others are also available. Windows systems may also use cygwin with winpty and prefix your docker command like winpty docker.

The options to allow X11 windows to be transmitted to the host are different for the different host operating systems:
 - **OSX:** `-e DISPLAY=host.docker.internal:0`
 - **Linux:** `-e DISPLAY=$DISPLAY -e XAUTHORITY=~/.Xauthority -v ~/.Xauthority:/home/cmsuser/.Xauthority -v /tmp/.X11-unix/:/tmp/.X11-unix`

#### Special instructions for OSX users

Once XQuarts is installed, start the program and navigate to XQuartz -> Preferences -> Security. Make sure that both the “Authenticate connections” and “Allow connections from network clients” checkboxes are selected. If you change any settings, you will need to restart XQuartz.

--------------------------------------------
## What can I do with this?

Now that you've started the container, you have full access to the suite of grid and CMS software.

### Setting up XRootD and VOMS software

Prerequisites:
* You've mounted oasis.opensciencegrid.org
* You've mounted you local .globus folder to /home/cmsusr/.globus
* The permissions on the .globus folder, the usercert.pem file, and userkey.pem file are correct

If you've satisfied the prerequisites, then you simply need to run the command:
```bash
voms-proxy-init -voms cms --valid 192:00 -cert .globus/usercert.pem -key .globus/userkey.pem
```
For some reason you need to specify the usercert.pem and userkey.pem files manually. However, this long command has been aliased inside the `.bashrc` file and you simply need to type:
```bash
voms-proxy-init
```

### Setting up a CMSSW area

Prerequisites:
* You've mounted cms.cern.ch

    Once inside the container, you can setup the CMSSW area in the standard way

* move to the directory where you would like to checkout CMSSW
* see what CMSSW versions are available by doing

    ```bash
    scram list -a CMSSW
    ```

* setup a work area for a specific version, e.g.

    ```bash
    scram project CMSSW_10_6_0
    ```

Note: The initial setup of the paths to the CMS software is handled within the `.bashrc` file. This gets you the `cmsrel` and `scram` commands, among others.

--------------------------------------------
## Acknowledgements

This work was based largely on the following work of others

https://twiki.cern.ch/twiki/bin/view/Main/DockerCVMFS

https://github.com/cms-sw/cms-docker/blob/master/cmssw/Dockerfile

http://cmsrep.cern.ch/cmssw/cms/slc6_amd64_gcc530-driver.txt

https://github.com/Dr15Jones/cms-cvmfs-docker

Special thanks goes to Burt Holzman for figuring out how to map the UID/GID and allowing for X11 access without breaking the Fermilab computing policy.
