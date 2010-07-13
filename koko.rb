require "rubygems"
require "sinatra"

require 'active_record'

dbconfig = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig[ENV['SINATRA_ENV'] || 'production'])

class Template < ActiveRecord::Base
end

class Letter < ActiveRecord::Base 
  belongs_to :template
end

get "/" do
  "Well Hello There: *|FNAME|*"
end

get "/test" do
  Template.inspect
end


