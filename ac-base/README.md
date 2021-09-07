# Amazon Connect Base Installtion

To launch an Amazon Connect instance programmatically we are leveraging AWS SDK for Python (Boto3).
## Prerequisite

Tested with bash, Python3.8 and Boto3
## Usage

To deploy the solution, execute the bash wrapper script.

```bash
Usage: bash connect.sh <Connect Instance Name> <Identity> <AWS Profile name>

Example: bash connect.sh <my-instance-name> <SAML|CONNECT_MANAGED> <AWS Profile Name> 
```
## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.