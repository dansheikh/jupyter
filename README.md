# Jupyter

## Description

Containerized data science and machine learning Jupyter environment.

## Usage

### Initiation

To initiate a Jupyter environment instance in daemon mode with a default token of "zeus" execute the following:

`docker run -d --name juypter --rm -p 8888:8888 -v ~/Workspace/ipynbs/:/home/jupyter/ipynbs dansheikh/jupyter`

Upon successful execution, a docker container will be launched and jupyter notebook will automatically be run and available at: `http://127.0.0.1:8888?token=zeus`. Further, the host directory of `$HOME/Workspace/ipynbs` will be mounted within the container at `/home/jupyter/ipynbs`.

_Notes_

1. Container name may be customized by changing `--name jupyter` to `--name custom_container_name` where _custom-container-name_ is a chosen alphanumeric value.

2. Volume location may be customized by changing `-v ~/Workspace/ipynbs/:/home/jupyter/ipynbs` to `-v custom_host_location:/home/jupyter/ipynbs` where _custom-host-location_ is a chosen directory on the host.

3. Jupyter token may be customized by adding `--env JUPYTER_TOKEN=custom-jupyter-token` or `-e JUPYTER_TOKEN=custom-jupyter-token` where _custom-jupyter-token_ is a chosen alphanumeric value.

### Termination

To terminate a Jupyter environment instance execute the following:

`docker stop jupyter`

_Notes_

1. During initiation, should an alternative container name be used that name will need to be used in place of _jupyter_ during container stoppage.
