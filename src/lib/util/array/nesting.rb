def depth(array)
	return 0 unless array.is_a?(Array)
	return 1 + depth[array[0]]
end
