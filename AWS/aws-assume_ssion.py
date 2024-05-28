import boto3 # AWS SDK for Python (Boto3) 'pip install boto3'

sts_client = boto3.Session(profile_name='default').client('sts')

arn_role = "" # Example "arn:aws:iam::532587168180:user/myuser"

assumed_role_object = sts_client.assume_role(
    RoleArn=arn_role,
    RoleSessionName="AssumeRoleSession",
)

print(assumed_role_object.get('Credentials').get('AccessKeyId'))