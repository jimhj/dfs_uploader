# coding: utf-8
module DfsUploader
	require 'mini_magick'
	require 'open-uri'

	class Process 

		attr_accessor :orig_file, :image, :ext, :size, :store_as, :opts, :dfs_path

		def initialize(file, store_as, opts = {})
			@orig_file = file
			@store_as = store_as
			@opts = opts
			@errors = []
			@filename = filename
			@file_path = file_path
			@rand_dir = mk_rand_dir_name
			@target_dir = mk_target_dir_name
			@opts[:create_thumbs] ||= true

			@image = MiniMagick::Image.open(@file_path)
			@ext = @image[:format].downcase
			@size = @image[:size].to_i

			if !DfsUploader.configuration.extension_white_list.include?(@ext)
				raise DfsUploader::ImageTypeError 
			end

			if @image[:size].to_i > DfsUploader.configuration.max_size	
				raise DfsUploader::MaxSizeError
			end
					
		end

		def upload
			FileUtils.mkdir_p(@target_dir)
			full_path = File.join(@target_dir, "o_#{@filename}.#{@ext}")
			self.image.write(full_path)
			create_thumbs if @opts[:create_thumbs]
			@dfs_path = [@filename, @ext, 0, 0, @store_as, 0, 0, @rand_dir.split('/')].join('|')
			self
		end

		def crop
		end


		def create_thumbs
		end

		private

		def file_path
			case @orig_file.class.to_s
			when "ActionDispatch::Http::UploadedFile"
				@orig_file.tempfile.path
			when "Tempfile"
				@orig_file.path
			when "String"
				if File.exist?(@orig_file) || @orig_file.match(/http:\/\//)
					@orig_file
				end
			end
		end

    def mk_target_dir_name
      target = DfsUploader.configuration.assets_path
      File.join(target, @store_as, @rand_dir)
    end

    def mk_rand_dir_name
      File.join('%02d' % rand(99), '%02d' % rand(99))
    end

    def filename
      Digest::MD5.hexdigest([Time.now.to_i.to_s, rand.to_s].join('-'))
    end				


		class << self

			def upload(file, store_as, opts = {})
				process = self.new(file, store_as, opts = {})
				process.upload
				process
			end

			def crop(opts = {}, coordinate)
				# opts[:img], opts[:preview_img] can be an url(http://www.xxx.com/x.jpg) or a file path(/var/xxx.jpg).

				raise ArgumentError, "wrong crop coordinates." unless coordinate.length === 4

				coord = OpenStruct.new
				%w(x y w h).each_with_index { |c, i| coord.send(c, coordinate[i]).to_f }

				img = MiniMagick::Image.open(opts[:img]).clone
				preview_img = MiniMagick::Image.open(opts[:preview_img]).clone
				roundx = img[:width].to_f / preview_img[:width]
				roundy = img[:height].to_f / preview_img[:height]

        x = (coord.x * roundx).round
        y = (coord.y * roundy).round
        w = (coord.w * roundx).round
        h = (coord.h * roundy).round

        img.crop("#{w}x#{h}+#{x}+#{y}!")
        img.coalesce(img.path, img.path)
        crop = self.process(img.path, opts[:store_as])
        crop
        
			end

		end



	end

end