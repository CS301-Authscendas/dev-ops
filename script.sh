#!/bin/bash

cd functions && pip3 install --target ./package -r requirements.txt && cd package && zip -r ../lambda_upload.zip . && cd .. && zip -g lambda_upload.zip lambda_function.py && mv lambda_upload.zip ../