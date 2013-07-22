pid_file = "ganso.old.csv.pid"

statu = []

lines = File.readlines(pid_file)
lines.each do |line|
 csv  = line.split(/,/)
 file = csv[0]
 pid  = csv[1].to_i
 
 begin
   Process.kill(-0,pid)
 rescue Errno::ESRCH => e
   statu << ["stopped",pid,file]
   #puts "#{pid} - #{file} has stopped!"
 else
   statu  << ["running",pid,file]
   #puts "#{pid} - #{file} is running..."
 end

end

statu.sort! { |x,y| x[0] <=> y[0] }
statu.each do |arr|
 file = arr[2]
 org = File.readlines(file)
 ret = File.exist?("#{file}_result.csv") ? File.readlines("#{file}_result.csv") : []
 printf("org:%5d - ret:%5d - %20s %5s\n",org.size,ret.size,arr[2],arr[0])
end
