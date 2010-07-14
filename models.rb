class Template < ActiveRecord::Base
end

class Letter < ActiveRecord::Base 
  belongs_to :template

  def render
    m = Mustache.new
    m.template = template.source
    m[:body] = RDiscount.new(body).to_html
    m.render
  end
end

