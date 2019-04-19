# apple_hls_put

Requires Apache webserver to be configured with a php put script.
Place this into apache httpd.conf:

```
<Directory />
Script PUT /put/put.php
</Directory>
```
Now you need to add a script that deals with the incoming ffmpeg calls.
