#!/usr/bin/env ruby -w
#
# This does all the magic, woo!

require 'rubygems'
require 'trollop'

cli_options = Trollop::options do
	opt :proxy, "Run as a proxy server"
	opt :port,	"Proxy port", :default => 8080
	opt :url_file, "File of URLs/attack strings", :default => ""
end
