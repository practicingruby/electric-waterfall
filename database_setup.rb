dbconfig = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig[ENV['SINATRA_ENV'] || 'production'])
