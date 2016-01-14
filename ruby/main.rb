require 'erb'
require 'cgi'
require 'date'
require 'active_support/time_with_zone'
require 'bundler'
Bundler.require(:default, :development)
require './asana_fetcher'
require './note_manager'


secret = YAML.load(open('../secret.yml').read)

cred = Aws::Credentials.new(secret['aws']['access_key'],
                            secret['aws']['secret_access_key'])
@dynamo = Aws::DynamoDB::Client.new(region: 'ap-northeast-1', credentials: cred)


asana   = AsanaFetcher.new(secret)

version = "asana-evernote-logger.#{`git rev-parse HEAD`.chomp[0..6]}"
manager = NoteManager.new(secret, template: '../template.html.erb',
                                  version: version)

task_completed = asana.fetch(completed_since: Date.parse(ARGV[0] || Time.now.to_s))
                      .select{|t| t.completed }
task_completed = task_completed.sample(ARGV[1].to_i) if ARGV && ARGV[1]

puts "logging #{task_count = task_completed.count} tasks..."
task_completed.each_with_index do |task, i|
  manager.process(task)
  sleep 5 unless task_count == i + 1
end
