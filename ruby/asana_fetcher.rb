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
