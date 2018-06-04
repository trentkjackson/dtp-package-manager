# Web scraper for collecting HTML elements from websites.
# This is a helpful tool to use to collect software from
# places like wikipedia and sourceforge.  

require 'net/http'
require 'uri'
require 'nokogiri'
require_relative '../util/network'
require_relative '../util/file'
require_relative '../util/array/sort.rb'


sourceforge_global_paginator = 'os%3Awindows/?page='
sourceforge_global_paginator_slice_point = 'os:windows'

# List of websites the tool should scrape.
# Don't include http/https as the 'net/http' module
# will not know how to make a connection and will fail.
$urls = {
	# Here we specific the key and some values for the webscraper in the form of
	# an array.
	#
	# &:[:key][0] - this is the url we want to extract information from. 
	#
	# &:[:key][1] - (obsolete) this should be removed soon but it is basically 
	# 					 	  the point in the url where the paginator should be attached
	# 						  to, at the moment is is completley removing it and replacing
	#              	it with &:[:key][2].
	#
	# &:[:key][2] - this is the paginator path that will be appended (or replaced
	#  					    until &:[:key][1] is deprecated).
	#
	# &:[:key][3] - this is the number of pages the tool should scrape through. If
	# 					 		you would only like to scrape the given url in &:[:key][0], set
	# 							this element to a zero.
	:wikipedia => [
		"en.wikipedia.org/wiki/List_of_free_and_open-source_software_packages",
		"",
		"",
		0
	],
	:sourceforge_development => [
		"www.sourceforge.net/directory/development/os:windows/",
		sourceforge_global_paginator_slice_point,
		sourceforge_global_paginator,
		5
	],
	:sourceforge_buisness => [
		"www.sourceforge.net/directory/business-enterprise/financial/accounting/os:windows/",
		sourceforge_global_paginator_slice_point,
		sourceforge_global_paginator,
		5
	],
	:sourceforge_crm => [
		"www.sourceforge.net/directory/business-enterprise/enterprise/crm/os:windows/",
		sourceforge_global_paginator_slice_point,
		sourceforge_global_paginator,
		5
	],
	:sourceforge_buisness_intel => [
		"www.sourceforge.net/directory/business-enterprise/enterprise/enterprisebi/os:windows/",
		sourceforge_global_paginator_slice_point,
		sourceforge_global_paginator,
		5
	],
}

# Links NOT containing these words should be excluded.
sourceforge_global_filters = ["projects", "?source=directory"]
$filter_words = {
	:wikipedia => ["wiki"],
	:sourceforge_development => sourceforge_global_filters,
	:sourceforge_buisness => sourceforge_global_filters,
	:sourceforge_crm => sourceforge_global_filters,
	:sourceforge_buisness_intel => sourceforge_global_filters
}

# Links containing these words should be excluded.
sourceforge_global_exclusion_filters = []
$must_exlude_words = {
	:wikipedia => ["wikipedia", "mediawiki", ":", "wikimediafoundation", "shop"],
	:sourceforge_development => sourceforge_global_exclusion_filters,
	:sourceforge_buisness => sourceforge_global_exclusion_filters,
	:sourceforge_crm => sourceforge_global_exclusion_filters,
	:sourceforge_buisness_intel => sourceforge_global_exclusion_filters
}


def get_element_array(content, el)
	return Nokogiri::HTML(content).css(el)
end

# Public: Parses and extracts HTML data from the given response.
#
# res 	  	 	  -  The HTML data from a 'http/net' socket response or HTML file.
# active_url    -  The url the HTML data derives from (for the sake of logging in the output file).
# current_page  -  The page the HTML data dervives from (for the sake of logging in the output file).
#
# Examples
#
#   parse_response(res, active_key, current_page)
#   # => ./output/out-sourceforge_crm-p5.txt
#
# Returns void and outputs parsed data to ./output folder.
def parse_response(res, active_url, current_page) 

	# Pushes all the Nokogiri <a> elements' href attributes into an array as strings.
	links = []
	get_element_array(res, "a").each_with_index do |el_a, i|
		links[i] = el_a['href']
	end

	# Filter through the href attributes for all the <a> elements within the response.
	hrefs = ["\n  [#{get_host_from_url($urls[active_url][0]).upcase}/PAGE=#{current_page}] \n "]
	links.exclude_null.require_array_match($filter_words[active_url]).exclude_array($must_exlude_words[active_url]).uniq.each_with_index do |e, i| 
		Logger.log(e) 
		hrefs[i + 1] = "  " + e
	end

	# Write scraped data to a file in the output directory.
	create_output_file("out-#{active_url}-p#{current_page}", "txt", "./output", hrefs)
end


# Connects to current hash key's url and runs 'parse_response' with given arguments.
def tcp_connect(active_host, active_key, active_path, current_page)
	# URL shouldn't contain a protocol.
	if url_has_protocol(active_host)
		Logger.error("Using http/https in urls hash")
	end

	# Create socket.
	http = Net::HTTP.new(active_host)
	res = http.get(active_path)

	# If successful response status code...
	if $_2xx.include? res.code.to_i
		debug_header_status(res.code)
		parse_response(res, active_key, current_page)

		# If response status code refers to a redirection...
	elsif $_3xx.include? res.code.to_i
		debug_header_status(res.code)
		res = Net::HTTP.get(URI.parse(http.get(active_path).header['location'])).force_encoding("utf-8");
		parse_response(res, active_key, current_page)
	end
end



# For each url in $URLS...
$urls.keys.each do |active_key|
	if $urls[active_key][3] != 0
		# Iterates through the pages and stops at the active hash's specified page number.
		1.upto($urls[active_key][3]) do |current_page|
			if current_page == 1
				active_url = $urls[active_key][0]
			else
				active_url = slice_at_path($urls[active_key][0], $urls[active_key][1]) + $urls[active_key][2] + current_page.to_s
			end
			active_host = get_host_from_url(active_url)
			active_path = get_path_from_url(active_url)
			tcp_connect(active_host, active_key, active_path, current_page)
		end
	else
		active_url = $urls[active_key][0]
		active_host = get_host_from_url($urls[active_key][0])
		active_path = get_path_from_url($urls[active_key][0])
		tcp_connect(active_host, active_key, active_path, 1)
	end
end
