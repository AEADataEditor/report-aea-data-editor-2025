#!/bin/bash


PWD=$(pwd)
. ${PWD}/.myconfig.sh
tag=${1:-2024-06-12}
case $USER in
  codespaceX)
  WORKSPACE=/workspaces
  ;;
  *)
  WORKSPACE=$PWD
  ;;
esac
  
# pull the docker if necessary

docker pull $dockerrepo:$tag

docker run -v $WORKSPACE:/home/rstudio --entrypoint="/bin/bash" -w /home/rstudio/programs -t --rm $dockerrepo:$tag  ./run_all.sh
