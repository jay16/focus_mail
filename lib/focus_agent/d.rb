str1 = "yrjun1985ok@vip.QQ.com"
str2 = "yrjun1985ok@QQ.com"
domain = "qq"

puts str1 =~ /@(vip.|)#{domain}/i ? str1 : "NO"
puts str2 =~ /@(vip.|)#{domain}/i ? str2 : "NO"
