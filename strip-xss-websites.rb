#!/usr/bin/env ruby -w
# 
# Grabbing list of XSS vulnerabilities
# from www.xssed.com for research stuff.

require 'rubygems'
require 'open-uri'
require 'trollop'

opts = Trollop::options do
	opt :csv, "Generate CSV a la Excel"
	opt :all, "Get from ALL websites or not (otherwise limited to (com|org|net|gov))"
end

MAX_PAGE = 1
URL = "http://www.xssed.com/archive/special=1/page="
sleep_time = 10

$all_rows = []
$urls = []
outname = opts[:csv] ? "xss-attacks.csv" : "xss-attacks.txt"
$outfile = File.new(outname, 'w')
$outfile.puts("Date,Hackername,Website,Pagerank,Attack Type,Mirror Link,\"Type\",Status,DSI?,CSTT?,Notes") if opts[:csv]

1.upto(MAX_PAGE) do |page_num|
	begin
		puts "Page ##{page_num}"
		page = open(URL + page_num.to_s)
		html = page.read
	rescue Exception => e
		$stderr.puts("Overloading the server: #{e}")
		$stderr.puts("Sleeping for: #{sleep_time} seconds")
		sleep sleep_time
		sleep_time += 1
		redo
	end

	rows = html.scan(/<tr><th class="row\d+" scope="col">.*?<\/tr>/)

	rows.each do |row|
		# only print still not fixed bugs
		if row =~ /unfixed\.gif/
			arr = row.split(/<.*?>/)
			arr.delete("")
			arr.delete("R")
			arr.delete("mirror")
			arr[3] = arr[3].to_i

			# get mirror link
			# http://www.xssed.com/mirror/45126/
			if row =~ /\/mirror\/\d+/
				arr << "http://www.xssed.com#{$~}"
			end

			if opts[:all]
				$all_rows << arr
				$urls << arr[2]
			elsif $urls.index(arr[2]) == nil && arr[2] =~ /\.(com|org|net|gov)$/
				$all_rows << arr
				$urls << arr[2]
			end
		end
	end
	# don't hammer the server
	sleep 1
end

$all_rows.sort! {|x,y| x[3] <=> y[3] }

if opts[:csv]
	$all_rows.each {|x| $outfile.puts(x.join(','))}
else
	$all_rows.each do |row|
		page = open(row[5])
		html = page.read

		# we have an attack url, woo!
		if html =~ /<th class="row3" scope="col" colspan="4">URL: (.*?)<\/th>/
			attack_str = $1.gsub("<br>","").gsub("&lt;","<").gsub("&gt;",">").gsub("&quot;",'"').gsub("&apos;","'").gsub("&amp;","&")
			$outfile.puts(row[5])
			$outfile.puts(attack_str)
		end
	end
end

$outfile.close
