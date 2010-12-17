require "fileutils"

begin

#Dir.foreach("#{File.dirname(__FILE__)}/report/raw/") do |x| 
#	next if File.extname("#{File.dirname(__FILE__)}/report/raw/#{x}") != ".xml" 
#	FileUtils.cp "#{File.dirname(__FILE__)}/report/raw/#{x}","#{File.dirname(__FILE__)}/report/intermediate/#{x}", :verbose=>true
#end

urlcounter=0
matchcounter=0

outfd = File.new("#{File.dirname(__FILE__)}/report/intermediate/outbound_results.xml","w+")

outfd.puts "<document>\n"
File.open ("#{File.dirname(__FILE__)}/report/raw/outbound_requests_sent.xml") do |infile|
	while (line = infile.gets) do
		if line =~ /<sent_req><timestamp>([^<]+)<\/timestamp><data>http:\/\/([^<]+)<\/data><\/sent_req>/
			url = $2
			time = $1
			urlcounter+=1
			found = 0
				File.open("#{File.dirname(__FILE__)}/report/raw/outbound_request_collected.xml") do |io| 
					while (line = io.gets) do
						line.chomp!
						#puts "whaa: #{line} searching for #{url}"
						if line.include? url
								matchcounter+=1
								found = 1					
						end
					end
				end	
			   outfd.puts "<request>"
			   if found == 1
				    outfd.puts "<status>Success/Unfiltered</status>"
			   else
			   		outfd.puts "<status>Failed/Blocked</status>"
			   end
			  outfd.puts "<timestamp>#{time}</timestamp><url>#{url}</url></request>"
			
		end
	end
end

outfd.puts "</document>\n"
outfd.close

puts "Test-summary: #{urlcounter} url(s) have been requested and #{matchcounter} url(s) where successful\n results written to #{File.dirname(__FILE__)}/report/intermediate/outbound_results.xml"

rescue ::Exception=>e
     puts "report-gen Error: #{e.to_s} backtrace #{e.backtrace}"
end

