# Downloads the package provided in the console arguments from the FTP server.
# The "install" section of the package manager.
require 'net/ftp'
require_relative '../lib/util/logger'
require_relative '../lib/util/file'
require_relative '../lib/util/string/str_paint'

DEBUG = false
INSTALLATION_PATH = 'C:/Users/Trent/Desktop/dtp installations'
HOST = "122.151.247.42"
USERNAME = "user"
PASSWORD = ""
DIRECTORY = '/'

if ARGV[0] == "install" || ARGV[0] == "i" && !ARGV[0].nil? && !ARGV[1].nil?
	Logger.log("Connecting to '#{HOST}' as '#{USERNAME}'.") if DEBUG

	Net::FTP.open(HOST, USERNAME, PASSWORD) do |ftp|
		ftp.chdir(DIRECTORY)

		matches = ftp.nlst.map do |file| 
			if file.downcase.include?(".")
				get_file_name(file.downcase) 
			else
				file.downcase
			end
		end

		match_with_extension = ftp.nlst.reject { |file| !file.downcase.include?(ARGV[1].downcase) }
		match_without_extension = matches.reject { |file| file.downcase != ARGV[1].downcase }

		if DEBUG
			Logger.log(
				"ftp.nlst >> #{ftp.nlst}\n_match_without_extension >> #{match_without_extension}\nmatch_with_extension >> #{match_with_extension[0]}")
			Logger.log("match_without_extension >> #{match_without_extension}") 
			Logger.log("match_with_extension >> #{match_with_extension[0]}") 
		end

		if match_without_extension.size > 1
			Logger.warning("FTP server contains files with the same name."\
				"You should submit this and the following log to an issue thread on the GitHub page.")
			Logger.log_data(match_without_extension, 5)
		end

		if !match_without_extension.empty?
			puts "Package '#{match_without_extension[0]}' found, download will start shortly.".str_paint(Color.get_t("fg")["cyan"])

			match_file_name = match_without_extension[0].to_s
			match_file_size = ftp.size(match_with_extension[0])
			match_file_size_type = {
				:kB => (match_file_size.to_f * (10 ** -3).to_f).round(2),
				:mB => (match_file_size.to_f * (10 ** -6).to_f).round(2),
				:gB => (match_file_size.to_f * (10 ** -9).to_f).round(2),
			}

			case
			when match_file_size <= 1000 
			    match_file_size_final = [match_file_size_type["kB"], "kB"]
			when match_file_size > 1000 && match_file_size <= (10 ** 9)
			    match_file_size_final = [match_file_size_type["mB"], "mB"]
			when match_file_size > (10 ** 9)
			    match_file_size_final = [match_file_size_type["gB"], "gB"]
			else
			    match_file_size_final = [match_file_size_type["kB"], "kB"]
			end

			puts "Download started for package #{match_file_name.str_paint(Color.get_t('fg')['red'])} "\
				"(#{match_file_size_final[0].to_s.str_paint(Color.get_t('fg')['cyan'])} #{match_file_size_final[1].str_paint(Color.get_t('fg')['cyan'])})."
			
			# Progress is the amount of bytes we have recieved, we then
			# do the following with that information:
			#
			# 1) We add any bytes of data we may have recieved from the current chunk.
			# 2) We print the percentage of progress / file_size in the form of a loading bar.
			progress = 0
			ftp.getbinaryfile(match_with_extension[0], INSTALLATION_PATH + "/#{match_with_extension[0]}") do |data|
			  progress += data.size
			  file_completion_point = ((progress).to_f / match_file_size.to_f) * 100

			  # TODO: Fix the repeating square bracket that appears when downloading large amounts of data.
			  printf("\rDownload progress: ["+ "%-40s" + "]\r", "=".str_paint(Color.get_t("fg")["cyan"]) * (file_completion_point/2.5))
			end

			puts "\nSuccessfully installed package to '#{INSTALLATION_PATH.str_paint(Color.get_t('fg')['cyan'])}'."
		else
			puts "Sorry, couldn't find a package titled '#{ARGV[1]}'".str_paint(Color.get_t('fg')["red"])
			Logger.log(get_file_name(ARGV[1].downcase))
		end
	end
else
	if ARGV[0] != "install" || ARGV[0] == "i"
		puts "Unknown command, sorry I don't know what to do with the command '#{ARGV[0]}'".str_paint(Color.get_t('fg')["red"])
	elsif (ARGV[0] != "install" || ARGV[0] == "i") && ARGV[1].nil? || ARGV[1].nil?
		puts "Please provide a package name, otherwise I don't know what to download for you!".str_paint(Color.get_t('fg')["red"])
	end
end
