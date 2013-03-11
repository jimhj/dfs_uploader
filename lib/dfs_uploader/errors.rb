# coding: utf-8
module DfsUploader
	class MaxSizeError < StandardError
		def message
			"图片超出了最大限制"
		end
	end

	class ImageTypeError < StandardError
		def message
			"不支持的图片格式"
		end		
	end

	class UploadError < StandardError
		def message
			"不支持的格式或上传中出错"
		end		
	end	

end