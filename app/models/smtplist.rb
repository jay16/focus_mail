class Smtplist < ActiveRecord::Base
  attr_accessible :domain, :email_name, :email_port, :email_pwd, :email_smtp, :login_name
end
