def filter_two_arrays(this, arr, should_include)
	filterd = []
	i = 0
	this.each do |x|
		checkpoint_cleared = true
		# For each element in argument's array.
		arr.each do |m|
			# Checkpoint passed
			if should_include
				if x.include? m
					next
				else
					# Checkpoint failed
					checkpoint_cleared = false
				end
			else
				if !x.include? m
					next
				else
					# Checkpoint failed
					checkpoint_cleared = false
				end
			end
		end
		if checkpoint_cleared
			filterd[i] = x
			i += 1
		end
	end
	return filterd
end

class Array
	# Returns array without any empty elements.
	def exclude_null
		self.reject { |e| e.to_s.empty? }
	end

	# Filters out words from self that can be found in the argument's array.
	def exclude_array(arr)
		filter_two_arrays(self, arr, false)
	end

	# Rejects elements that aren't included within the given argument's array.
	def require_array_match(arr)
		filter_two_arrays(self, arr, true)
	end

end

