### What is FWD_App?
FWD_App is a simple application using Flask that when deployed will forward all the requests to a target URL using the same method, path, query string, headers (except for the Host header of course), cookies and data(body).

This can be useful in so many ways, including in dangling domains and subdomains 😉

> NOTE: Change the **`TARGET_URL`** variable to whatever URL you want to forward the requests to.

### Testing

#### Install the requirements:
```shell
pip install requirements.txt
```
#### Run the app
```shell
flask run
```
