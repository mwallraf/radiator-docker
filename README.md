Radiator radius server from Open System Consultants.

The Radiator radius software from OSC is commercial software that should be purchased from the OCS website and you need to  download and build the Dockerfile locally in the same folder where the Radiator source and license files are located.

Pre-requisite:

Rename the downloaded source tarball to "radiator.tgz" and copy it in the same folder als the Dockerfile before starting the build.
The content of radiator.tgz should be something like "Radiator-4.4/*"


Download the Dockerfile, build it and run:

```
cd /Users/mwallraf/
git clone https://github.com/mwallraf/radiator-docker.git
cd radiator-docker
```

**--->> copy your official radiator source files into the working folder as filename radiator.tgz <<--**

```
docker build -t mwallraf/radiator .
docker run --name radiator \ 
                   -v /Users/mwallraf/radiator-docker/etc/radiator/:/etc/radiator/ \
                   -v /Users/mwallraf/radiator-docker/log/:/var/log/radiator/ \
                   -p 1645:1645 \
                   -p 1646:1646 \
                   -d mwallraf/radiator
```

The example above clones the Dockerfile and builds the image. 

If you mount the "/etc/radiator" configuration folder then you have to make sure that it contains a valid Radiator config file with the name "radiator.cfg".

You can mount other folders for logging if required.

Expose the required ports using -p <host port>:<image port>
The ports should be defined in the radiator config file "/etc/radiator/radiator.cfg". The default example file exposes the radius auth port 1645 and radius acct port 1646

If you have mounted the "/etc/radiator" configuration folder and you have updated the 'radiator.cfg' config file then don't forget to restart the docker image.
