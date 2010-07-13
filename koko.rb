require "rubygems"

require "sinatra"
require 'active_record'
require "mustache"

dbconfig = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig[ENV['SINATRA_ENV'] || 'production'])

class Template < ActiveRecord::Base
end

class Letter < ActiveRecord::Base 
  belongs_to :template

  def render
    m = Mustache.new
    m.template = template.source
    m[:body] = body
    m.render
  end
end

get "/letters/:id" do 
  Letter.find(params[:id]).render
end

get "/test" do
  Template.inspect
end


