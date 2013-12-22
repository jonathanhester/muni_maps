set :application, "muni_map"
set :repository,  "ssh://git@bitbucket.org/jhester/muni_map.git"
set :user, "jonathan"

set :deploy_to, "/var/www/muni"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "jonathanhester.com"                          # Your HTTP server, Apache/etc
role :app, "jonathanhester.com"                          # This may be the same as your `Web` server
role :db,  "jonathanhester.com", :primary => true # This is where Rails migrations will run

set :rvm_ruby_string, 'ruby-1.9.3-p327@muni_maps'

set :normalize_asset_timestamps, false

#without this, it doesn't install/update gems
require 'bundler/capistrano'

require "rvm/capistrano"

set :rvm_type, :system  # Copy the exact line. I really mean :system here

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end

after "deploy", "rvm:trust_rvmrc"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end


namespace :deploy do
  desc "Start the Thin processes"
  task :start do
    run  <<-CMD
      /etc/init.d/thin_muni start
    CMD
  end

  desc "Stop the Thin processes"
  task :stop do
    run <<-CMD
      /etc/init.d/thin_muni stop
    CMD
  end

  desc "Restart the Thin processes"
  task :restart do
    run <<-CMD
      /etc/init.d/thin_muni restart
    CMD
  end
end
