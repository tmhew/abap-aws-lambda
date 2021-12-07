# AWS Lambda for ABAP
AWS Lambda API for ABAP

## Setting up

Import the following library in your ABAP platform to use AWS Lambda for ABAP:

+ [AWS Signature V4 for ABAP](https://github.com/tmhew/abap-aws-sigv4)

Import relevant lambda API SSL certification to `STRUST` under `SSL client SSL Client (Standard)`. Below is an example how you can go about doing it.

```sh
openssl s_client -connect lambda.us-east-1.amazonaws.com:443 -showcerts

# Copy the content of the certificate for 
#  0 s:CN = lambda.us-east-1.amazonaws.com
#   i:C = US, O = Amazon, OU = Server CA 1B, CN = Amazon
# -----BEGIN CERTIFICATE-----  
# Copy this content to a text file and upload the text file to STRUST
# -----END CERTIFICATE-----
```
