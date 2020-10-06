#! /bin/bash

gcloud beta compute --project=playground-timesler instances create simple-openvpn \
    --zone=us-west1-a \
    --machine-type=f1-micro \
    --can-ip-forward \
    --tags=http-server,https-server \
    --image=cos-77-12371-1079-0 \
    --image-project=cos-cloud

