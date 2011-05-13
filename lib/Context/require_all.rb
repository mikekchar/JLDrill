module Kernel

	# Requires all the files that match the glob in the
	# current load-path
	def require_all(glob)
		$:.each do |path|
			Dir.glob(path + "/" + glob) do |file|
				name = file.to_s.sub(path + "/", "")
				require name
			end
		end
	end
end
