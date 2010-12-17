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

module CaratLib_ServerApplication

  def nmap_target(args)
    begin
      name = @sessionData["pluginName"]

      print_good("Starting port scan against host #{args}: nmap -vv -PN -F -sS -n -r -g 88 -oX #{@sessionData['logDir']}/out/nmap_report_dump.xml --log-errors -n #{args} > #{@sessionData['logDir']}/out/nmap_console_dump")
      ret = system("nmap -vv -PN -F -sT -n -r -oX #{@sessionData['logDir']}/out/nmap_report_dump.xml --log-errors -n #{args} > #{@sessionData['logDir']}/out/nmap_console_dump")
      if ret == true
		print_good("Portscan using nmap successfully finished")
	  else
		print_error("Portscan using nmap failed, system() returned false")
	  end

    rescue ::Exception
      if sessionClass.isDebugOn == true
        sessionClass.log_error("#{self.current_class(self.name)}.#{self.current_method}: Unable to scan the target host: #{e.to_s}, #{e.backtrace.to_s}")
      else
        sessionClass.log_error("#{self.current_class(self.name)}.#{self.current_method}: Unable to scan the target host: #{e.to_s}")
      end
    end
  end # end self.nmap

end # end module CaratLib_Application


