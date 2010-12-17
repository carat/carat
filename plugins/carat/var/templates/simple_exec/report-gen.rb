require "fileutils"
puts "The filedirname is #{File.dirname(__FILE__)}"

puts "The pwd using fileuitils is #{FileUtils.pwd}"

puts "\n Now the reportgenerator copies some files:\n"
#puts "#{Dir.glob('#{File.dirname(__FILE__)}/report/raw/*.xml')}"

Dir.foreach("#{File.dirname(__FILE__)}/report/raw/") do |x| 
	next if File.extname("#{File.dirname(__FILE__)}/report/raw/#{x}") != ".xml" 
	FileUtils.cp "#{File.dirname(__FILE__)}/report/raw/#{x}","#{File.dirname(__FILE__)}/report/intermediate/#{x}", :verbose=>true
end

begin
# We need to parse netstat to get it converted into an usable xml structure
outfile="#{File.dirname(__FILE__)}/report/intermediate/NETSTAT_NA.xml"
infile="#{File.dirname(__FILE__)}/report/raw/netstat_na.txt"

fd = File.new("#{outfile}", "w")

num_of_tcp_listenning=0
num_of_tcp_established=0
num_of_tcp_others=0
num_of_udp=0


fd.puts "<netstat_na>" 
  File.foreach("#{infile}") do |line|
    proto, local, remote, status = line.split

	if proto.to_s.upcase == "UDP"
		num_of_udp+=1
	elsif proto.to_s.upcase == "TCP"
		if status.to_s.upcase == "LISTENING"
			num_of_tcp_listenning+=1
		elsif status.to_s.upcase == "ESTABLISHED"
			num_of_tcp_established+=1
		else
			num_of_tcp_others+=1
		end
	end
	
    if proto.to_s.upcase == "TCP" or proto.to_s.upcase == "UDP" 
      fd.puts "<data>" 
      fd.puts "<protocol>"
      fd.puts proto.to_s
      fd.puts "</protocol>"
      
      fd.puts "<local>"
      fd.puts local.to_s
      fd.puts "</local>"
      
      fd.puts "<remote>"
      fd.puts remote.to_s
      fd.puts "</remote>"
      
      fd.puts "<status>"
      fd.puts status.to_s
      fd.puts "</status>"
      
      fd.puts "</data>" 
    end
  end
fd.puts "</netstat_na>" 

#generate the statistics chart for netstat
googlecharturl="http://chart.apis.google.com/chart?chxs=0,000000,11.5&chxt=x&chs=300x150&cht=p3&chds=-5,60&chd=t:#{num_of_udp},#{num_of_tcp_listenning},#{num_of_tcp_established},#{num_of_tcp_others}&chdl=UDP|TCP_Listening|TCP_Established|TCP_Others&chdlp=b&chp=1.11&chl=#{num_of_udp}|#{num_of_tcp_listenning}|#{num_of_tcp_established}|#{num_of_tcp_others}&chma=5,5,5,5&chtt=Connection+States&chts=000000,11.5"

system ("curl -o \'#{File.dirname(__FILE__)}/report/html/images/netstat.png\' \'#{googlecharturl}\'")




rescue ::Exception=>e
     puts "report-gen Error: #{e.to_s} backtrace #{e.backtrace}"
end
