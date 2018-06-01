require 'time'
require_relative './string/str_paint.rb'

# Returns foreground id for color given.
def get_fg(str)
	return Color.get_t("fg")[str]
end

class Logger
	@software_version = "v1.0"
	@_24HourTime = Time.new.strftime("%H:%M")

	def self.get_head()
		return "[Logger #{@_24HourTime.to_s}]"
	end

	#TODO: Metaprogramming, get line and file from caller.
	def self.error(info)
		puts "#{self.get_head()} " + "ERROR".str_paint(get_fg("red")) + ": Line '#{__LINE__}' in #{__FILE__} (#{info})." 
	end

	def self.warning(info)
		puts "#{self.get_head()} " + " WARNING".str_paint(get_fg("brown")) + ": #{info}."
	end

	def self.log(message)
		puts "#{self.get_head()}: " + "#{message}".str_paint(get_fg("blue"))
	end

	def self.success(message)
		puts "#{self.get_head()} " + "Success: ".str_paint(get_fg("green")) + message.str_paint(get_fg("green"))
	end

	def self.plog(message)
		print "#{self.get_head()}: " + "#{message}".str_paint(get_fg("blue"))
	end

	def self.log_data(data, length)
		loop do 
			if data.length > length
				self.plog("Data about to me printed is over #{length} chararacters, continue? (Y/N): ")
				case gets.chomp.downcase
				when "y"
					self.log(data)
					break
				when "n"
					break
				else
					next
				end
			else
				self.log(data)
				break
			end
		end
	end

end
