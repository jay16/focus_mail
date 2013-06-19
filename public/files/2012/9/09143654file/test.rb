#encoding : utf-8
require 'rss/1.0'         
require 'rss/2.0'         
require 'open-uri'
#p "凯迪克"
#a = [1,2,3,4]
#
#a.each do |b|
#  p b
#end
#p "===========================1"
#a.push(5)
#
#a.each do |b|
#  p b
#end
#
#p "===========================2"
#
#b = [[1,2],[2,3],[4,5]]
#
#b.each do |c|
#  p c
#end
#
#p "===========================3"
#
#b.push([6,7])
#
#b.each do |c|
#  c.each do |d|
#    p d
#  end
#end
#
#p "=============================4"
#
#a = [ 1, 2, 3..4, 'five' ]
#
#p a
#
#p "inspect\n"
#
#p a.inspect 
#
#p "map\n"
#n = 1
#p a.map{|x| [x]}
#
#p "reject\n"
#
#b = 1..5
#
#p b.reject{|x| x < 3}
#
#for i in Range.new(1,5)
#  p i
#end
#
#file = File.open("cmd.csv","w") 
#a = [[1,2,3],[1,1,3],[3,2,1]]
#a = a.sort_by{|x| x}
#p 'lldddd'
#p a[0][0]
#
#b = [1,1,3,4,2,3,5,2]
#
#p b.to_s
#
#p b.uniq.sort_by{|y| y}
#
#p "llll"
#
#p b.clear
#
#
#require 'json_builder'
#
#json = JSONBuilder::Compiler.generate do
#  name 'Garrett Bjerkhoel'
#  email 'spam@garrettbjerkhoel.com'
#  url root_path
#  address do
#    street '1234 1st Ave'
#    street2 'Apt 1'
#    city 'New York'
#    state 'NY'
#    zip 10065
#  end
#  key :nil, 'testing a custom key name'
#  skills do
#    ruby true
#    asp false
#  end
#  longstring do
#    # Could be a highly intensive process that only returns a string
#    '12345' * 25
#  end
#end
#
#p json
#p json.to_json
#
#sql = "delete from rulenumbers where created_at >= '" + Time.new.strftime("%Y-%m-%d") + "'"
#p sql
#gsub(/<\/?font[^>]*>/){|html| ""}

#w = "kdkdkd<![CDATA[acccdd]]>lldld"
#puts w.gsub(/<!\[CDATA\[.*?\]>/){|html| ""}
#
#puts (w.gsub(/\<\!\[CDATA\[[^\]]/){|text| ""}).gsub(/\]\]>/){|text| ""}
#
#puts w.gsub(/<\/?!\[CDATA\[/){|html| ""}
#require 'yaml'
#hash = {'txt' => {1 => "http://news.google.com.hk/news?hl=zh-CN&gl=cn&q=%s&um=1&ie=UTF-8&output=rss", 2 => 'postgresql', 3 => 'mssql', 4 => 'mysql', 5 => 'oracle'}}
#hash['txt'][6] = 'abcdd'
# 
## write yaml file
#File.open("/home/user002/data.yaml", "wb") {|f| YAML.dump(hash, f) }
#
#data = YAML.load(File.open("/home/user002/data.yaml"))
#@txtkeyword = 'oode'
#@url = data['txt'][1] %@txtkeyword
#
#puts @url


#@str = "http://news.baidu.com/ns?word=%s&ie=UTF-8&tn=newsrss&sr=0&cl=20&rn=10&ct=0"
#@str = @str % '1','2'
#puts @str
#@strfeed = "https://www.google.com.hk/search?hl=zh-CN&newwindow=1&safe=strict&gl=cn&tbs=cdr%3A1%2Ccd_min%3A2012-4-20%2Ccd_max%3A2012-4-20&tbm=nws&q=%E4%B8%AD%E5%9B%BD&oq=%E4%B8%AD%E5%9B%BD&aq=f&aqi=&aql=&gs_nf=1&gs_l=serp.3...5295.16418.0.16808.11.11.0.0.0.0.534.1795.0j1j3j0j1j1.7.0.7YzO8iV06Qo"
#puts URI.decode(@strfeed)

#exec '/usr/bin/wkhtmltopdf --print-media-type "http://192.168.186.135:3000/pdfcreate/index" /home/work/rssread/public/pdf/output_1335494842.pdf'
#file = File.open('基础词库.txt')
#file.each do |f|
#  puts f.gsub(/[a-z]/, '')
#end

#require 'toPinyin'  
#words = "  
#人  
#没有  
#理想  
#跟  
#咸鱼  
#有  
#什么  
#区别  
#".split("\n")  
# words.sort! {|a ,b|   a.pinyin.join <=> b.pinyin.join } 
# 
#words.each do |w|
#  puts w.pinyin.join
#end

