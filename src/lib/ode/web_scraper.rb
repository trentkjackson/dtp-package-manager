require 'net/http'
require 'uri'
require 'nokogiri'
require_relative '../util/network'
require_relative '../util/file'
require_relative '../util/array/sort.rb'

# TODO: Make web scraper iterate through the website paginator

# List of websites the tool should scrape.
# Don't include http/https

sourceforge_global_paginator = 'os%3Awindows/?page='
sourceforge_global_paginator_slice_point = 'os:windows'
$urls = {
	:wikipedia => [
		"en.wikipedia.org/wiki/List_of_free_and_open-source_software_packages",
		 "",
		 "",
		 0 # Entering a zero will make it so it doesn't iterate through pages for this key
	],
	:sourceforge_development => [
		"www.sourceforge.net/directory/development/os:windows/",
		 sourceforge_global_paginator_slice_point,
		 sourceforge_global_paginator,
		 2
	],
	:sourceforge_buisness => [
		"www.sourceforge.net/directory/business-enterprise/financial/accounting/os:windows/",
		 "",
		 "",
		 0  # Entering a zero will make it so it doesn't iterate through pages for this key
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
		 2
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

# Just for simplicity.
def get_element_array(content, el)
	return Nokogiri::HTML(content).css(el)
end

# Parses the response, logs it in console and writes it to a .txt file within the ./output directory.
# [a_url] being the active_url within the loop that this function should be called in.
def parse_response(res, a_url, current_page) 
	# DEBUG --------------------
	# Logger.log_data(res, 50) |
	# --------------------------

	# Pushes all the Nokogiri <a> elements' href attributes into an array as strings.
	links = []
	get_element_array(res, "a").each_with_index do |el_a, i|
		links[i] = el_a['href']
	end

	# Filter through the href attributes for all the <a> elements within the response.
	hrefs = ["\n  [#{get_host_from_url($urls[a_url][0]).upcase}/PAGE=#{current_page}] \n "]
	links.exclude_null.require_array_match($filter_words[a_url]).exclude_array($must_exlude_words[a_url]).uniq.each_with_index do |e, i| 
		Logger.log(e) 
		hrefs[i + 1] = "  " + e
	end

	# Write scraped data to a file in the output directory.
	create_output_file("out-#{a_url}-p#{current_page}", "txt", "./output", hrefs)
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
