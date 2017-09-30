# Hardening Azure Ecosystem


## RSA key

On your linux local/desktop/laptop/officeVM machine generate a RSA key

```
cd ~/.ssh
ssh-keygen -t rsa
```

When being asked to name the file, enter ```azure_key``` as a name for RSA files.


```
ssh-copy-id -i ~/.ssh/azure_key username@azure_public_ip
```

## Azure CLI on Ubuntu

Open the Bash shell

Modify your sources list
```
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
tee /etc/apt/sources.list.d/azure-cli.list
```

Run the following sudo commands
```
apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
apt-get install apt-transport-https
apt-get update && sudo apt-get install azure-cli
```

Run the CLI from the command prompt with the ```az``` command
```
Welcome to Azure CLI!
Use az -h to see available commands or go to https://aka.ms/cli.

Telemetry
The Azure CLI collects usage data in order to improve your experience.
The data is anonymous and does not include commandline argument values.
The data is collected by Microsoft.

You can change your telemetry settings with az configure.


     /\
    /  \    _____   _ _ __ ___
   / /\ \  |_  / | | | \'__/ _ \
  / ____ \  / /| |_| | | |  __/
 /_/    \_\/___|\__,_|_|  \___|


Welcome to the cool new Azure CLI!
```

### Login to Azure
To operate Azure Virtual machines from CLI, you need

```
localhost$ az login
```
To sign in, use a web browser to open the page https://aka.ms/devicelogin and enter the code to authenticate.
