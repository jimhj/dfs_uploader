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
			# @opts[:create_thumbs] ||= true

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
      FileUtils.chmod(0660, full_path) #!!!!!!
			create_thumbs unless @opts[:create_thumbs] === false
			@dfs_path = [@filename, @ext, 0, 0, @store_as, 0, 0, @rand_dir.split('/')].join('|')
			self
		end


		def create_thumbs
      full_path = File.join(@target_dir, "o_#{@filename}.#{@ext}")
      img = MiniMagick::Image.open full_path
      DfsUploader.configuration.thumbs.each_pair do |prefix, size|
        x, y = size.split('x').map{ |length| length.to_i }
        if x == y
          w, h = img[:dimensions]
          shave = ((w - h).abs / 2).round
          shave = w > h ? "#{shave}x0" : "0x#{shave}"
          img.shave shave

          # img.shave("#{((w - x) / 2).round}x#{((h - y).to_f / 2).round}")
        end
        img.resize size 
        img.write File.join(@target_dir, "#{prefix}_#{@filename}.#{@ext}")
      end
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
				process = self.new(file, store_as, opts)
				process.upload
			end

			def crop(opts = {}, coordinate)
				# opts[:img], opts[:preview_img] can be an url(http://www.xxx.com/x.jpg) or a file path(/var/xxx.jpg).
				raise ArgumentError, "wrong crop coordinates." unless coordinate.length === 4

				# coord = OpenStruct.new
				# %w(x y w h).each_with_index { |c, i| coord.send(c, coordinate[i]).to_f }

				img = MiniMagick::Image.open(opts.delete(:img)).clone
        if opts[:preview_img]
				  preview_img = MiniMagick::Image.open(opts.delete(:preview_img)).clone
        else
          preview_img = img
        end
        
				roundx = img[:width].to_f / preview_img[:width]
				roundy = img[:height].to_f / preview_img[:height]

        x = (coordinate[0] * roundx).round
        y = (coordinate[1] * roundy).round
        w = (coordinate[2]* roundx).round
        h = (coordinate[3] * roundy).round

        img.crop("#{w}x#{h}+#{x}+#{y}!")
        img.coalesce(img.path, img.path)

        self.upload(img.path, opts.delete(:store_as), opts)        
			end

		end



	end

end