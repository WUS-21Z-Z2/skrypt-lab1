#!/bin/bash
sudo docker stop $(sudo docker container list -q)
