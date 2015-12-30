require 'bundler'
Bundler.require

secret = YAML.load(open('../secret.yml').read)

client = Asana::Client.new do |c|
  c.authentication :access_token, secret['asana']['personal_access_token']
end

p client.workspaces.find_all

binding.pry

# [15] pry(main)> $ client.workspaces.instance_eval { @resource }.find_all
#
# From: /Users/hash/work/asana-evernote/ruby/.bundle/ruby/2.2.0/gems/asana-0.5.0/lib/asana/resources/workspace.rb @ line 49:
# Owner: #<Class:Asana::Resources::Workspace>
# Visibility: public
# Number of lines: 4
#
# def find_all(client, per_page: 20, options: {})
#   params = { limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
#   Collection.new(parse(client.get("/workspaces", params: params, options: options)), type: self, client: client)
# end


# [21] pry(main)> p Asana::Resources::Workspace.instance_methods(false);
# [:id, :name, :is_organization, :update, :typeahead, :add_user, :remove_user]

# [22] pry(main)> p Asana::Resources::Task.instance_methods(false);
# [:id, :assignee, :assignee_status, :created_at, :completed, :completed_at, :due_on, :due_at, :external, :followers, :hearted, :hearts, :modified_at, :name, :notes, :num_hearts, :projects, :parent, :workspace, :memberships, :tags, :update, :delete, :add_followers, :remove_followers, :add_project, :remove_project, :add_tag, :remove_tag, :subtasks, :add_subtask, :set_parent, :stories, :add_comment]

# -- class methods を含むのは ls ClassName.
# [7] pry(main)> ls client.tasks.instance_eval { @resource }
# Object.methods: yaml_tag
# Asana::Resources::ResponseHelper#methods: parse
# Asana::Resources::Resource.methods: inherited
# Asana::Resources::Task.methods: create  create_in_workspace  find_all  find_by_id  find_by_project  find_by_tag  plural_name
# Asana::Resources::Task#methods:
#   add_comment    add_project  add_tag   assignee_status  completed_at  delete  due_on    followers  hearts  memberships  name   num_hearts  projects          remove_project  set_parent  subtasks  update
#   add_followers  add_subtask  assignee  completed        created_at    due_at  external  hearted    id      modified_at  notes  parent      remove_followers  remove_tag      stories     tags      workspace

