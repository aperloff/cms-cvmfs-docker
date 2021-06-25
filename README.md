# cms-cvmfs-docker: A docker container for the CMS user

This project was setup to allow local access to the CernVM File System (CernVM-FS or CVMFS). Users may want access to CVMFS for a multitude of reasons, not the least of which are offline access to CMSSW, local access to grid tools, or a sandboxed environment. Whatever the reason is, this container was built with a couple of requirements in mind:

1. Local access to CVMFS
2. A Linux environment in which to work with the CMSSW and OSG tools
3. X11 support for using GUIs and ImageMagic
4. Don't trip the Fermilab network security policies
   - Don't ssh into the container using a password
   - Don't open unnecessary ports
   - Don't allow the use of passwords to login
   - Simply put, don't use Ubuntu or Centos unless you want to configure a lot of the software yourself
5. UID and GID mapping for using the grid certificate on the localhost
6. Use of a lightweight container system like docker rather than a full virtual machine
7. The use of DockerHub as a build system

Branch|Build|Type|Pulls|Stars|Docker Hub
---|---|---|---|---|---
latest | [![Docker Build Status](https://img.shields.io/docker/build/aperloff/cms-cvmfs-docker.svg)](https://img.shields.io/docker/build/aperloff/cms-cvmfs-docker.svg) | [![Docker Build Type](https://img.shields.io/docker/automated/aperloff/cms-cvmfs-docker.svg)](https://img.shields.io/docker/automated/aperloff/cms-cvmfs-docker.svg) | [![](https://img.shields.io/docker/pulls/aperloff/cms-cvmfs-docker.svg)](https://img.shields.io/docker/pulls/aperloff/cms-cvmfs-docker.svg) | [![](https://img.shields.io/docker/stars/aperloff/cms-cvmfs-docker.svg)](https://img.shields.io/docker/stars/aperloff/cms-cvmfs-docker.svg) | [cms-cvmfs-docker](https://hub.docker.com/r/aperloff/cms-cvmfs-docker/)

--------------------------------------------
## Setting up the Docker image

There are two ways to access this container, build it yourself or pull the image from DockerHub. Below we will describe both methods.

### Building the image

In the directory containing the Dockerfile file, run this command
> docker build -t <name>[:<tag>] .
For example:
> docker build -t cms-cvmfs-docker:latest .
The name and tag choice are up to you.

### Pulling a pre-build image

If you would rather not build the image yourself, you can always check it out (pull) from DockerHub.
> docker pull aperloff/cms-cvmfs-docker[:tag]

The number of tags varies from time to time based on the current number of branches in GitHub. There will always be a `latest` tag, which is built from the master branch.

--------------------------------------------
## Container basics

### Starting the container (for the first time)

To run the container use a command similar to:
> docker run -it -P --device /dev/fuse --cap-add SYS_ADMIN -e DISPLAY=host.docker.internal:0 <name>[:<tag>]
where the name and tag will be dependent on if your accessing a local image or the pre-built from DockerHub. For information about the name and tag choices, see the previous section on setting up the image.

You may also customize the run command with some additional options. These options and their effect are described below:
- If you would like the container to be removed immediately upon exiting the container, simply add ```--rm``` to the command.
- If you would like to limit the number of CVMFS mount points, you can add ```-e CVMFS_MOUNTS="<mounts>"```, where ```<mounts>``` is a space separated list of mount points. The accessible mount points are:
   - cms.cern.ch
   - cms-ib.cern.ch
   - oasis.opensciencegrid.org
   - cms-lpc.opensciencegrid.org
   - sft.cern.ch
   - cms-bril.cern.ch
   - cms-opendata-conddb.cern.ch
- To access a grid certificate on the host computer you will need to not only mount the directory containing the certificate files, but also map the host user's UID and GID to that of the remote user. To do this you will need to append the commands: ```-e MY_UID=$(id -u) -e MY_GID=$(id -g) -v ~/.globus:/home/cmsusr/.globus```. Though technically the local ```.globus``` folder doesn't need to be in the local users home area.
- To mount other local folders, simply add ```-v <path to local folder>:<path to remote folder>```.
- To name the container, add the ```--name <name>``` option. If you don't name the container, Docker will assign a random string name to the container. You can find the name of the container by entering the command ```docker ps -a``` on the host computer.

A full command may look something like:
> docker run --rm -it -P --device /dev/fuse --cap-add SYS_ADMIN -e CVMFS_MOUNTS="cms.cern.ch oasis.opensciencegrid.org" -e DISPLAY=host.docker.internal:0 -e MY_UID=$(id -u) -e MY_GID=$(id -g) -v ~/.globus:/home/cmsusr/.globus aperloff/cms-cvmfs-docker:latest

### Stopping a container

If you've added the ```--rm``` option to the run command, then the container will be removed once you enter the ```exit``` command from within the container and the pseudo-tty is closed.

However, if you haven't added that option, then you will need to explicitly shutdown the container. Exit as described above and then use the following command to temporarily stop the container daemon:
> docker stop <container name>

### Restarting a container

You can restart a container after it had been stopped by doing
> docker start <container name>

You may need to remount the CVMFS folders by runnign the command:
> /run.sh

### Removing a container

If you decide you no longer need that particular container (perhaps you want to start another fresh one), you can delete that container instance by doing
> docker rm <container name>

### Opening another instance into the same container

If you find you need multiple instances withing the same container you can use the following command to open a new shell in the container:
> docker exec -it <container name> bash -i

The starting path will be '/'. Without the ```-i``` command the shell will start without loading any of the interactive login scripts.

### Running a shell script upon startup (will not be interactive)

If all you'd like to do is run a single shell script or command within bash, you may pass this as the docker run "[COMMAND] [ARG...]" options. This will, in fact, be gobbled up by the 'su' command in the run.sh script which started the bash shell owned by the cmsusr user. In order to run a command, use the syntax:
> docker run <options> aperloff/cms-cvmfs-docker:latest -c <command>
where all of the docker run options have been omitted for clarity. You may run multiple commands if they are separated by "&&" and surrounded by quotes. For example:
> -c "<command> && <command>"
The '-c' option is passed to su and tells it to run the command once the shell has started up. If instead you would like to run a shell script with arguments, simply use:
> docker run <options> aperloff/cms-cvmfs-docker:latest <script> <arguments>
Please note, you cannot run multiple shell scripts as all of the scripts will be passed as arguments to the first script.

--------------------------------------------
## What can I do with this?

Now that you've started the container, you have full access to the suite of grid and CMS software.

### Setting up XRootD and VOMS software

Prerequisites:
- You've mounted oasis.opensciencegrid.org
- You've mounted you local .globus folder to /home/cmsusr/.globus
- The permissions on the .globus folder, the usercert.pem file, and userkey.pem file are correct

If you've satisfied the prerequisites, then you simply need to run the command:
> voms-proxy-init -voms cms --valid 192:00 -cert .globus/usercert.pem -key .globus/userkey.pem
For some reason you need to specify the usercert.pem and userkey.pem files manually. However, this long command has been aliased inside the ```.bashrc``` file and you simply need to type:
> voms-proxy-init

### Setting up a CMSSW area

Prerequisites:
- You've mounted cms.cern.ch

Once inside the container, you can setup the CMSSW area in the standard way

- move to the directory where you would like to checkout CMSSW
- see what CMSSW versions are available by doing
> scram list -a CMSSW 
- setup a work area for a specific version, e.g.
> scram project CMSSW_10_6_0

Note: The initial setup of the paths to the CMS software is handled within the ```.bashrc``` file. This gets you the 'cmsrel' and 'scram' commands, among others.

--------------------------------------------
## Acknowledgements

This work was based largely on the following work of others

https://twiki.cern.ch/twiki/bin/view/Main/DockerCVMFS

https://github.com/cms-sw/cms-docker/blob/master/cmssw/Dockerfile

http://cmsrep.cern.ch/cmssw/cms/slc6_amd64_gcc530-driver.txt

https://github.com/Dr15Jones/cms-cvmfs-docker

Special thanks goes to Burt Holzman for figuring out how to map the UID/GID and allowing for X11 access without breaking the Fermilab computing policy.
