class CemailLog < ActiveRecord::Base
  attr_accessible :from_email, :subject, :template_id, :to_eamil, :user_id, :campaign_id
end
