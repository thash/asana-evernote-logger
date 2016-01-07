require 'erb'
require 'cgi'
require 'date'
require 'active_support/time_with_zone'
require 'bundler'
Bundler.require(:default, :development)
require './asana_fetcher'
require './note_manager'

VERSION = 'v2'

secret = YAML.load(open('../secret.yml').read)

asana   = AsanaFetcher.new(secret)
manager = NoteManager.new(secret, template: '../template.html.erb',
                                  note_tag: "asana-evernote-logger.#{VERSION}")

task_completed = asana.fetch(completed_since: Date.parse(ARGV[0] || Time.now.to_s))
                      .select{|t| t.completed }.sample(5) # TODO: remove sample()

task_completed.each do |task|
  manager.process(task)
  sleep 5
end
