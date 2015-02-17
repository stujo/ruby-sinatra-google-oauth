Sinatra Google OAuth Example
============

A sample application for Google OAuth, inspired by [queuetue's app skeleton](https://github.com/queuetue/sinatra-oauth2-google-auth-skeleton)

# Required Pre-work

* Set up a client application in [Google Developer Console](https://console.developers.google.com)
    * Set up the app with a OAuth Client Credential
        * Use ``http://localhost:9292/`` as the app url
        * Use ``http://localhost:9292/auth/callback`` as the callback url
    * Add the Google Plus API to the App
* Create a ``.env`` file in the proeject folder
```
GOOGLE_API_CLIENT="YOUR CLIENT ID HERE"
GOOGLE_API_SECRET="YOUR CLIENT SECRET HERE"
```

# Start the App
``rackup``

or

``rerun rackup``

