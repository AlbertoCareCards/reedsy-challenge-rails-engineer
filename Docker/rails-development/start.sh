#!/bin/sh
rm ./tmp/pids/server.pid
rdebug-ide --debug --host 0.0.0.0 --port 1234 -- bin/rails s -p 3000 -b 0.0.0.0
