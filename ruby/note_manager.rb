class NoteManager

  def initialize(secret, template: './template.html.erb', version: nil)
    @template = template
    @version = version
    @enutils = ENUtils::Core.new(secret['evernote']['developer_token'])
    cred = Aws::Credentials.new(secret['aws']['access_key'],
                                secret['aws']['secret_access_key'])
    @dynamo = Aws::DynamoDB::Client.new(region: 'ap-northeast-1', credentials: cred)
    @table = secret['aws']['dynamo_table']
  end

  # save workflow/status into DynamoDB
  def process(task, force: false)
    task_log_line = "task {id: #{task.id}, created_at: #{task.created_at}, name: #{task.name}}"
    item = @dynamo.get_item(table_name: @table,
                            key: { task_id: task.id }).item

    if item && item['note_guid'] && !item['error'] && !force # skip
      puts "#{Time.now}: skip - #{task_log_line}"
      return
    end

    puts "#{Time.now}: logging - #{task_log_line}"
    note = save_note(task)
    dynamo_put({task_id: task.id, note_guid: note.guid})
    puts "#{Time.now}: complete"

  rescue => e
    STDERR.puts "#{Time.now}: #{e}"
    STDERR.puts "#{Time.now}: #{e.message}"
    # ref: https://dev.evernote.com/doc/reference/Errors.html#Struct_EDAMSystemException
    dynamo_put({task_id: task.id, note_guid: nil,
                error: "#{e}\t#{e.message}\t#{e.errorCode}\t#{e.rateLimitDuration}"})
  end

  def save_note(task)
    erb = ERB.new(open(@template).read)
    @enutils.create_note(title: task.name,
                         notebook: @enutils.notebook('Asana'),
                         tag: @version && @enutils.tag(@version) || @enutils.create_tag(name: @version),
                         from_html: true,
                         content: erb.result(binding)) # local variable 'task' will be passed
  end

  private def dynamo_put(attrs)
    attrs = attrs.merge(updated_at: Time.now.to_i)
    @dynamo.put_item(table_name: @table, item: attrs)
  end
end
