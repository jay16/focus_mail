#encoding:utf-8
class AnalyzerController < ApplicationController 
include AnalyzerHelper
require 'net/pop'
require 'iconv'
require 'base64'

  def index
    @email_list,@etype_list = loadinfo

  end
  
  def monitor
    if params[:user_id].present?
      @actions = ActionLog.find(:all,
        :select => "action_logs.*,users.*",
        :joins => "LEFT JOIN users ON users.id = action_logs.user_id",
        :order => "action_logs.created_at desc",
        :conditions => ["action_logs.user_id = ?",params[:user_id]]).paginate(:page => params[:page],:per_page => 20)      
    else
      @actions = ActionLog.find(:all,
        :select => "action_logs.*,users.*",
        :joins => "LEFT JOIN users ON users.id = action_logs.user_id",
        :order => "action_logs.created_at desc").paginate(:page => params[:page],:per_page => 20)
    end
  end
  
  def test
    f=format("%.2f",3/7.to_f).to_f
    cov = Iconv.new('utf-8','gbk')
    render :text => "鍏ㄦ柊浣撻獙锛屾墜鏈轰篃鑳界帺杞綉鏄撻偖绠?".encoding
  end
  
  def analyzer
   email_list,@etype_list = loadinfo
   @valid_num = 0
   email_list.inject(0) do |sum,ep| 
     isRecevied = false
     begin
     isRecevied = lastest(ep[0],ep[1],params[:analyzer_sub])[0]
     rescue => e
       puts e
     else
       etype = ep[0].split('@')[1].split('.')[0]
       valid_plus(@etype_list,etype) if isRecevied
     end
     @valid_num += 1 if isRecevied
   end

   @etype_list.each do |data|
     if data.include?(:valid_num)
       self_per = format("%.2f",data[:valid_num]/data[:num].to_f).to_f
       all_per = format("%.2f",data[:valid_num]/@valid_num.to_f).to_f
       data.merge!({:self_per => self_per,:all_per => all_per})
     else
       data.merge!({:valid_num => 0, :self_per => 0, :all_per => 0})
     end
   end

   respond_to do |format|
     format.html { render :layout => false }
   end
   #render :text => etype_list
  end
  
  def lastest(email,pwd,fsub)
    cov = Iconv.new('gbk','utf-8')
    puts email
    isContinue = true
    pop=Net::POP3.new("pop3.sohu.com")
    case email.split('@')[1]
    when 'sina.cn'
      pop=Net::POP3.new('pop3.sina.com.cn') #邮件服务->设置区->开启pop3服务
    when 'sohu.com'
      pop=Net::POP3.new("pop3.sohu.com")
    when 'intfocus.com'
      pop=Net::POP3.new('pop.ym.163.com')
    when '126.com'
      pop=Net::POP3.new('pop.126.com')
    when 'yeah.net'
      pop=Net::POP3.new('pop.yeah.net')
    else
      isContinue = false
      return [false,'暂不支持']
    end
    #('pop.qq.com') #待开启pop3服务
    #pop.start('2640332438@qq.com','focusmail')
    #pop=Net::POP3.new('pop3.live.com') #不支持pop3
    #pop.start('intfocus01@hotmail.com','focusmail1')
    #pop=Net::POP3.new('pop.mail.yahoo.com.cn',995)#不支持pop3
    #pop.start('mail_test05@yahoo.cn','focusmail1')
    if isContinue
    pop.start(email.to_s,pwd.to_s)
    isRecevied = false
    sub = ''
    if pop.mails.empty?
      sub = '无邮件'
    else  
      current = pop.mails.reverse![0]
      info = current.header.split("\r\n").grep(/^Subject:/)[0]
      begin
       sub = cov.iconv Base64.decode64(info.split("?")[-2]) if info.split("?").length>=5
      rescue => e
        puts e
      else
        isRecevied = true if sub.to_s == cov.iconv(fsub)
        puts Base64.decode64(info.split("?")[-2]).encoding
      end
    end
    pop.finish
    end
    puts [isRecevied,sub]
    return [isRecevied,sub]
  end
  
  def loadinfo
    fpath = Rails.root.join('public','emaillist.xls')
    book = Spreadsheet.open fpath
    email_list = Array.new
    etype_list = Array.new
    sheet = book.worksheet(0)
    sheet.each 1 do |row|
     row_arr = Array.new
     row.each { |data| row_arr.push(data) }
     etype = row[0].split('@')[1].split('.')[0]
     row_arr.push etype
     email_list.push row_arr
     if has_type?(etype_list,etype)
       index = etype_list.index{|h| h[:type] == etype}
       etype_list[index][:num] += 1
     else
       htype = {:type => etype,:num => 1}
       etype_list.push htype 
     end
    end
    email_list.sort!{ |x,y| y[0].split('@')[1] <=> x[0].split('@')[1] }
    return [email_list,etype_list]
  end
    
  def has_type?(array,type)
    isContain = false
    array.each do |hash|
      isContain = true if hash[:type] == type
    end
    return isContain
  end
  
  def valid_plus(array,type)
    if has_key?(array,type)
      array.each do |hash|
        hash[:valid_num] += 1 if hash[:type] == type
      end
    else
      array.each do |hash|
        hash.merge!({:valid_num => 1}) if hash[:type] == type
      end      
    end
  end
  
  def has_key?(array,type)
    isContain = false
    array.each do |hash|
      isContain = hash.include?(:valid_num) if hash[:type] == type
    end
    return isContain
  end
  
end