contant= "<div> <img   src= '../bannersms.jpg '> </div><div> <img   src= '../images/bannersms.jpg '></div>"
str= /<img\s+.*\s*src= \'+.*\s\'\/{0,1}> /

con=/(<img).+(src=\"?.+)\/(.+\.(jpg|gif|bmp|bnp|png)\"?).+>/.match(contant)
con=con.to_s.split("/>")[0]+"/>" 

m = str.match(contant)

#s = /<img.*?src=\'([^\']+)\'.*?>/.match(contant)
#puts s[0]

#puts con

strcon = "<img src=""http://img.cn.com/a/latest.gif"" /> <img src=""http://img.cn.com/topics/latest.gif"" /> <img src=""http://img.cn.com/b/free/latest.gif"" /> <img src=""http://img.cn.com/topics/latest.gif"" /> <img src=""http://img.cn.com/main/c/latest.gif"" />"
strcon1 = "<div><img src='http://img.cn.com/a/latest.gif' /></div> <img src='http://img.cn.com/topics/latest.gif' /> <img src='http://img.cn.com/b/free/latest.gif' /> <img src='http://img.cn.com/topics/latest.gif' /> <img src='http://img.cn.com/main/c/latest.gif' />"
@abc =Regexp.new("http://img.cn.com/a/latest.gif")
#puts strcon.gsub(@abc,'')
str1 = /<img[^>]*?src=(['""\s]?)((?:(?!topics)[^'""\s])*)\1[^>]*?>/.match(strcon)
str2 = strcon.scan(/<img[^>]*?src=(['""\s]?)((?:(?!topics)[^'""\s])*)\1[^>]*?>/)
str3 = strcon.scan(/src='"".*?""/)
str4 = strcon1.scan(/<img[^>]*?src=(['\s]?)(([^'\s])*)[^>]*?>/)
puts str2.length
@i = 1
str4.each do |s|
  urlimg = s[1].to_s
  if urlimg != "" && urlimg != nil then
    urlimgs = urlimg.split("/")
    uinum = urlimgs.length
    puts urlimgs[uinum-1]
  end
  puts s[1]
  strcon1 = strcon1.gsub(Regexp.new(s[1]), @i.to_s)
  #puts strcon1
  @i = @i + 1
end
puts strcon1

strcon2 = "<ul>
<li><a href=""jingdong1"" target=""blank"">jingdong_name</a></li>
<li><a href=""printer1"" target=""blank"">printer_name</a></li>
</ul>
Best Regards!"
#"<a href=""http://www.abc.com"" target=""blank"">kdkde_ldld</a><a href=""http://www.def.com"" target=""blank"">def</a><a href=""http://www.ghi.com"" target=""blank"">ghi</a>"
#puts strcon2.scan(/<a[^>]*?href=(['\s]?)(([^'\s])*)[^>]*?>/)

#puts strcon2.scan(/<a[^>]+>(...)<\/a>/)

str5 = strcon2.scan(/<a[^>]*?href=(['\s]?)(([^'\s])*)[^>]*?>/)
astr = Array.new(str5.length){Array.new(2,0)}
@m = 0
str5.each do |s5|
  strcon2 = strcon2.gsub(Regexp.new(s5[1]), "\"$|href" + @m.to_s + "|$\"")
  astr[@m][0] = s5[1].to_s
  @m += 1
end

#strcon3 = strcon2.to_s
str6 = strcon2.scan(/<a[^>]+>(\w+)<\/a>/)
@n = 0
str6.each do |s6|
  strcon2 = strcon2.gsub(Regexp.new(s6[0]), "$|text" + @n.to_s + "|$")
  astr[@n][1] = s6[0]
  @n += 1
end

#puts strcon2

#puts astr

astr.each do |a|
  #puts a[0] + "-----" + a[1]
end

arr = Array.new(3){Array.new(3,0)}
arr = nil
##arr = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]    
#arr[1][1] = 1
#p arr.count

strimg = "dddimgkdee"

puts strimg.include? "img"


strcon4 = "<html>
<head>
<script language=\"javascript\" type=\"text/javascript\" src=\"../js/jquery-1.4.2.js\"> </script>
<script type=\"text/javascript\">
        $(document).ready(function(){
        $(\"#ctl00_ContentPlaceHolder1_EmailUser\").click(function(){
        alert(\"aaa\");
        if($(this).attr(\"Checked\"))
        {
        alert(\"bbbb\");
        }
        });
        }); 
 </script>
</head>
<body>Best Regards!</body>dddd"

str7 = strcon4.gsub(/^(.|\s)*<body.*?>/, '')
str7 = str7.gsub(/<\/body>(.|\s)*/, '')
str8 = strcon4.scan(/<body.*?>.*<\/body>/)
puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
puts str8
