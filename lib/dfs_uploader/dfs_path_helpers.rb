 # coding: utf-8
module DfsUploader
	module DfsPathHelpers
		
		def dfs_to_url(dfs, size = nil)
      arr = (dfs || '').split('|')
      return '' if arr.length <= 1

      file_name = "#{arr[0]}.#{arr[1]}"
      file_name = "#{size.to_s}_#{file_name}" if size

      file_path = '/' + File.join(arr[4], arr[-2], arr[-1], file_name)

	    dfs_assets_host = DfsUploader.configuration.assets_host

	    if dfs_assets_host.present?
	    	file_path = (dfs_assets_host % arr[2]) << file_path
	    end

	    file_path
	  end

    def dfs_to_path(dfs, size)
      file_path = get_file_path(dfs, size)
      File.join(DfsUploader.configuration.assets_path, file_path)
    end

    def get_file_path(dfs, size)
      arr = (dfs || '').split('|')
      return '' if arr.length <= 1
      file_name = "#{size.to_s}_#{arr[0]}.#{arr[1]}"
      file_path = '/' + File.join(arr[4], arr[-2], arr[-1], file_name)
      file_path           
    end

	end

  class Railtie < Rails::Railtie
    initializer "dfs_uploaders.dfs_path_helpers" do
      ActionController::Base.send :include, DfsPathHelpers
      ActionView::Base.send :include, DfsPathHelpers
    end
  end

end