require 'net/http'
require 'uri'
require 'nokogiri'
require_relative '../util/network'
require_relative '../util/file'
require_relative '../util/array/sort.rb'

# List of websites the tool should scrape.
# Don't include http/https
$urls = {
	:wikipedia => "en.wikipedia.org/wiki/List_of_free_and_open-source_software_packages", 
	:sourceforge => "www.sourceforge.net/directory/development/os:windows/",
}

# Links NOT containing these words should be excluded.
$filter_words = {
	:wikipedia => ["wiki"],
	:sourceforge => ["projects", "?source=directory"]
}

# Links containing these words should be excluded.
$must_exlude_words = {
	:wikipedia => ["wikipedia", "mediawiki", ":", "wikimediafoundation", "shop"],
	:sourceforge => []
}

# Just for simplicity.
def get_element_array(content, el)
	return Nokogiri::HTML(content).css(el)
end

# -------------------------------------------------------------------------------------
# Parses the response, logs it in console and writes it to a .txt file within the     |
# ./output directory.																  |
# -------------------------------------------------------------------------------------
# [a_url]  being the currently active url within the each loop this function should be|
#          called in.																  |
# [res]    being the response from the net/http socket.								  |
# -------------------------------------------------------------------------------------
def parse_response(res, a_url) 
	# Log res
	Logger.log_data(res, 50)

	# Pushes all the Nokogiri <a> elements' href attributes into an array as strings.
	links = []
	get_element_array(res, "a").each_with_index do |el_a, i|
		links[i] = el_a['href']
	end

	# Filter through the href attributes for all the <a> elements within the response.
	hrefs = ["\n  [#{get_host_from_url($urls[a_url]).upcase}] \n "]
	links.exclude_null.require_array_match($filter_words[a_url]).exclude_array($must_exlude_words[a_url]).uniq.each_with_index do |e, i| 
		Logger.log(e) 
		hrefs[i + 1] = "  " + e
	end

	# Write scraped data to a file in the output directory.
	create_output_file("out-#{a_url}", "txt", "./output", hrefs)
end


# For each url in $URLS...
$urls.keys.each do |active_url|
	active_host = get_host_from_url($urls[active_url])

	# URL shouldn't contain a protocol.
	if url_has_protocol(active_host)
		Logger.error("Using http/https in urls hash")
	end

	# Create socket.
	http = Net::HTTP.new(get_host_from_url($urls[active_url]))
	res = http.get(get_path_from_url($urls[active_url]))

	# If successful response status code...
	if $_2xx.include? res.code.to_i
		parse_response(res, active_url)

	# If response status code refers to a redirection...
	elsif $_3xx.include? res.code.to_i
		res = Net::HTTP.get(URI.parse(http.get(get_path_from_url($urls[active_url])).header['location'])).force_encoding("utf-8");
		parse_response(res, active_url)
	end

	# Prints information about the type of status code given by the header. 
	debug_header_status(res.code)
end
