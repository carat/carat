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
# Contributor(s) are refferenced within the sourcecode.
#
#
#

##############################################################################
####
####
####
##############################################################################

def instr(task)

  error=0

  # => read - read the file into array
  # => check - checking the validity of the instruction file
  # => run - process the instruction file

  print_status("Read instruction file") if task=="read"
  print_status("Check instruction file") if task=="check"
  print_status("Run instruction file") if task=="run"

  if task == "run" or task == "check"

    # run the instructions saved within sessionData
    @sessionData["instructions"].each do |line|

      # print "   > #{task}: ", line, "\n"
      #line =~ /^(r\.|l\.|remote\.|local\.){0,1}([a-zA-Z0-9_]+).*\((.*)\)$/
      # substitude placeholders
      line = line.gsub(/___RAWDIR___/, @sessionData['raw_dir'])
      line = line.gsub(/___RWORKDIR___/, @sessionData['remote_work_dir'])
      line = line.gsub(/___INSDIR___/, @sessionData['ins_dir'])
      line = line.gsub(/___IP___/, @sessionData['host'])

      line =~ /^(r\.|l\.|remote\.|local\.){0,1}([a-zA-Z0-9_]+)\((.*)\)$/

      loc=$1.to_s
      cmd=$2.to_s
      arg=$3.to_s

      # Create a argument array from "aaa","bbb","ccc"
      arg.sub!(/^"/,'')     # strip off leading "
      arg.sub!(/"$/,'')     # strip off trailing "
      args=arg.split("\",\"")

      # Print some debug information
      #print_status("  Target:[#{loc}] Cmd:[#{cmd}] Arg:[#{arg}]")
      #print_status("  > ARGS: " + args.inspect)
      print_status("Cmd:[#{cmd}] Arg:[#{arg}]")

      if loc=="l." or loc == "local."
        # Process the local commands
        case cmd
	when "msf_jobkillall_name"
          print_status("  local_msf_jobkillall_name #{arg}")
          local_msf_jobkillall_name(arg) if task=="run"
	when "msf_aux"
          print_status("  local_msf_aux #{arg}")
          local_msf_aux(arg) if task=="run"
        when "exec"
          print_status("  local_system #{arg}")
          local_exec(arg) if task=="run"
        when "ruby"
          print_status("  local_ruby #{arg}")
          local_ruby(arg) if task=="run"
        when "sleep"
          print_status("  local_sleep #{arg}")
          local_sleep(arg) if task=="run"
        when "logger"
          print_status("  local_loggr #{arg}")
          local_logger(arg) if task=="run"
		when "executescript"
			print_status(" local_executescript #{args.inspect}")
			local_executescript(args) if task=="run"
        when "upload"
          if args.length == 2
            print_status("  local_upload #{args[0]} -> #{args[1]}")
            local_upload(args[0],args[1]) if task=="run"
          elsif args.length == 3
            print_status("  local_upload #{args[0]} -> #{args[1]} -> #{args[2]}")
            local_upload(args[0],args[1],"no") if task=="run"
          else
            print_error("local_upload() needs at least 2 arguments!")
            error+=1
          end
		when "dir_download"
			if args.length == 2
            print_status("  local_dir_download #{args[0]} -> #{args[1]}")
            local_dir_download(args[0],args[1]) if task=="run"
          elsif args.length == 3
            print_status("  local_dir_download #{args[0]} -> #{args[1]} -> #{args[2]}")
            local_dir_download(args[0],args[1],"no") if task=="run"
          else
            print_error("local_dir_download() needs at least 2 arguments!")
            error+=1
          end
        when "download"
          if args.length == 2
            print_status("  local_download #{args[0]} -> #{args[1]}")
            local_download(args[0],args[1]) if task=="run"
          elsif args.length == 3
            print_status("  local_download #{args[0]} -> #{args[1]} -> #{args[2]}")
            local_download(args[0],args[1],"no") if task=="run"
          else
            print_error("local_download() needs at least 2 arguments!")
            error+=1
          end
        else
          print_error("Syntax error in instruction file: #{line}!")
          error+=1
        end
      else
        # process the remote commands
        case cmd
	    when "exec_read"
		  print_status("  remote_exec_read #{args[0]} -> #{args[1]}")
	      remote_exec_read(args[0],args[1]) if task=="run"
	
	    when "upload_exec_inmem"
		  print_status("  upload_exec_inmem #{arg}")
	      remote_upload_exec_inmem(arg) if task=="run"
		
	    when "upload_exec_read_inmem"
		  print_status("  upload_exec_read_inmem #{arg}")
	      remote_upload_exec_read_inmem(args[0],args[1]) if task=="run"	
	
        when "get_clipboard"
          print_status("  get_clipboard #{arg}")
          remote_get_clipboard(arg) if task=="run"
        when "msgbox"
          print_status("  remote_MsgboxA #{args[0]}")
          remote_MsgboxA(args[0],args[1]) if task=="run"
        when "sleep"
          print_status("  remote_sleep #{arg}")
          remote_sleep(arg) if task=="run"
        when "exist"
          print_status("  remote_exist #{arg}")
          remote_exist(arg) if task=="run"
		when "exec"
			print_status("  remote_exec #{arg}")
			remote_exec(args[0],args[1]) if task=="run"
			
        else
          print_error("Syntax error in instruction file: #{line}!")
          error+=1
        end
      end
    end
  else
    # read the instruction file(s)
    return instr_read(@sessionData["ins_dir"] + "/main.ins")
  end
  return error
end


def instr_read(file)
  print_status("  Reading instruction file #{file}")

  f = File.open(file) or begin
    print_error("Unable to open file: #{file}!")
    return 1
end

f.each_line do |line|
  line = line.strip   # strip lines

  next if line.index("#") == 0	# skip lines starting with “#”
  next if line.eql? ""			    # skip empty lines

  # if the line is a include read the file
  if line =~ /^include\s+\"*(.*?)\"$/ then
    instr_read(@sessionData["ins_dir"] + "/" + $1)
    next
  else
    # else add the command to the array
    @sessionData["instructions"].push line
  end
end
return 0
end
