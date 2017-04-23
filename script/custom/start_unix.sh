#bundle exec puma -e production -d -b unix:///var/run/discourse.sock --pidfile tmp/pids/discourse.pid
bundle exec puma -d -b unix:///var/run/discourse.sock --pidfile tmp/pids/discourse.pid