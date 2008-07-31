#!/usr/local/bin/ruby

require 'webrick/httpproxy'
require 'delimiter-add'

class TaintProxy

	def initialize(port)
		@proxy = WEBrick::HTTPProxyServer.new(
		     :Port => port,
		     :ProxyContentHandler => lambda { |request,response|
			# get longest attack string
			attack = request.query.values.sort {|x,y| y.length <=> x.length}[0]
			if not attack.nil? and attack != ""
				result = add_delims(response.body, attack, $stdout)
				if result[1]
					response.body = result[0]
				end
			end
		}
		)
		trap('INT') { @proxy.shutdown }
	end

	def start
		@proxy.start
	end
end

def run(port)
	tp = TaintProxy.new(port)
	tp.start
end

run 2020
