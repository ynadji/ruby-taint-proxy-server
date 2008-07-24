#!/usr/bin/env ruby -w
#
# This does all the magic, woo!

require 'rubygems'
require 'proxy'
require 'trollop'
require 'FileUtils'
require 'open-uri'
require 'cgi'

sleep_time = 10

cli_options = Trollop::options do
	opt :proxy, "Run as a proxy server"
	opt :port,	"Proxy port", :default => 8080
	opt :url_file, "File of URLs/attack strings", :default => "xss-attacks.txt"
	opt :html_dir, "Output directory for delimited HTML files", :default => "html"
	opt :logfile, "File to log what happened", :default => "delim.log"
end

def add_delims(html, attack, log)
	nullified = false

	# fuck you newlines
	attack.strip!

	# first we want to generate the different
	# ways it could be rendered, i.e: %3C <=> <, etc.
	# apparently, things can be escaped multiple times
	# and still render correctly. so escape it one extra time
	# and unescape until it's "normal"
	attacks = []
	attacks << attack
	attacks << CGI::escape(attack).chomp
	while attacks.last != CGI::unescape(attack).chomp
		attacks << CGI::unescape(attack).chomp
	end

	# should be the most "readable"
	unescaped_attack = attacks.last

	# guess server-side escaping or JS-escaping
	if unescaped_attack =~ /"/
		attacks << unescaped_attack.gsub('"','\"')
	end
	if unescaped_attack =~ /'/
		attacks << unescaped_attack.gsub("'","\\'")
	end
	if unescaped_attack =~ /"/ and unescaped_attack =~ /'/
		attacks << unescaped_attack.gsub('"','\"').gsub("'","\\'")
	end

	attacks.uniq!

	attacks.each do |att|
		# we sucessfully delimited an attack
		# for now, just use **randnum**
		if html.include?(att)
			key = rand(999).to_s
			key = "0#{key}" if key.length == 2
			key = "00#{key}" if key.length == 1
			html.gsub!("#{att}","**#{key}**#{att}**#{key}**")

			nullified = true

			log.puts("#{att} nullified!")
		end
	end

	# if it didn't work, try
	# last ditch effort, only attack the specific script tag
	if not nullified
		unescaped_attack.scan(/<script>.*?<\/script>/i).each do |att|
			# we sucessfully delimited an attack
			# for now, just use **randnum**
			if html.include?(att)
				key = rand(999).to_s
				key = "0#{key}" if key.length == 2
				key = "00#{key}" if key.length == 1
				html.gsub!("#{att}","**#{key}**#{att}**#{key}**")

				nullified = true

				log.puts("#{att} nullified!")
			end
		end
	end

	return [html, nullified, attacks]
end

def delimit_html(url_file, html_dir, logfile)
	# code to delimit html
	FileUtils.remove_dir(html_dir, true) if File.exist?(html_dir)
	FileUtils.mkdir(html_dir)

	infile = File.open(url_file)

	url = nil
	attack = nil
	file_no = "000"

	log = File.open(logfile, 'w')
	log.puts("=====#{Time.now}=====")

	infile.each_line do |line|
		if url.nil? and attack.nil?
			url = line
		elsif attack.nil?
			attack = line
		else
			puts file_no
			log.puts("\nFile: #{file_no}.html")
			log.puts("URL:  #{url}")
			log.puts("ATT:  #{attack}\n")
			# do stuff
			begin
				page = open(url)
				html = page.read
			rescue Exception => e
				$stderr.puts("Overloading the server: #{e}")
				$stderr.puts("Sleeping for: #{sleep_time} seconds")
				sleep sleep_time
				sleep_time += 1
				redo
			end

			new_html, nullified, attacks = add_delims(html, attack, log)

			if not nullified
				log.puts("Nothing found :(")
				log.puts("Attacks Tried: #{attacks.inspect}\n\n")
			end

			outfile = File.new("#{html_dir}/#{file_no}.html", 'w')
			outfile.puts(new_html)
			outfile.close

			file_no.succ!
			url = line
			attack = nil
		end
	end

	log.close
end

def start_proxy(port)
	# code to start proxy
end

if cli_options[:proxy]
	start_proxy(cli_options[:port])
else
	delimit_html(cli_options[:url_file], 
					 cli_options[:html_dir],
					 cli_options[:logfile])
end
