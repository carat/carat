##########################################################################
##
##  associate_job - determine which job (instruction file) gets executed
##				  by the client. It compares the session-data with the
##				  jobs.rc file. Returns false if theres no job
##				  associated. Otherwise it returns the job number.
##
##  TODO: There is a Rex::Socket.cidr_crack("192.168.3.0/25") and some other
##        usefull functions (atoi...) USE THEM! or do you want to invent a 
##        foursquare wheel?
##########################################################################

def associate_job(session)
    # set variables
    db = @sessionData['db']
    target=Array.new
  
    # fill the hash
    session.net.config.each_interface do |iface|
	  next if iface.mac_addr.empty?

      mac = sprintf("%02X:%02X:%02X:%02X:%02X:%02X", iface.mac_addr[0].ord, iface.mac_addr[1].ord, iface.mac_addr[2].ord, iface.mac_addr[3].ord, iface.mac_addr[4].ord, iface.mac_addr[5].ord)
      ip = iface.ip
      netmask = iface.netmask
      bitmask = Rex::Socket.net2bitmask(netmask)
      
      # create the decimale representation of the IP and MASK to make binary calculation
      #  192.168.23.3	 => 3232241411
      #  255.255.255.0 => 4294967040
      iip	 = Rex::Socket.addr_atoi(ip)
      imask = Rex::Socket.addr_atoi(netmask)

      # The network address is <IP> AND <MASK>
      #  192.168.23.3 AND 255.255.255.0 => 192.168.23.0
      #  3232241411 AND 4294967040 => 3232241408
      inetwork = iip & imask
      
      # convert back to ASCII
      network = Rex::Socket.addr_itoa(inetwork)
      
      # and build cidr
      cidr = "#{network}/#{bitmask}"
      
      # push into array (one entry per interface)
      target.push({
        "mac" => mac,
        "ip" => ip,
        "cidr" => cidr,
      })
	  
    end
    
    # now loop trough the target array of hashes
    target.each do |iface|
      # this looks like a loopback interface so skip it
      # TODO: what about multicast? do we have to match them also?
    
      next if iface['cidr'] == "127.0.0.0/8"
	  next if iface['cidr'] == "0.0.0.0/0"
	  next if iface['ip'] == "0.0.0.0"
      next if iface['cidr'].empty? and iface['ip'].empty? and iface['mac'].empty?
	  next if iface['cidr'].nil? and iface['ip'].nil? and iface['mac'].nil?

	  print_good("Matching the interface information again the database now: #{iface.inspect}")

      match = db.get_first_row("SELECT * FROM Job WHERE Match==\'#{iface['mac']}\'")
	  if match 
	  	print_good("The database returned the following matching row #{match}")
		return match
      end
      
      match = db.get_first_row("SELECT * FROM Job WHERE Match==\"#{iface['ip']}\"")
	  if match 
	  	print_good("The database returned the following matching row #{match}")
		return match
      end

      match = db.get_first_row("SELECT * FROM Job WHERE Match==\"#{iface['cidr']}\"")
	  if match 
	  	print_good("The database returned the following matching row #{match}")
		return match
      end
    end

    # we havent found a mac, ip or cidr... this client isn't managed by carat
    return nil
end ### END def associate_job

