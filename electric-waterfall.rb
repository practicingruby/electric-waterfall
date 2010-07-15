require "rubygems"

require "sinatra"
require 'active_record'
require "mustache"
require "rdiscount"

dir = File.dirname(__FILE__)

require "#{dir}/database_setup"
require "#{dir}/models"

SECRET = Digest::SHA1.hexdigest("A+C")


before do
  protected_route unless request.path =~ %r{^/letters/\d+/#{SECRET}}
end


helpers do
  def protected_route
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['a+c', 'a+c1337']
  end
  
  def render_letters
    @letters = Letter.all
    haml :"letters/index"
  end
end

get "/" do
  render_letters
end

get "/letters" do
  render_letters
end

get "/letters/:id/edit" do
  @letter = Letter.find(params[:id])
  haml :"/letters/edit"
end

get "/letters/new" do
  @letter = Letter.new
  haml :"/letters/edit"
end

get "/letters/:id/#{SECRET}" do 
  Letter.find(params[:id]).render
end

post "/letters" do
  letter = Letter.create(params["letter"])

  redirect "/letters/#{letter.id}/#{SECRET}"
end

put "/letters/:id" do
  letter = Letter.find(params["id"])
  letter.update_attributes(params["letter"])
  redirect "/letters/#{letter.id}/#{SECRET}"
end

delete "/letters/:id" do
  @letter = Letter.find(params["id"])
  @letter.destroy
  redirect "/letters"
end

get "/templates" do
  @templates = Template.all
  haml :"templates/index"
end

get "/templates/new" do
  @template = Template.new
  haml :"/templates/edit"
end

get "/templates/:id" do 
  redirect "/templates/#{params[:id]}/edit"
end

get "/templates/:id/edit" do
  @template = Template.find(params["id"])
  haml :"/templates/edit"
end

delete "/templates/:id" do
  @template = Template.find(params["id"])
  @template.destroy
  redirect "/templates"
end

post "/templates" do
  template = Template.create(params["template"])

  redirect "/templates/#{template.id}/edit"
end

put "/templates/:id" do
  template = Template.find(params["id"])
  template.update_attributes(params["template"])
  redirect "/templates/#{template.id}/edit"
end

get '/css/default.css' do
  sass :stylesheet
end

helpers do
  def url_for(route, object)
    if object.new_record?
      route
    else
      "#{route}/#{object.id}"
    end
  end

  def set_http_verb(object)
    unless object.new_record? 
      '<input type="hidden" name="_method" value="put">'
    end
  end
  
  def link_to_delete(path)
    %{<a href="#{path}" onclick="if (confirm('Are you sure?')) { var f = document.createElement('form');
      f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;
      var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method');
      m.setAttribute('value', 'delete'); f.appendChild(m);f.submit(); };return false;">Delete</a>
    }
  end
end