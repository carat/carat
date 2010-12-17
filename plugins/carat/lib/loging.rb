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

module CaratLib_Loging

  # Wrapper method that calls the metasploit print_line method
  # and log the unmodified text to the session logfile
  def print_line(text)
	@pluginclass.print_line("#{text}")
	self.log("INFO","CARAT",text)
  end

  # Wrapper method that calls the metasploit print_good method
  # and log the good status text to the session logfile
  def print_good(text)
	@pluginclass.print_good("#{text}")
	self.log("GOOD","CARAT",text)
  end

  # Wrapper method that calls the metasploit print_error method
  # and log the error text to the session logfile
  def print_error(text)
	@pluginclass.print_error("#{text}")
	self.log("ERROR","CARAT",text)
  end

  # Wrapper method that calls the metasploit print_status method
  # and log the status text to the session logfile
  def print_status(text)
	@pluginclass.print_status("#{text}")
	self.log("STATUS","CARAT",text)
  end

  # Log given text to defined the status logfile of the session.
  # * logLevel 1 = Silent, don't log anything to logfile
  # * logLevel 2 = Log errors to the session logfile
  # * logLevel 3 = Log errors and good messages to logfile
  # * logLevel 4 = Log errors,good and status messages to logfile
  # * logLevel 5 = Log everything to logfile
  #
  # The logLevel can be changed during executing when using Session.logLevel(number)
  # The instruction Session.log can be used within an instruction file as well.
  #

  def log(type, who, text)
	logDir = @sessionData["logdir"]
	logformat = "#{Time.now.strftime("%Y-%m-%d/%H-%M-%S")}: #{@sessionData["host"]}: #{type}: #{text}"
	if File.exists?("#{logDir}#{File::SEPARATOR}status.log") == true
	  fd = File.new("#{logDir}#{File::SEPARATOR}status.log", "a")
	else
	  fd = File.new("#{logDir}#{File::SEPARATOR}status.log", "w")
	end
	if type == "ERROR"
	  fd.puts(logformat) unless @sessionData["logLevel"] < 2
	elsif type == "GOOD"
	  fd.puts(logformat) unless @sessionData["logLevel"] < 3
	elsif type == "STATUS"
	  fd.puts(logformat) unless @sessionData["logLevel"] < 5
	elsif type == "INFO"
	  fd.puts(logformat) unless @sessionData["logLevel"] < 5
	end
	fd.close
	STDOUT.flush
  end

end # end module CaratLib_Loging
