#!/usr/bin/env sh

export AWS_REGION=ap-southeast-2
if [ $# -lt 3 ] || [ $# -gt 3 ] ; then
    echo "Usage: bash connect.sh <Connect Instance Name> <Identity> <AWS Profile name>"
    echo "Example: bash connect.sh <my-instance-name> <SAML|CONNECT_MANAGED> <AWS Profile Name>"
    exit 1
fi

InstanceName=$1
Identity=$2
Profile=$3
# Random=`echo $RANDOM`
Function_Name="amazon-connect"
Stack_Name=${Function_Name}-"lambda"
Bucket_Name=${Stack_Name}-${Profile}-`date +%s`
Template_File="connect-lambda-cfn.yaml"
Parameter_File="params.json"

############################################ 
# "Creating Private S3 bucket and Uploading Lambda Function Zip file"
echo "Creating Private S3 bucket and Uploading Lambda Function Zip file"
############################################

aws s3api create-bucket \
    --bucket ${Bucket_Name} \
    --region ${AWS_REGION} \
    --create-bucket-configuration LocationConstraint=${AWS_REGION} \
    --profile ${Profile}

aws s3api put-bucket-encryption \
    --bucket ${Bucket_Name} \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}' \
    --profile ${Profile}

aws s3 cp ./index.zip s3://${Bucket_Name}/ \
    --profile ${Profile}

#############################################
# "Creating Cloudformation Stack to Deploy Amazon Connect Lambda Function"
echo "Creating Cloudformation Stack to Deploy Amazon Connect Lambda Function"
#############################################

Stack_Arn=$(aws cloudformation create-stack --stack-name ${Stack_Name} --template-body file://${Template_File} --parameters \
    ParameterKey=LambdaBucket,ParameterValue=${Bucket_Name} \
    ParameterKey=FunctionName,ParameterValue=${Function_Name} \
    ParameterKey=Identity,ParameterValue=${Identity} \
    ParameterKey=InstanceName,ParameterValue=${InstanceName} \
    --capabilities "CAPABILITY_IAM" \
    --profile ${Profile} | jq -r ".StackId")


aws cloudformation wait stack-create-complete \
    --stack-name $Stack_Arn \
    --profile ${Profile}

############################################
# "Invoking Amazon Connect Lambda Function"
echo "Invoking Amazon Connect Lambda Function"
############################################

aws lambda invoke \
    --function-name ${Function_Name} \
    --payload '{}' \
    --profile ${Profile} \
    response.json