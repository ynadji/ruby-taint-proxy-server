require 'rubygems'
require 'trollop'

cli_options = Trollop::options do
	opt :input, "HTML File to Delimit", :default => "file.html"
	opt :output, "HTML File to Output To", :default => "file-att.html"
	opt :attack, "Attack String", :default => ""
end

require 'delimiter-add'

input = File.open(cli_options[:input])
html = input.read

output = File.open(cli_options[:output], 'w')

output.puts(add_delims(html, cli_options[:attack], $stdout)[0])
output.close
input.close
