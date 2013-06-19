class CountclicksController < ApplicationController
  def index
    @campaigns = Campaign.all
    
    respond_to do |format|
      format.html { render :layout => true }
    end
  end
  
  def refresh
    @campaign_id = params[:campaign_id]# = 20
    mstype = params[:mstype]# = "gt0"
    @arr_clicks, @fname = perform(@campaign_id)
    @count_clicks = Array.new
    @arr_clicks.each do |hlink|
      @count_clicks.push(
        {:link_id => hlink[:l],
         :click_num => Click.find(
           :all, 
           :conditions => ["link_id = ? and campaign_id= ?", hlink[:l],hlink[:c]]).length})
    end
    #提前排序
    @count_clicks.sort!{ |x,y| y[:click_num] <=> x[:click_num] }

    @rank_clicks = Array.new
    case mstype
    when "all" then @rank_clicks = @count_clicks
    when "gt0" then @rank_clicks = gt0Click(@count_clicks)
    else @rank_clicks = getRank(@count_clicks,mstype.to_i)
    end
    
    respond_to do |format|
      format.html { render :layout => false }
    end
#    render :text => @rank_clicks.to_s
  end
  
  def gt0Click(oarr)
    narr = Array.new
    oarr.each_with_index do |item,index|
      narr.push item if item[:click_num] > 0
    end
    narr
  end
  
  def getRank(oarr,ranknum)
    narr = Array.new
    oarr.each_with_index do |item,index|
      ranknum -= 1 if (narr.present?? narr[-1][:click_num] : -1) != item[:click_num]
      narr.push item
      break if ranknum < 0 
    end
    narr.delete narr[-1] if narr.size>=2 and narr[-1][:click_num] != narr[-2][:click_num]
    narr
  end
  
  def perform(id)
    @campaign = Campaign.find(id.to_i)
    from_name = @campaign.from_name
    from_email = @campaign.from_email
    if from_email != "" && from_email != nil then
      from_email_array = from_email.split("@")
      from_email = from_email_array[0] + "_#{@campaign.id}_0@" + from_email_array[1]
    end
    from = from_name.present? ? %{"#{from_name}" <#{from_email}>} : from_email
    subject = @campaign.subject
    template_name = @campaign.template.file_name
    
    template_img_url = @campaign.template.img_url
    
    memberarray = Array.new
    @campaign.lists.collect(&:members).flatten.each do |member|
      memberarray.push(member.id)
    end
    members = Member.find(memberarray.uniq)
    if members.count > 0 then
        to_email = "hello"
        to_name = "world"
        alink,fname = email_with_template_job(from_email, from, to_email, to_name, members.first.id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url)
    end
    return [alink,fname]
  end
  
  def email_with_template_job(hfrom, from, to_email, to_name, member_id, subject, campaign_id, template_id, img_url)
    readfile = YAML.load_file('config/readfile.yml')
    readip = readfile["sendip"]
    readport = readfile["sendport"]
    bodyhtml = "<body>"
    _bodyhtml,alink = display_email_job(template_id,img_url,member_id,campaign_id)
    bodyhtml << _bodyhtml
    bodyhtml << %Q{<img src="http://#{readip}:#{readport}/track.gif?c=#{campaign_id}&u=#{member_id}" style="display:none" />}
    bodyhtml << "</body>"
    

    filename = to_name
    sendmail = readfile["sendmail"].to_s + "#{filename}.html.erb"
    File.delete sendmail if File.exists? sendmail
    file = File.open(sendmail,"w")
    file.print(bodyhtml.to_s)
    file.close

    return [alink,File.basename(sendmail)]
  end
  
  def display_email_job(template_id,img_url,member_id,campaign_id)
    alink = Array.new
    readfile = YAML.load_file('config/readfile.yml')
    readip = readfile["sendip"]
    readport = readfile["sendport"]
    template = Template.find(template_id)
    if template.zip_url != nil then
      images = "/files/" + template.zip_url.to_s.split(".")[0] + "/images/"
    else
      images = "/images/"
    end
    entries = Entry.find_all_by_template_id(template_id)
    source = IO.readlines(Rails.root.join('lib/emails', "#{template.file_name}.html.erb")).join("").strip
    source = source.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
    source = source.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")
    entries.each do |e|
      if e.name.include? "img" then
        if img_url == 1 then
          source = source.gsub(/\$\|#{e.name}\|\$/, "cid:" + e.default_value.to_s)
        else
          if(e.default_value.to_s=~/http:\/\/([\w-]+\.)+[\w-]+(\/[\w-]*)?.*/) != nil then
            source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
          else
            source = source.gsub(/\$\|#{e.name}\|\$/, "http://#{readip}:#{readport}#{images}" + e.default_value)
          end
        end
        
      else
        v = e.default_value
        if %r{^http://(.*)}.match(e.default_value)
          link = Link.where(:url => v).first_or_create
          v = "http://#{readip}:#{readport}/click?u=#{member_id}&c=#{campaign_id}&l=#{link.id}"
          alink.push({:u=>"#{member_id}",:c=>"#{campaign_id}",:l=>"#{link.id}"})
          source = source.gsub(/\$\|#{e.name}\|\$/, v)
        else
          source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
        end
      end
    end
    return [source.lstrip.to_s,alink]
  end
end
