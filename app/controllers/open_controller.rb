require 'yaml'
require 'yaml/store'
require 'json'

class OpenController < ActionController::Base
  include ApplicationHelper
  require 'uri'
  
  def sendmail
   email = params[:email]
   name  = params[:name]
   href  = params[:href]
   campaign_id = 146

   api_path    = Rails.root.join("public/openapi")
   name = email.split(/@/)[0]

   if email and email.split(/@/).size != 2 then
     ret = { :code => -1,
       :error => {
	 :email => email,
	 :reason => "Incorrect Email Format!"
       }
     }
   elsif File.exist?(yaml_path   = File.join(api_path,"#{email.split('@').join('-')}.yaml")) then
      yaml_load   = YAML.load_file(yaml_path)
      timetags = []
      yaml_load.each do |dd|
	timetags.push(dd[0])
      end
      timetags.sort!
      lastest = timetags[-1]
      detail = yaml_load[lastest]

      if detail[:log] then
	 ret = { :code => 2,
	   :deliver => { 
	     :email     => detail[:to_email],
	     :timestamp => detail[:time],
	     :md5       => detail[:md5],
	     :mq        => detail[:mq],
	     :port      => detail[:port],
	   },
	   :log    => {
	     :content   => detail[:log]
	   }
	 }
      else
	ret = { :code => 2,
	   :deliver => { 
	     :email     => detail[:to_email],
	     :timestamp => detail[:time],
	     :md5       => detail[:md5],
	     :mq        => detail[:mq],
	     :port      => detail[:port],
	   }
	}
      end
   else
    #FocusApi::Mailer.deliver(name,email,href,campaign_id)
    ret = { :code => 1,
      :state => "deliver.."
    }

   end

    respond_to do |format|
        format.json { render :json => ret.to_json }
    end
  end

  def getstate
    email = params[:email]
    if email then
      api_path    = Rails.root.join("public/openapi")
      yaml_path   = File.join(api_path,"#{email.split('@').join('-')}.yaml")
      yaml_load   = YAML.load_file(yaml_path)
      timetags = []
      yaml_load.each do |dd|
	timetags.push(dd[0])
      end
      timetags.sort!
      lastest = timetags[-1]
      detail = yaml_load[lastest]

      if detail[:log] then
	 ret = { :code => 1, 
	   :deliver => { 
	     :email     => detail[:to_email],
	     :timestamp => detail[:time],
	     :md5       => detail[:md5],
	     :mq        => detail[:mq],
	     :port      => detail[:port],
	   },
	   :log    => {
	     :content   => detail[:log]
	   }
	 }
      else
	ret = { :code => 0, :info => "wait for log" }
      end
    else
      ret = { :info => params.to_s }
    end

    respond_to do |format|
        format.json { render :json => ret.to_json }
    end
   # render :json => ret.to_json
  end

  def getlog
   email = params[:email]
   strftime = params[:strftime]
   mq   = params[:mq]
   port = params[:port]
   log  = params[:log]
   api_path    = Rails.root.join("public/openapi")
   yaml_path   = File.join(api_path,"#{email.split('@').join('-')}.yaml")
   yaml_save = YAML::Store.new(yaml_path) 
   yaml_save.transaction do
     yaml_save[strftime][:mq]   = mq
     yaml_save[strftime][:port] = port
     yaml_save[strftime][:log]  = log
   end

    if log then
      render :json => { code => 1 }
    else
      render :json => { code => -1, :info => "#{params.to_s}" }
    end
  end

  def dd
  end
end
