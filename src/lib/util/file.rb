require_relative "logger"
# File
def create_output_file(name, extention, relative_path, content)
	file = File.new("#{relative_path}/#{name}.#{extention}", "w")
	file.puts(content)
	file.close
end

def get_file_name(file)
	if !file.include? "."
		Logger.warning("Using get_file_name on a file path that doesn't include an extention of any sort.")
		return file
	end
	return file[0...file.index(".")]
end