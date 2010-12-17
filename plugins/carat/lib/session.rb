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

module CaratLib_Session
  # Does force CARAT not to clean up the workspace
  def dont_close(args)
    begin
      @sessionData["dont_close"] = true;
    rescue ::Exception=>e
      print_error "dont_close: An error has occured: #{e.to_s}"
    end
  end

  # Create a working directory for carat on the remote system
  # In case of failure the return value is an empty sting ""
  # Currently %TEMP%\\carat is used. Might be good to check %USERPROFILE%
  # in case the regular one does not work.
  # Important: If the directory is already existing on the remote host
  # the existing path will be returned (Directory will not be overwritten)
  def createremoteTmpDir(args='')
    begin
      rtmpdirname = "#{@sessionData["session"].fs.file.expand_path("%TEMP%")}\\carat"

      # If the directory already exists
      if @sessionData["session"].fs.file.stat(rtmpdirname).ftype() == "directory"
        print_status("Remote temporary directory did already exist: #{rtmpdirname}")
        return "#{rtmpdirname}\\"
      end
    rescue ::Exception=>e
      # When the directory is inexisting we get and exceptio, that we can ignore
    end

    begin
      # it does not exist so try to make the directory at the target host
      # No return value here just 0 but exception if not successfull.
      @sessionData["session"].fs.dir.mkdir("#{rtmpdirname}")

      # Verify that the directory was made successfully
      if @sessionData["session"].fs.file.stat(rtmpdirname).ftype() != "directory"
        #something went wrong cannot find made directory return ""
        print_error("There was an error while creating the directory #{rtmpdirname} on the remote host")
        return ""
      else
        print_good("Remote host temporary directory #{rtmpdirname} created")
        return "#{rtmpdirname}\\"
      end
    rescue ::Exception=>e
      print_error("There was an error while creating the directory #{rtmpdirname} on the remote host: #{e}")
    end
  end #End createremoteTmpDir

  # Initializes the working environment for carat on the remote host.
  # Steps involved:
  # * Creating the temporary directory
  # * More might follow, something like copy certain files etc.

  def session_start(args='')
    begin
      path = createremoteTmpDir
      if path.to_s.strip == ""
        print_error("session_start: Could not create temporary directory on remote host. Exiting ...")
        #@sessionData["session"].kill
        return false
      else
        @sessionData['remote_work_dir'] = path
        print_good("Remote working environment created and prepared at #{path}")
      end
    rescue ::Exception=>e
      print_error("session_start: Error while creating the temporary directory on remote host: #{e.to_s} \n backtrace: \n #{e.backtrace}")
      return false
    end
    return true
  end # session_start


  # When a carat session is about to be closed, different things might be conducted like
  # cleaning remote directory , report triggering etc.
  # The following actions are take inside of this method:
  # * Removing remote directory

  def session_end(args="")
    logDir = @sessionData["logDir"]

    # finish connection, clean up workspace
    begin
	

     print_good("Session_end: Cleanup command executed and ended")

    rescue ::Exception=>e
      print_error("Session_end: Unable to clean up the workspace: #{e.to_s}")
    end

    print_good("Session_end: Finished")
  end

end #CaratLib_Session
