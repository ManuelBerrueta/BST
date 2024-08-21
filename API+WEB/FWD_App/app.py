import os
import requests

from flask import (Flask, redirect, render_template, request,
                   send_from_directory, url_for)

app = Flask(__name__)

TARGET_URL = "https://your-target-url.com"

@app.route('/', defaults={'path': ''}, methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'])
@app.route('/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'])
def proxy(path):
    print(f"Request received: {request.method} {path}")
    
    # Construct the full URL
    url = f"{TARGET_URL}/{path}"

    # Forward headers
    headers = {key: value for key, value in request.headers if key != 'Host'}
    
    # Forward the request with the same method and data
    response = requests.request(
        method=request.method,
        url=url,
        headers=headers,
        data=request.get_data(),
        cookies=request.cookies,
        allow_redirects=False,
        params=request.args
    )


    # Construct the response
    excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
    headers = [(name, value) for (name, value) in response.raw.headers.items()
               if name.lower() not in excluded_headers]
    print(f"Response: {response.content}")

    # Return the response from the forwarded request
    return response.content, response.status_code, response.headers.items()

# This function would redirect all request to the new URL instead
#    You would use this instead of the proxy function above
#def before_request():
#    # Construct the new URL with the query string
#    new_url = TARGET_URL + request.full_path
#    return redirect(new_url, code=302)

if __name__ == "__main__":
    app.run(debug=True)