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

def file_has_extension(file)
	return file.include? "."
end

def construct_directory(path, new_dir_name)
	Dir.mkdir("#{path}/#{new_dir_name}")
end

def construct_directories(path, dir_list)
	Logger.error("Function 'construct_directories' does not take argument #{tree.class}") if dir_list.class != Array
	tree.each do |new_dir|
		Logger.error("Function 'construct_directories'('s) argument of type Array does not take #{tree[0].class}") if new_dir.class != String
		construct_directory(path, new_dir)
	end
end