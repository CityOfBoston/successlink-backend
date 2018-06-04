web: bundle exec puma -b "ssl://0.0.0.0:5000?key=server.key&cert=server.crt"
worker: sleep 10; bundle exec sidekiq -c 3