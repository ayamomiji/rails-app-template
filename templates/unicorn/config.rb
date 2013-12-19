app_path = File.expand_path(File.join(File.dirname(__FILE__), '../..'))

worker_processes   1
preload_app        true
timeout            60
listen             "#{app_path}/tmp/sockets/unicorn.sock"

working_directory  app_path
pid                "#{app_path}/tmp/pids/unicorn.pid"
stderr_path        "#{app_path}/log/unicorn.err.log"
stdout_path        "#{app_path}/log/unicorn.out.log"

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  GC.disable
end
