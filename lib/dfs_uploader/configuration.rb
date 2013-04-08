# coding: utf-8
module DfsUploader
	class Configuration
    attr_accessor :extension_white_list, :max_size, :thumbs, :assets_path, :assets_host

    def initialize
      self.extension_white_list = %w(jpg jpeg png gif)
      self.max_size = 10485760 #B
      self.assets_path = File.join(Rails.root, "public")
      self.assets_host = "http://localhost:3000"
      self.thumbs = {
        :l => '600x900>',      
        :m => '200x300>',
        :c => '80x80',
        :s => '50x50'        
      }
    end
	end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end	

end