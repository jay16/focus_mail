class Entry < ActiveRecord::Base
  attr_accessible :default_value, :name, :template_id, :type
  belongs_to :template
  has_many :campaign_entries
    
  def image=(file_field)
   render "entries/preview.js.erb"
  end
end
