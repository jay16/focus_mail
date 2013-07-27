require 'yaml'
require 'yaml/store'

path = "/home/work/focus_mail//public/openapi/jay_li-intfocus.com.yaml"

yaml = YAML.load_file(path)

times = []
yaml.each do |dd|
  puts dd[0]
  times.push(dd[0])
end
times.sort!
puts times
