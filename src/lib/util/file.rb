require_relative "logger"
require 'zip'

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

def get_file_fullname_from_path(path)
	return path[path.rindex("/") + 1...path.size()]
end

def get_file_name_from_path(path)
	if !path.include?(".")
		Logger.error("The function 'get_file_name_from_path' only accepts paths that lead to a file and an extension.")
	end
	return path[path.rindex("/") + 1...path.index(".")]
end

def get_file_parent_from_path(path)
	return path[0...path.rindex("/")]
end

def unzip_and_extract_locally(path, remove_zip_after) 
	destination = "#{get_file_parent_from_path(path)}/#{get_file_name(get_file_fullname_from_path(path))}"
	Zip::ZipFile.open(path) do |zipped_file|
		zipped_file.each do |file|
			end_path = File.join(destination + "/", file.name)
			FileUtils.mkdir_p(File.dirname(end_path))
			zipped_file.extract(file, end_path) if !File.exist?(end_path)
		end
	end
	if(remove_zip_after && File.exist?(path))
		File.delete(path)
	end
end