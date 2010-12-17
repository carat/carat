#
# The contents of this file are subject to the Mozilla Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is developed by Dreamlab Technologies and the team from
# remote-exploit.org. Copyright (C) 2008-2010 All Rights Reserved.
#
# Contributor(s) are refferenced within the sourcecode.
#
#
#

module CaratLib_Process
##############################################################################
# == local_exec(command)
# This command executes the command locally using system()
# ___BASE___ will be substituted with the raw dir to save results 
# ___IP___ will be substituted with the clients ip
# 
#
# === Syntax
# [+command+] The command to be executed
#
# === Usage example
#  local.exec("nmap ....")
##############################################################################
def local_exec(command)
		 system(command);
end # end local_exec


	##############################################################################
	# == wait_for_pid(pid)
	# It will just looks for a process id (PID) in the processes list on the 
	# remote host. It is used to implement a "wait for process within carat"

	#
	# === Syntax
	# [+pid+] Process id to monitor
	#
	# === Usage example
	#  r=@sessionData["session"].sys.process.execute(command, nil, {'Hidden'=>'false','Channelized'=>false})
	#  wait_for_pid(r.pid)
	##############################################################################
	def wait_for_pid(pid)
			found = 0
			while found == 0
				@sessionData["session"].sys.process.get_processes().each do |x|
					found =1
					if pid == x['pid']
						select(nil, nil, nil, 1)
						found = 0
					end
				end
			end	
	end #end wait_for_pid

	##############################################################################
	# == remote_exec(command)
	# This command executes the content of the parameter "command" on the remote host.

	#  @sessionData["session"].fs.file.stat(file).ftype()

	#
	# === Syntax
	# [+command+] Command to be executed on the remote host
	#
	# === Usage example
	#  remote.exec("cmd.exe")
	##############################################################################
	def remote_exec(wait,command)
	  begin
		# replace $BASE$ in src with @sessionData["inputdir"]
	    command = command.gsub(/___BASE___/,  @sessionData['remote_work_dir'])
	    r=@sessionData["session"].sys.process.execute(command, nil, {'Hidden'=>'false','Channelized'=>false})	
		wait_for_pid(r.pid) if wait == "yes"
		#select(nil, nil, nil, 0.5)
	  rescue Exception => e
	    print_error "remote_exec() had an error, exception values: #{e}"
	  end # end remote_exec
	end # remote_exec

	##############################################################################
	# == remote_exec_read(command)
	# This command executes the content of the parameter "command" on the remote host.
	# and returns the output 

	#
	# === Syntax
	# [+command+] Command to be executed on the remote host
	#
	# === Usage example
	#  remote.exec_read("cmd.exe")
	##############################################################################
	def remote_exec_read(command,destfile,append=false)
	  begin
	  	 # replace $BASE$ in src with @sessionData["inputdir"]
	     command = command.gsub(/___BASE___/,  @sessionData['remote_work_dir'])
		 # replace $BASE$ in dst with @sessionData['raw-dir']
		 destfile = destfile.gsub(/___BASE___/, @sessionData['raw_dir'])

		 print_good("Process execute read with command: #{command.to_s} output will be written to #{destfile}")
	      r = @sessionData["session"].sys.process.execute(command, nil, {'Hidden' => true, 'Channelized'=>true})
	      b = ""
	      while d = r.channel.read
	        b << d
	      end
		  wait_for_pid(r.pid)
		 # select(nil, nil, nil, 0.5)
	      r.channel.close unless r==nil
# just change to append per default
		  fd = File.open("#{destfile}", "a") 
		  #fd = File.open("#{destfile}", "w") if append == false
	      fd.puts b
	      fd.close
	    rescue ::Exception=>e
	      print_status "process_execute_read Error: #{e.to_s}"
	      r.channel.close unless r==nil
		end # end of begin
	end # remote_exec_read

	##############################################################################
	# == remote_upload_exec_inmem(command)
	# This command executes the content of the parameter "command" on the remote host.

	#
	# === Syntax
	# [+command+] Command to be executed on the remote host
	#
	# === Usage example
	#  remote.exec("cmd.exe")
	##############################################################################
	def remote_upload_exec_inmem(command)
	  begin
		# replace $BASE$ in src with @sessionData["inputdir"]
	    command = command.gsub(/___BASE___/,  @sessionData['ins_dir'])
	    r=@sessionData["session"].sys.process.execute(command, nil, {'Hidden'=>'false','Channelized'=>false,'InMemory'=>true})
		wait_for_pid(r.pid)
		#select(nil, nil, nil, 0.5)
	  rescue Exception => e
	    print_error "remote_upload_exec_inmen() had an error, exception values: #{e}"
	  end # end remote_exec
	end # remote_upload_exec_inmem

	##############################################################################
	# == remote_upload_exec_read_inmem(command)
	# This command executes the content of the parameter "command" on the remote host
	# and writes its output to the destination file

	#
	# === Syntax
	# [+command+] Command to be executed on the remote host
	# [+destfile+] Command to be executed on the remote host
	#
	# === Usage example
	#  remote_upload_exec_read_inmem("/tmp/something.exe","output.txt")
	##############################################################################
	def remote_upload_exec_read_inmem(command,destfile,args=nil)
		begin
			# replace $BASE$ in src with @sessionData["inputdir"]
		    command = command.gsub(/___BASE___/,  @sessionData['ins_dir'])

		    # replace $BASE$ in dst with @sessionData['raw-dir']
		    destfile = destfile.gsub(/___BASE___/, @sessionData['raw_dir'])	

			 print_good("Process execute read with command: #{command.to_s} output will be written to #{destfile}")
		      r = @sessionData["session"].sys.process.execute(command, args, {'Hidden' => true, 'Channelized'=>true,'InMemory'=>true})
		      b = ""
		      while d = r.channel.read
		        b << d
		      end
			wait_for_pid(r.pid)
			#select(nil, nil, nil, 0.5)
		      r.channel.close unless r==nil
		      #r.close unless r==nil
		      select(nil, nil, nil, 0.5)
			  fd = File.open("#{destfile}", "w")
		      fd.puts b
		      fd.close
		    rescue ::Exception=>e
		      print_status "process_execute_read Error: #{e.to_s}"
		      r.channel.close unless r==nil
			end # end of begin
	end # remote_upload_exec_read_inmem



end # CaratLib_Process
