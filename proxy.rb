#!/usr/local/bin/ruby

require 'webrick/httpproxy'

class TaintProxy

	def initialize(port)
		@s = WEBrick::HTTPProxyServer.new(
			:Port => port,
			:RequestCallback => Proc.new{|req,res|
			puts "-"*70
			puts req.request_line, req.raw_header
			res.each do |x|
				puts "Stuff: #{x}"
			end
			puts "-"*70
		}
		)
		trap("INT"){ @s.shutdown }
	end

	def start
		@s.start
	end
end

def run(port)
	tp = TaintProxy.new(port)
	tp.start
end
