require 'clockwork'
require 'git'
require 'logger'

GIT_REPO = ENV['GIT_REPO']
COMMAND = ENV['COMMAND'] || "update"

USER_NAME = ENV['USER_NAME'] || "Updater"
USER_EMAIL = ENV['USER_EMAIL'] || "updater@heroku.local"

TMP_PATH = "/tmp"

LOG = Logger.new(STDOUT)

module Clockwork

  handler do |job|
    name = "#{ job }-#{ Time.now.to_i }"
    path = "#{ TMP_PATH }/#{ name }"

    LOG.info "Cloning repo at #{ path }"

    repo = Git.clone(GIT_REPO, name, path: TMP_PATH)

    repo.config('user.name', USER_NAME)
    repo.config('user.email', USER_EMAIL)

    LOG.info "Executing updater..."

    updater_path = Dir.pwd
    Dir.chdir(path)
    result = system("#{ updater_path }/#{ COMMAND }")

    if result
      LOG.info "Updater exited successfully"
      updated = repo.status.any? { |f| f.untracked || f.type }
      if updated
        LOG.info "Changes detected. Updating repo..."
        repo.add(all: true)
        repo.commit("Updated #{ Date.today }")
        repo.push
        LOG.info "Updated"
      else
        LOG.info "No changes detected"
      end
    else
      LOG.error "Updater exited with error code #{ $?.pid }"
    end

  end

  every(1.week, 'list.update') # at: "Monday 08:00"
end
