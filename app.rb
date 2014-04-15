require 'nancy'
require 'nancy/render'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Task
  include DataMapper::Resource
  property :id, Serial
  property :name, String, required: true
  property :completed_at, DateTime
end

DataMapper.finalize

class TaskApp < Nancy::Base
  include Nancy::Render
  use Rack::MethodOverride
  use Rack::Static, :urls => ["/javascripts", "/stylesheets"], root: 'public'

  get '/' do
    redirect '/tasks'
  end

  get '/tasks' do
    @tasks = Task.all
    render('views/layout.erb'){ render 'views/index.erb' }
  end

  get '/task/:id' do
    @task = Task.get(params['id'])
    render('views/layout.erb'){ render 'views/task.erb' }
  end

  post '/task' do
    Task.create(name: params['name'])
    redirect '/tasks'
  end

  put '/task/:id' do
    task = Task.get(params['id'])
    task.completed_at = params['completed'] ? Time.now : nil
    task.name = params['name']
    redirect '/tasks'
  end

  delete '/task/:id' do
    Task.get(params['id']).destroy
    redirect '/tasks'
  end
end
