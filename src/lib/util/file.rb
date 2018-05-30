# File
def create_output_file(name, extention, relative_path, content)
	file = File.new("#{relative_path}/#{name}.#{extention}", "w")
	file.puts(content)
	file.close
end