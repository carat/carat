##
# $Id: http.rb 7248 2009-10-25 17:18:23Z hdm $
##

##
# This file is part of the Metasploit Framework and may be subject to 
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##


require 'msf/core'


class Metasploit3 < Msf::Auxiliary

	include Msf::Exploit::Remote::TcpServer
	include Msf::Auxiliary::Report

	
	def initialize
		super(
			'Name'        => 'Authentication Capture: outbound',
			'Version'     => '$Revision: 7248 $',
			'Description'    => %q{
				This module provides a fake HTTP service that
			is designed to capture request.
			},
			'Author'      => ['ddz', 'hdm','mmo'],
			'License'     => MSF_LICENSE,
			'Actions'     =>
				[
				 	[ 'Capture' ]
				],
			'PassiveActions' => 
				[
					'Capture'
				],
			'DefaultAction'  => 'Capture'
		)

		register_options(
			[
				OptPort.new('SRVPORT',    [ true, "The local port to listen on.", 80 ]),
				OptPath.new('SITELIST',   [ false, "The list of URLs that should be used for cookie capture", 
						File.join(Msf::Config.install_root, "data", "exploits", "capture", "http", "sites.txt")
					]
				),
				OptPath.new('TEMPLATE',   [ false, "The HTML template to serve in responses", 
						File.join(Msf::Config.install_root, "data", "exploits", "capture", "http", "index.html")
					]
				),
				OptPath.new('FORMSDIR',   [ false, "The directory containing form snippets (example.com.txt)", 
						File.join(Msf::Config.install_root, "data", "exploits", "capture", "http", "forms")
					]
				),
				OptAddress.new('AUTOPWN_HOST',[ false, "The IP address of the browser_autopwn service ", nil ]),
				OptPort.new('AUTOPWN_PORT',[ false, "The SRVPORT port of the browser_autopwn service ", nil ]),
				OptString.new('AUTOPWN_URI',[ false, "The URIPATH of the browser_autopwn service ", nil ]),
			], self.class)
	end

	def run
		@formsdir = datastore['FORMSDIR']
		@template = datastore['TEMPLATE']
		@sitelist = datastore['SITELIST']
		@myhost   = datastore['SRVHOST']
		@myport   = datastore['SRVPORT']
		
		@myautopwn_host =  datastore['AUTOPWN_HOST']
		@myautopwn_port =  datastore['AUTOPWN_PORT']
		@myautopwn_uri  =  datastore['AUTOPWN_URI']
		@myautopwn      = false
		#@outputfile = datastore['OUTPUTFILE']
				
		exploit()
	end
	
	def on_client_connect(c)
		c.extend(Rex::Proto::Http::ServerClient)
		c.init_cli(self)
	end
	
	def on_client_data(cli)
		begin
			data = cli.get_once(-1, 5)
		
			raise ::Errno::ECONNABORTED if !data or data.length == 0

			dispatch_request(data)
			close_client(cli)
		rescue ::Exception
			print_status("Error: #{$!.class} #{$!} #{$!.backtrace}")
		end
	
		close_client(cli)
	end

	def close_client(cli)
		cli.close
		# Require to clean up the service properly
		raise ::EOFError
	end
	
	def dispatch_request(data)		
		puts "\nReceived Request:#{data}\n\n"
		destfile="#{datastore['raw_dir']}/outbound_request_collected.xml"
		fd = File.open("#{destfile}", "a") 
	        fd.puts "<received_req><timestamp>#{Time.now}</timestamp><data>#{data}</data></received_req>"
	        fd.close
		return		
	
	end
end
