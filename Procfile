web: thin start -p 5000 --ssl --ssl-key-file server.key --ssl-cert-file server.crt
worker: sleep 10; bundle exec sidekiq -c 3