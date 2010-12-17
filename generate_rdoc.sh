#!/bin/sh
rm -rf doc
rm -rf carat_cli_doc
rdoc --all --diagram --output=doc --exclude plugins/carat/var --exclude msf_modules --exclude carat_cli.rb
rdoc --all --diagram --main=carat_cli.rb --output=carat_cli_doc carat_cli.rb

