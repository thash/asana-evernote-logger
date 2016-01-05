require 'erb'
require 'cgi'
require 'date'
require 'active_support/time_with_zone'
require 'bundler'
Bundler.require(:default, :development)

VERSION = 'v1'

secret = YAML.load(open('../secret.yml').read)

client = Asana::Client.new do |c|
  c.authentication :access_token, secret['asana']['personal_access_token']
end

date = Date.parse(ARGV[0] || Time.now.to_s)
task_list = Asana::Resources::Task.find_all client,
  workspace: secret['asana']['workspace_id'],
  assignee: :me,
  completed_since: "#{date.to_s}T00:00:00.000Z",
  # specify fields to be returned
  options: { fields: %w$
    name
    notes
    created_at
    due_on
    completed
    completed_at
    hearted
    workspace.name
    memberships.(project|section).name
    stories
    $ }

# task_completed = task_list.select{|t| t.completed }.sample(5) # TODO: remove sample()
task_completed = task_list.select{|t| t.completed && t.hearted && t.notes.length > 0 } #.sample(5) # TODO: remove sample()

# "Consider updating your project status"
# https://app.asana.com/0/503195131478/76902390551534
# https://app.asana.com/0/000000000000/76902390551534 ;; also OK

enutils = ENUtils::Core.new(secret['evernote']['developer_token'])
tagname = "asana-evernote-logger.#{VERSION}"
evernote_tag = enutils.tag(tagname) || enutils.create_tag(name: tagname)

task_completed.each do |task|
  ap task
  erb = ERB.new(open('../template.html.erb').read)
  enutils.create_note(title: task.name,
                      notebook: enutils.notebook('Asana'),
                      tag: evernote_tag,
                      from_html: true,
                      content: erb.result(binding)) # local variable 'task' will be passed
end
