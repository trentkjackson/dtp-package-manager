# Colors
class Color 
	@k = ["black", "red", "green", "brown", "blue", "magenta", "cyan", "gray"]
	@fg_v = [*30..37]
	@bg_v = [*40..47]
	@@fg_colors = Hash[@k.zip(@fg_v)]
	@@bg_colors = Hash[@k.zip(@bg_v)]

	# Returns the appropriate hash in relation to the type of
	# color that is wanted (foreground / background)
	def self.get_t(type)
		begin
			case type.downcase
			when "fg"
				return @@fg_colors
			when "bg"
				return @@bg_colors
			else
				throw ArgumentError
			end
		rescue ArgumentError
			Logger.error("Type '#{type}' does not exist in class 'Color'.")
			return nil
		end
	end
end	

# String prototyping
class String 
	def str_paint(color)
		return "\033[#{color}m#{self}\033[0m"
	end
end

