#!/usr/bin/env ruby

# == Synopsis 
# This is the command line interface to carat. With it you administrate your
# jobs. Acctually it's a front end for the sqlite3 Jobs-Database.
#
# == Usage 
#  catat_cli.rb - Command line interface for carat management.
#  
#    LIST [match]                      List the current entries in database.
#    ADD match description template    Add a target
#    DEL match                         Delete a target
#    SQL command                       Execute a SQL statement
#    HELP                              Print this help screen
#  
#    match        definition of a target or destination in form of 
#                 MAC-address, IP-address or CIDR-address.
#  
#    description  Freeform text sting describing this job
#  
#    template     name of the template directory containing the task-
#                 files and job-definitions.
#  
#   Example:
#    carat_cli.rb LIST AA:BB:CC:DD:EE:FF
#    carat_cli.rb ADD 192.168.1.2/24 \"Standard LAN\" default_win32
#    carat_cli.rb DEL 192.168.1.2"
#    carat_cli.rb SQL 'SELECT * FROM Job WHERE'
#
#
# == Examples
#  carat_cli.rb LIST AA:BB:CC:DD:EE:FF"
#  carat_cli.rb ADD 192.168.1.2/24 \"Standard LAN\" default_win32
#  carat_cli.rb DEL 192.168.1.2"
#  carat_cli.rb SQL \"SELECT * FROM Job WHERE JobID='4'\""
#
# == Copyright
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
# == Database design
#  PRAGMA foreign_keys=OFF;
#  BEGIN TRANSACTION;
#  CREATE TABLE Job (
#      JobID INTEGER PRIMARY KEY AUTOINCREMENT,
#      JobDescription TEXT,
#      JobStatus INTEGER NOT NULL,
#      Match TEXT NOT NULL,
#      Template TEXT NOT NULL
#  );
#  COMMIT;

require 'sqlite3'
#require 'FileUtils'
require "fileutils"

