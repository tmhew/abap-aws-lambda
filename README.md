# AWS Lambda for ABAP
ABAP wrapper around AWS Lambda REST API.

## Setting up

Import the following library to your ABAP platform:

+ [AWS Signature V4 for ABAP](https://github.com/tmhew/abap-aws-sigv4)

Import relevant AWS Lambda REST API SSL certification to `STRUST` under `SSL client SSL Client (Standard)`. Below is an example how you can go about doing it.

```sh
openssl s_client -connect lambda.us-east-1.amazonaws.com:443 -showcerts

# Copy the content of the certificate with the following subject and import it to STRUST. 
#  0 s:CN = lambda.us-east-1.amazonaws.com
#   i:C = US, O = Amazon, OU = Server CA 1B, CN = Amazon
# -----BEGIN CERTIFICATE-----  
# Copy this content to a text file and upload the text file to STRUST
# -----END CERTIFICATE-----
```
## Supported Lambda Actions

These are highly opinionated wrappers around the respective Lambda actions and by no mean meant to be comprehensive. If you have use cases that are not covered by these wrappers, consider writing your own wrappers with the help of [AWS Signature V4 for ABAP](https://github.com/tmhew/abap-aws-sigv4).

| Actions | ABAP Objects |
|---------|--------------|
| [Invoke](https://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html) | [ZAWS_LMB_INVOKE](https://github.com/tmhew/abap-aws-lambda/blob/main/src/zaws_lmb_invoke.clas.abap) |

## References

+ [AWS Lambda API Reference](https://docs.aws.amazon.com/lambda/latest/dg/API_Reference.html)
+ [AWS Lambda endpoints and quotas](https://docs.aws.amazon.com/general/latest/gr/lambda-service.html)
