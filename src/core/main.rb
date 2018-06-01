# Temporary variables
require 'net/ftp'
require_relative '../lib/util/logger'
require_relative '../lib/util/file'
require_relative '../lib/util/string/str_paint'
DEBUG = true

# ~ TODO ~
# Make folders work, make it so if the given 'package' 
# ARGV match doesn't include an extention it will traverse
# through the folder downloading and organizing everything in it's new destination

installation_path = 'C:/Users/Trent/Desktop/dtp installations'
if (ARGV[0] == "install" || ARGV[0] == "i") && !ARGV[0].nil? && !ARGV[1].nil?
	HOST = '127.0.0.1'
	USERNAME = 'user'
	PASSWORD = 'password'
	DIRECTORY = './'

	# Logger.log("Connecting to '#{HOST}' as '#{USERNAME}'.")
	Net::FTP.open('127.0.0.1', "user", "") do |ftp|
		files = ftp.chdir('/')
		matches = ftp.nlst.map do |x| 
			if x.downcase.include? "."
				get_file_name(x.downcase) 
			else
				x.downcase
			end
		end
		originalMatch = ftp.nlst.reject { |x| !x.downcase.include? ARGV[1].downcase }
		match_ = matches.reject { |x| x.downcase != ARGV[1].downcase }
		Logger.log("ftp.nlst >> #{ftp.nlst}") if DEBUG
		Logger.log("_match >> #{match_}") if DEBUG
		Logger.log("originalMatch >> #{originalMatch[0]}") if DEBUG
		if match_.length > 1
			Logger.warning("FTP server ceontains files with the same name. You should submit this and the following log to an issue thread on the GitHub page.")
			Logger.log_data(match_, 5)
		end
		if !match_.empty?
			puts "Package '#{match_[0]}' found, download will start shortly.".str_paint(Color.get_t("fg")["cyan"])
			sleep(0.1)
			match_file_name = match_[0].to_s
			match_file_size = ftp.size(originalMatch[0])
			progress = 0
			puts "Download started for package" + " #{match_file_name}".str_paint(Color.get_t("fg")["red"]) + " (" + "#{(match_file_size.to_f * (10 ** -3).to_f)} kB".str_paint(Color.get_t("fg")["cyan"]) +")."
			sleep(0.1)
			ftp.getbinaryfile(originalMatch[0], installation_path + "/#{originalMatch[0]}", 1024) do |data|
			  progress += data.size
			  file_completion_point = ((progress).to_f / match_file_size.to_f) * 100
			  printf("\rDownload progress: "+ "[" + "%-40s" + "]", "=".str_paint(Color.get_t("fg")["cyan"]) * (file_completion_point/2.5))
			  sleep(0.025)
			end
			sleep(0.1)
			puts "\nSuccessfully installed package to '" + installation_path.str_paint(Color.get_t("fg")["cyan"]) + "'."
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
