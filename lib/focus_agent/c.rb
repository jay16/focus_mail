require './chk_email'
csv = "ganso.old.csv"
cwd = Dir.pwd
puts File.join(File.dirname(cwd),"smtp_server")

puts FocusAgent::ChkEmail.dispatch(File.join(cwd,csv))
puts Dir.pwd
