#!/bin/bash

(node index.js) &
(echo "Web server started on port 8000"
./node_modules/.bin/http-server ../Client -a localhost -s -p 8000)