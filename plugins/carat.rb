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

# add a new path to loadpath of ruby

basepath = File.join(File.dirname(__FILE__), 'carat/')
$: << basepath

module Msf
require 'lib/stdlib.rb'

  # CaratSession is used to keep additional session dependant information bound to the session
  # a lot of the methods are available within individual modules in the directory lib
  # and are included into the session class. Even when multiple session objects are including
  # the modules, only one module will be referenced so no memory issue here i hope.
  class CaratSession
    begin
      require "fileutils"

      include CaratLib_Loging
      include CaratLib_ServerApplication
      include CaratLib_Session
      include CaratLib_Process

      def init(framework, opts, pluginName, config_dir, session, host, port, pluginclass)
        begin
          # Initialise some variables
          @framework = framework
          @opts = opts
          @pluginName = pluginName
          @pluginclass = pluginclass
          @confDir = config_dir
          @sessionData = {
            "session"=>session,				# current session
            "host"=>host,					# host name of remote host
            "port"=>port,					# port of remote host
            "framework"=>@framework,		# framework instance
            "opts"=>@opts,					# options passed by start parameter
            "pluginName"=>@pluginName,		# name of the plugin, e.g. 'carat'
            "logLevel"=>5,					# default loglevel
          }
          
          # populate session hash with startparameter
          @sessionData['logdir']=@opts['logdir']
          @sessionData['jobs_dir']=@opts['jobsdir']
          @sessionData['db']=@opts['db']
          @sessionData['templatesdir']=@opts['templatesdir']
          @sessionData['results_dir']=@opts['resultsdir']

          # Loading meterpreter extension explicit
          #  * stdapi should be loaded anyway but just to ensure stability
          #  * priv ???
          #  * session_info - Meterpreter function to get additional info into
          #    the session object. See lib/msf/base/sessions/meterpreter.rb for
          #    details. Now there is new information available via session object.
          #    session.platform will give you the os platform.
          begin
            @sessionData["session"].load_stdapi
            @sessionData["session"].load_priv
            @sessionData["session"].load_session_info
          rescue ::Exception => e
            print_error "An error occured during loading the meterpreter extension stdapi or priv or session_info: #{e}"
          end
          
          # Open the database handle and attach it to the sessionData
          # The DB-File is specified within carat.rc
          print_status "Opening database #{@opts['db']}"
          begin
            @sessionData['db']=SQLite3::Database.new( @opts['db'] )
          rescue ::Exception => e
            print_error "An error occured while opening the database: #{e}"
          end
          
          print_status "Checking now authorisation for session id: #{@sessionData["session"].sid} platform #{@sessionData["session"].platform} #{@sessionData["host"]} on port #{@sessionData["port"]}"

          # read the jobs.rc file and search for a job-id corresponding to
          # the MAC-, IP- or networks-address if there is no match the client is not allowed
          job_id,job_description,job_status,job_match,job_template=associate_job(@sessionData["session"])

          # if we didn't get a job_id this client isn't managed by carat
          # maybe you have to register the client trough the gui?
          if job_id == nil
            print_status("No job assciated with client!")
            return false
          else
            print_status("Found JobID............: #{job_id}")
            print_status("      JobDescription...: #{job_description}")
            print_status("      JobStatus........: #{job_status}")
            print_status("      JobMatch.........: #{job_match}")
            print_status("      JobTemplate......: #{job_template}")
          end
          
          # updateing the @sessionData hash
          @sessionData['job_id'] = job_id
          @sessionData['job_description'] = job_description
          @sessionData['job_status']      = job_status
          @sessionData['job_match']       = job_match
          @sessionData['job_template']   = job_template                       # This is acctualy not used since the GUI already copied the template to the jobs directory

          # check if there is already a job running on the client
          # this is remembered within the job_database status flag
          # 1 = running, 0 = not running
          if @sessionData["job_status"] == "1"
            print_status("Client has already a job running!")
            return false
          end

          # Create uniq string to create the working directory of this job
          timeStamp = "#{ Time.now.strftime("%Y%m%d.%M%S")}#{sprintf("%.5d", rand(10000))}"

          # Now we have all informations we need... lets populate the 
          # sessionData even more
          @sessionData['ins_dir'] = @sessionData['jobs_dir'] + File::SEPARATOR + @sessionData['job_id'].to_s
          @sessionData['ins_file'] = @sessionData['ins_dir'] + File::SEPARATOR + 'main.ins'
          @sessionData['work_dir'] = @sessionData['results_dir'] + File::SEPARATOR + @sessionData['job_id'].to_s + File::SEPARATOR + timeStamp
          @sessionData['raw_dir'] = @sessionData['work_dir'] + File::SEPARATOR + "report" + File::SEPARATOR + "raw"
          @sessionData['xml_dir'] = @sessionData['work_dir'] + File::SEPARATOR + "report" + File::SEPARATOR + "xml" # ATM it calls intermediate acctually...bin 
          
          @sessionData['instructions']=[] # resulting instructions defined within all files within instset
          
          # Some definitions on remote  
          @sessionData['remote_platform'] = @sessionData["session"].platform
          
          ### TODO: remote_work_dir get overwritten by session_start()!!!
          if @sessionData['remote_platform'] == 'x86/win32'  
            @sessionData['remote_tmp'] = @sessionData["session"].fs.file.expand_path("%TEMP%")	# path to remote %TEMP%
            @sessionData['remote_work_dir'] = @sessionData["remote_tmp"] + "\\carat-" + timeStamp
          else
            # TODO POSIX METERPRETER
          end 
          
          #MAX -require 'pp'
          #MAX - pp @sessionData
          
          # check if the instruction file exists else rise error
          if File.exist?(@sessionData['ins_file'])==false
            print_error("Instruction file does not exist #{@sessionData['ins_file']}")
            return false
          end

          # create the workdirectory
          print_status "Create work directory: #{ @sessionData['work_dir']}" unless File.exists?( @sessionData['work_dir'])
          FileUtils.mkdir_p(@sessionData['work_dir']) unless File.exists?( @sessionData['work_dir'])
		  
		  # now the logging can take place in here
		  @sessionData['logdir']= @sessionData['work_dir']
          
          # recursive copy the job instructions to the workingdir
          print_status "Copy instruction files to workdirectory: #{@sessionData['work_dir']}"
          FileUtils.cp_r(@sessionData['ins_dir'] + File::SEPARATOR + '.', @sessionData['work_dir'])
          
          # update the status flag of the job within the database to 1 (running)
          print_status("Setting JobStatus to running (1)")
          @sessionData['db'].execute("UPDATE Job SET JobStatus=\"1\" WHERE Match==\"#{job_match}\"")
                    
          ######################################################################
          # First we check the instruction file given by job-id or the session
          # respectively for errors, typos and syntax. If everithing is OK we
          # are going to start the session and run the command defined within
          # the instruction file defined by the @sessionData["ins_dir"] variable

		 @sessionData['session'].response_timeout=120
          if instr("read") == 0
            print_status("Instruction file(s) readed successfully")
            if instr("check") == 0  
              print_status("Instruction file syntax OK!")
              # Lets initialize the target for the session
              session_start()
              # and run the instruction file
              instr("run")

	      # update the status flag of the job within the database to 0 (not running)
	      print_status("Setting JobStatus to idle (0) within db")
              @sessionData['db'].execute("UPDATE Job SET JobStatus=\"0\" WHERE Match==\"#{@sessionData["job_match"]}\"")


   	      return true
            end
          end
          
	      print_status("Setting JobStatus to idle (0) within db")
              @sessionData['db'].execute("UPDATE Job SET JobStatus=\"0\" WHERE Match==\"#{@sessionData["job_match"]}\"")

          # We are done, if we land here, something is wrong :-)
          @sessionData = nil
          return false
        rescue ::Exception => e
          puts "An error has occuren in init: #{e} backtrace: #{e.backtrace}"
        end # init
      end

    rescue ::Exception => e
      print_error "Had and end error in caratsession class. #{e} \nbacktrace: \n#{e.backtrace}"
    end
  end  # class CaratSession end


  ###
  #
  # This class hooks all session creation events.
  # Verifies the type to be meterpreter and gets
  # Instructions to be executed on the session
  ###
  class Plugin::Carat < Msf::Plugin

    #require "FileUtils"
    include Msf::SessionEvent

    # Initializes the Carat plugin class
    def initialize(framework, opts)
      super
      self.framework.events.add_session_subscriber(self)

      @framework = framework
      @opts = opts
      @name = name.to_s

      # check for all required parameters for carat plugin
      raise "No logdir='' parameter within carat.rc!" if @opts['logdir']==nil
      raise "No db='' parameter within carat.rc!" if @opts['db']==nil
      raise "No templatesdir='' parameter within carat.rc!" if @opts['templatesdir']==nil
      raise "No jobsdir='' parameter within carat.rc!" if @opts['jobsdir']==nil
      raise "No resultsdir='' parameter within carat.rc!" if @opts['resultsdir']==nil
      
      
      # replace ${MSF} with the root-path of the MSF
      # defined within /plugins/carat/lib/core.rb
      begin
        msfhome = Msf::Config.install_root
        @opts['logdir'].gsub!(/\$\{MSF\}/, msfhome)
        @opts['db'].gsub!(/\$\{MSF\}/, msfhome)
        @opts['templatesdir'].gsub!(/\$\{MSF\}/, msfhome)
        @opts['jobsdir'].gsub!(/\$\{MSF\}/, msfhome)
        @opts['resultsdir'].gsub!(/\$\{MSF\}/, msfhome)
      end
      
      # create the log directory if it not already exist
      print_status "Create log directory: #{@opts['logdir']}" unless File.exists?(@opts['logdir'])
      FileUtils.mkdir_p(@opts['logdir']) unless File.exists?(@opts['logdir'])
      
      # Print initialisation message
      print_good("=====================================================")
      print_good(" Carat plugin initialized waiting for session events")
      print_good("=====================================================")

    end # End initialize

    def on_session_close(session,reason='')

      if session.respond_to?("sys")
        print_status "session has closed I'm afraid"
      end

    end # End on_session_close

    def cleanup
      self.framework.events.remove_session_subscriber(self)
    end # End cleanup

    def name
      "Carat"
    end

    def desc
      "Job sheduling plugin"
    end

    # Handler for all session creation events from metaploit
    # session holds the session object provided by the multihandler
    # Most of the logic is implemented within this method
    def on_session_open(session)

      # First we verify that we are talking to a meterpreter session
      if session.type != "meterpreter"
        print_error "Wrong session type #{session.type}"
        return
      end

      # Get the host and the portnumber out of the session
      host,port = session.tunnel_peer.split(':')

      # Just checking again that there is a session available
      if session == nil
        print_error "Error: invalid session - please restart scan!"
        session.kill
        return
      else
        print_good "Got a meterpreter session #{session.sid} from #{host} on port #{port}"
      end
      @sh = CaratSession.new()
      @sh.init(@framework, @opts, @name, @config, session, host, port,self)
      session.kill

    end # end on_session_open
  end # class carat plugin end
end # module end
