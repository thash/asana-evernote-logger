require 'erb'
require 'cgi'
require 'date'
require 'active_support/time_with_zone'
require 'bundler'
Bundler.require(:default, :development)

VERSION = 'v2'

secret = YAML.load(open('../secret.yml').read)

class AsanaFetcher
  def initialize(secret)
    @secret = secret
    @client = ::Asana::Client.new do |c|
      c.authentication :access_token, @secret['asana']['personal_access_token']
    end
  end

  # date = Date.parse(ARGV[0] || Time.now.to_s)
  def fetch(completed_since: )
    Asana::Resources::Task.find_all @client,
      workspace: @secret['asana']['workspace_id'],
      assignee: :me,
      completed_since: "#{completed_since.to_s}T00:00:00.000Z",
      # specify fields to be returned
      options: {
      fields: %w$
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
    $
    }
  end
end

class NoteManager
  attr_accessor :note_tag

  def initialize(secret, template: './template.html.erb', note_tag: nil)
    @template = template
    @note_tag = note_tag
    @enutils = ENUtils::Core.new(secret['evernote']['developer_token'])
  end

  # save workflow/status into DynamoDB
  def process(task)
    save(task)
  end

  def save(task)
    erb = ERB.new(open(@template).read)
    @enutils.create_note(title: task.name,
                         notebook: @enutils.notebook('Asana'),
                         tag: note_tag && @enutils.tag(note_tag) || @enutils.create_tag(name: note_tag),
                         from_html: true,
                         content: erb.result(binding)) # local variable 'task' will be passed
  end
end


asana   = AsanaFetcher.new(secret)
manager = NoteManager.new(secret, template: '../template.html.erb',
                                  note_tag: "asana-evernote-logger.#{VERSION}")

task_completed = asana.fetch(completed_since: Date.parse(ARGV[0] || Time.now.to_s))
                      .select{|t| t.completed }.sample(5) # TODO: remove sample()

task_completed.each do |task|
  manager.process(task)
  sleep 5
end
