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

