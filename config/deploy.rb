set :repo_url,        'git@github.com:AIESEC-no-Brasil/bazicon.git'
set :application,     'bazicon'
set :user,            'ubuntu'
set :puma_threads,    [4, 16]
set :puma_workers,    0

set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

set :format,        :pretty
set :log_level,     :debug
set :keep_releases, 5

set :linked_files, %w{config/database.yml config/local_env.yml}
set :linked_dirs,  %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Shoryuken'
  task :workers do
    on roles(:workers) do
      within release_path do
        execute "bundle exec shoryuken -R -C config/shoryuken.yml -d -L ~/shoryuken.log"
      end
    end
  end

  desc 'Clockwork'
  task :clock do
    on roles(:clock) do
      within release_path do
        execute 'clockwork script/clockwork_expa.rb'
        execute 'clockwork script/clockwork_podio.rb'
        execute 'clockwork script/clockwork_sync.rb'
      end
    end
  end


  # after "deploy:published", "deploy:workers"
  # after "deploy:published", "deploy:clock"

  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma