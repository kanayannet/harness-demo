workers 2
threads 1, 1

port 8000
environment "development"

pidfile "tmp/pids/puma.pid"
state_path "tmp/state/puma.state"
stdout_redirect "log/puma.stdout.log", "log/puma.stderr.log", true

preload_app!
