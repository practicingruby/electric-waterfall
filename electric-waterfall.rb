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
end

get "/letters" do
  @letters = Letter.all
  haml :"letters/index"
end

get "/letters/:id/edit" do
  @letter = Letter.find(params[:id])
  haml :edit_letter
end

get "/letters/new" do
  @letter = Letter.new
  haml :edit_letter
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

get "/templates" do
  @templates = Template.all
  haml :"templates/index"
end

get "/templates/new" do
  @template = Template.new
  haml :edit_template
end

get "/templates/:id" do 
  redirect "/templates/#{params[:id]}/edit"
end

get "/templates/:id/edit" do
  @template = Template.find(params["id"])
  haml :edit_template
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
end

__END__
@@ edit_letter
%h1 Edit Letter

%form{:action => url_for('/letters', @letter), :method => :post}  
  = set_http_verb(@letter)

  %p
    Name:
    %input{:name=>"letter[name]", :value=>@letter.name}
  %p 
    Template:
    %select{:name => "letter[template_id]"}
      - ::Template.all.each do |t|
        %option{:value => t.id}= t.name
      
  %p
    Body:
    %br
    %textarea{:name=>"letter[body]", :rows => 15, :cols => 100}= @letter.body

  %input{:type => :submit, :value => "Save Changes"}

@@ edit_template
%h1 Edit Template

%form{:action => url_for('/templates', @template), :method => :post}  
  = set_http_verb(@template)

  %p
    Name:
    %input{:name=>"template[name]", :value=>@template.name}
  %p 
    Source:
    %textarea{:name=>"template[source]", :rows => 15, :cols => 100}= @template.source

  %input{:type => :submit, :value => "Save Changes"}
