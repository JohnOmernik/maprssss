#!/bin/bash

. ./env.list

sudo docker build -t $APP_IMG .


if [ "$?" == "0" ]; then
    echo "Image Build - Sucess!"
else
    echo "Image did not build correctly"
    exit 1
fi