# Carat_CLI class 
class Carat_CLI
  
  
  # == Initialize our instance class variables:
  # [@arguments] this is acctually ARGV supplied by the user
  # [@basedir] is the directory which contains this script
  # [@db specifies] the sqlite3 database file
  # [@templdir] specifies the directory which holds the various templates
  # [@jobdir] specifies the directory where the templates gets copied to
  # [@dhb] is a global handler to the database
  #
  # Create and start the application with:
  #  app = Carat_CLI.new(ARGV)
  #  app.run
  #
  def initialize(arguments)
    @arguments = arguments
    @basedir = File.expand_path(File.dirname(__FILE__))
    @db = @basedir + "/plugins/carat/var/sqlitedb/carat.db"
    @templdir = @basedir + "/plugins/carat/var/templates"
    @jobdir = @basedir + "/plugins/carat/var/jobs"
    @dbh = SQLite3::Database.new( @db )
  end
  

  # this method defines the program flow and acct acordign to the parameters 
  # supplied my the user
  def run
    help if ARGV.length < 1
    action = ARGV[0].upcase

    case action
    when "LIST"
      list
    when "ADD"
      add
    when "DEL"
      del
    when "SQL"
      sql
    else
      help
    end
  end

  # list - this method lists job entries from the database
  def list()
    # LIST can have arguments. Ether it has to be a Match or a JobID
    # If no argument is supplied we will list the whole table

    if ARGV[1] != nil
      # We have a argument, so lets figure out which it is
      if valid_match(ARGV[1])
        # This looks like a Mac-Addr or IP-Addr or CIDR
        query = " where Match=='#{ARGV[1]}'"
      elsif ARGV[1]=~/\d+/
        # We only have digits as argument, so lets assume it is a JobID
        query = " where JobID=='#{ARGV[1]}'"
      else
        puts "Error: Invalid argument to LIST!"
        exit 1
      end
    else
      # we don't have a argument so just list the whole table
      query = ""
    end

    result = @dbh.execute( "select * from Job #{query}" )
    if (result.length > 0)
      puts "+---- JID -+- Description ----------------------------+--- Status -+- Match --------------+- Template ----------+"
      result.each do |row|
        print        row[0].to_s.rjust(10)
        print " | ", row[1].to_s.ljust(40)
        print " | ", row[2].to_s.rjust(10)
        print " | ", row[3].to_s.ljust(20)
        print " | ", row[4].to_s.ljust(20),"\n"
        puts "+----------+------------------------------------------+------------+----------------------+---------------------+"
      end
    else
      puts "No Result!"
    end
  end

  #
  # add - this method adds a job entry to the database
  #
  # To successfuly add a job we must have three arguments:
  #
  # * Match
  # * Description
  # * Job-Template
  #
  #  INSERT INTO Job values(NULL,"Job Description",0,"AA:BB:CC:DD:EE:FF","win32_inventory");
  #
  def add
    match = ARGV[1]
    descr = ARGV[2]
    templ = ARGV[3]

    # Check if match arguments is valid
    if !valid_match(match) then
      puts "ERROR in argument [match]: #{match}!"
      exit 1
    end

    # Check if description is not empty
    if descr == NIL then
      puts "ERROR missing argument [description]!"
      exit 1
    end

    # Check if template is not empty
    if templ == NIL then
      puts "ERROR missing argument [template]!"
      exit 1
    end

    # Check if match already exist within database
    result = @dbh.execute("SELECT * FROM Job WHERE Match=='#{match}'")
    if result.length > 0 then
      puts "ERROR Match already exist in database!"
      exit 1
    end

    # Check if template exists
    # Dir["directory"].empty? will return true if it wasn't found.
    if Dir[@templdir + "/" + templ].empty? then
      puts "ERROR Template: #{$templdir}/#{templ} was not found!"
      exit 1
    end
    
    # Ask the DB for the next JobID
    jobid = @dbh.get_first_value("SELECT seq FROM sqlite_sequence WHERE name='Job'").to_i
    jobid += 1
     
    # Check if destination job directory exists
    if File.directory?(@jobdir + "/" + jobid.to_s) then
      puts "ERROR Template: #{@jobdir}/#{jobid} already exist!"
      exit 1
    end
 
    # copy the directory
    FileUtils::cp_r "#{@templdir}/#{templ}", "#{@jobdir}/#{jobid}" 
 
    if valid_match(match) && (descr!=NIL) && (templ!=NIL) then
      @dbh.execute("INSERT INTO Job values(NULL,'#{descr}',0,'#{match}','#{templ}')")
      puts "Done!"
    else
      puts "ERROR in argument!"
      exit 1
    end
    
 
    
  end



  # this method deletes a job entry from the database
  # You can eather delete by JobID or by Match (MAC/IP/CIDR)
  def del
    # you can delete a entry by match or by id
    if valid_match(ARGV[1]) then
      # check if the database contains such a match
      if @dbh.execute("SELECT * FROM Job WHERE Match='#{ARGV[1]}'").length > 0
        @dbh.execute("DELETE FROM Job WHERE Match='#{ARGV[1]}'")
        puts "Done!"
        exit 0
      else
        puts "ERROR: No entry matches match: #{ARGV[1]}!"
        exit 1
      end
    elsif ARGV[1]=~/\d+/ then
      # we have probably found a JobID lets see if a corresponding entry exists
      if @dbh.execute("SELECT * FROM Job WHERE JobID='#{ARGV[1]}'").length > 0
        @dbh.execute("DELETE FROM Job WHERE JobID='#{ARGV[1]}'")
        puts "Done!"
        exit 0
      else
        puts "ERROR: No entry matches JobID: #{ARGV[1]}!"
        exit 1
      end
    else
      puts "ERROR: No valid JobID or Match supplied: #{ARGV[1]}!"
    end
  end



  # this method executes sql statements supplied by the user with arguments
  def sql
    begin
      puts @dbh.execute(ARGV[1]).to_s
    rescue
      puts "An error occurred: ",$!, "\n"
      exit 1
    end
  end


  # this method displays some help on how to use the carat_cli
  def   help
    puts
    puts "catat_cli.rb - Command line interface for carat management."
    puts
    puts "  LIST [match]                      List the current entries in database."
    puts "  ADD match description template    Add a target"
    puts "  DEL match                         Delete a target"
    puts "  SQL command                       Execute a SQL statement"
    puts "  HELP                              Print this help screen"
    puts
    puts "  match        definition of a target or destination in form of "
    puts "               MAC-address, IP-address or CIDR-address."
    puts
    puts "  description  Freeform text sting describing this job"
    puts
    puts "  template     name of the template directory containing the task-"
    puts "               files and job-definitions."
    puts
    puts " Example:"
    puts "  carat_cli.rb LIST AA:BB:CC:DD:EE:FF"
    puts "  carat_cli.rb ADD 192.168.1.2/24 \"Standard LAN\" default_win32"
    puts "  carat_cli.rb DEL 192.168.1.2"
    puts "  carat_cli.rb SQL 'SELECT * FROM Job WHERE'"
    puts
    exit 1
  end

  # helper function - this function matches eather MAC's or IP's or CIDR 
  # returns 1 if matched successfully, otherwise 0
  def valid_match(match)
    return true if match=~/([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}/     # MAC
    return true if match=~/([0-9]{1,3}\.){3}[0-9]{1,3}\/*([0-9]*)/   # IP or CIDR
    return false                                                     # everything else
  end
  
end # Class Carat_CLI


# Create and run the application
app = Carat_CLI.new(ARGV)
app.run
