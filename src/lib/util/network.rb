require_relative "logger.rb"
# Networking

# Returns the host (www.*.com) from the url.
def get_host_from_url(url)
  return url[0...url.index("/")]
end

# Returns the /path/ from a url.
def get_path_from_url(url)
  return url[url.index("/")..url.length]
end

# Returns true if url has a protocol (e.g. https/http)
def url_has_protocol(url) 
	return (url.include? "http") || (url.include? "https")
end	

def slice_at_path(url, path)
	path_arr = url[0...url.index(path)]
end

# Returns true if the url has a valid ssl certificate (https).
def is_url_secured(url)
  url = url.downcase
  if !url.include?("https") && !url.include?("http")
    Logger.warning("Using 'is_url_secured' on a url that doesn't have a http(s):// attachment.")
  end
  return url.include? "https"
end

# Returns true if the urls contains 'www.'
def is_url_valid_www(url)
  return url.include? "www."
end

# List of status codes that could be sent from a HTTP header.
$_1xx = [*100..103]                     # Informational.
$_2xx = [*200..208, 226]                # Success.
$_3xx = [*300..308]                     # Redirection.
$_4xx = [*400..418, *421..431, 451]     # Client errors.

# Outputs information about the type of header given.
def debug_header_status(status)
  status = status.to_i
  # Make this actually useful by explaining why each header appears.
  if $_1xx.include? status
    Logger.log("Response code: #{status}. Response type: Informational.")
  elsif $_2xx.include? status
    Logger.log("Response code: #{status}. Response type: Success.")
  elsif $_3xx.include? status
    Logger.log("Response code: #{status}. Response type: Redirection.")
  elsif $_4xx.include? status
    Logger.log("Response code: #{status}. Response type: Client error.")
  else
    Logger.log("Response code: #{status} does not have a valid response type.")
  end
end

