#!/bin/bash

cd $1
echo 'using GIT_ASKPASS to set credentials Syngenta Jenkins account'
echo "echo $3" > pass.sh
chmod 777 ./pass.sh
export GIT_ASKPASS=./pass.sh
git tag $2
echo Tag with name $2 created!
echo Pushing tag to repository.
git push origin $2
echo Tag pushed successfully.
rm -f ./pass.sh