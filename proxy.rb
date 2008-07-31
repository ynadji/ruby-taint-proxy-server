#!/usr/local/bin/ruby

require 'webrick/httpproxy'

class TaintProxy

	def initialize(port)
		@proxy = WEBrick::HTTPProxyServer.new(
		     :Port => 8080,
		     :ProxyContentHandler => lambda { |request,response|
			response.body.gsub!(%r{<a href=".*?">(.*?)</a>},
							  '<a href="http://goatse">\1</a>')
		}
		)
	end

	def start
		@proxy.start
	end
end

def run(port)
	tp = TaintProxy.new(port)
	tp.start
end
