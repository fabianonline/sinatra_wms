module Sinatra
	module WMS
		def wms(url)
			get url do
				#blubb
				yield
			end
		end
	end
	
	register WMS
end