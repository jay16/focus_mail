class ClickinfoController < ApplicationController  
  layout "appclickinfo"
  
  def index
    @c_id = params[:c_id]
    template= Rails.root.join("app","views","clickinfo","templates","#{@c_id}.html.erb")
    @c_id = -1 unless File.exists?(template)
    
    respond_to do |format|
      format.html #{ render :layout => false }
    end
  end
  
  def clickinfo
    campaign_id = params[:campaign_id]
    
    arr_clicks, @tname = perform(campaign_id)
    
    count_clicks = Array.new
    if arr_clicks.present?
      arr_clicks.each do |hlink|
        count_clicks.push(
          {:link_id => hlink[:l],
           :campaign_id => hlink[:c],
           :click_num => Click.find(
             :all, 
             :conditions => ["link_id = ? and campaign_id= ?", hlink[:l],hlink[:c]]).length})
      end
      #提前排序
      count_clicks.sort!{ |x,y| y[:click_num] <=> x[:click_num] }
    end
    @rank_clicks = rank(count_clicks)

    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  
  #综合报表
  def report
    if params[:c_id].present?
      @report = IntegratedData.find_by_campaign_id(params[:c_id])
      @campaign = Campaign.find(params[:c_id])
      @bi_over = true
      if @report.present?
       #@report.member_num,@report.member_unvalid = update_member(@campaign)
      else
       @bi_over = false
      end
    else
      @campaign = nil
    end

  end


  def rank(array)
    click_num = 0
    rank_index = 1
    array.each_with_index do |item,index|
      if item[:click_num] == 0
        item.merge!({:zero => 1})
      else
        item.merge!({:zero => 0})
      end
      if index == 0
        item.merge!({:rank => rank_index})
        click_num = item[:click_num]
        rank_index += 1
      else
        if item[:click_num] == click_num
          item.merge!({:rank => array[index-1][:rank_index]})
        else
          item.merge!({:rank => rank_index})
          click_num = item[:click_num]
          rank_index += 1
        end
      end
    end
    array
  end
  
  def test
    a = Link.find_by_id(168)

    puts a.url
    render :text => a.url
  end
  
  
  def perform(id)
    @campaign = Campaign.find(id.to_i)
    from_name = @campaign.from_name
    from_email = @campaign.from_email
    from = from_name.present? ? %{"#{from_name}" <#{from_email}>} : from_email
    subject = @campaign.subject
    
    alink = nil
    fname = nil
    if @campaign.template.present?
      template_name = @campaign.template.file_name
      
      template_img_url = @campaign.template.img_url
      
      memberarray = Array.new
      @campaign.lists.collect(&:members).flatten.each do |member|
        memberarray.push(member.id)
      end
      members = Member.find(memberarray.uniq)
      if members.count > 0 then
          to_email = "hello"
          to_name = id.to_s
          alink,fname = email_with_template_job(from_email, from, to_email, to_name, members.first.id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url)
      end
     else
       alink = []
       fname = ''
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
    #删掉开信记录的图片
    #bodyhtml << %Q{<img src="http://#{readip}:#{readport}/track.gif?c=#{campaign_id}&u=#{member_id}" style="display:none" />}
    bodyhtml << "</body>"
    
    sendmail= Rails.root.join("app","views","clickinfo","templates","#{to_name}.html.erb")
    unless File.exists? sendmail
      file = File.open(sendmail,"w")
      file.print(bodyhtml.to_s)
      file.close
      puts "*"*50
      puts "write"
    else
      puts "*"*50
      puts "no write"
    end

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
    puts "@"*50
    puts "#{template.file_name}.html.erb"
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
        if %r{^(http|https)://(.*)}.match(e.default_value)
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
