# Image Inspection 

## Local Image Inspection
It may be the case that you may need to inspect an image that is in a tarball.

## File system extraction from local or acquired tarball
Leverage the shell script `extract_docker_image.sh`

## Get the image metadata, including environment variables:
To extract the file system you can follow the instructions below:
1. Load the Image
```sh
 docker load -i <image-file_name>.tar
```
> In the output you will get the imagename:tag

2. Inspect the image using the imagename:tag from the output of Step 1
```sh
docker inspect <imagename:tag>
```

3. Just the environment variables:
```sh
docker inspect <imagename:tag> | jq '.[0].Config.Env'
```

## Trivy Image Scan
```sh
 docker run  -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image <local-image_Name>:<Tag>
```
