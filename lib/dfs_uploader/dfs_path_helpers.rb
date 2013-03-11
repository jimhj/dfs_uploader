 # coding: utf-8
module DfsUploader
	module DfsPathHelpers
		
		def dfs_to_url(dfs, size)
			arr = (dfs_path || '').split('|')
	    return '' if arr.length <= 1
	    file_name = "#{size.to_s}_#{arr[0]}.#{arr[1]}"
	    file_path = '/' + File.join(arr[4], arr[-2], arr[-1], file_name)

	    dfs_assets_host = DfsUploader.configuration.assets_host

	    if dfs_assets_host.present?
	    	file_path = (dfs_assets_host % arr[2]) << file_path
	    end
	    file_path
	  end

		def url_to_dfs(asstes_url)
	    # arr = asstes_url.split(/\//)
	    # if asstes_url.start_with?('http://')
	    # 	img_name_arr = arr[4].split(/\./)
	    # 	img_name = img_name_arr.first.split(/_/).last
	    # 	dfs_path = [img_name, img_name_arr.last, 0, 0, arr[1], 0, 0, arr[2], arr[3]].join("|")
    	# else
	    # 	img_name_arr = arr.last.split(/\./)
	    # 	img_name = img_name_arr.first.split(/_/).last
	    # 	dfs_path = [img_name, img_name_arr.last, 0, 0, arr[1], 0, 0, arr[2], arr[3]].join("|")    		
    	# end		
		end


	end

  class Railtie < Rails::Railtie
    initializer "dfs_uploaders.dfs_path_helpers" do
      ActionController::Base.send :include, DfsPathHelpers
      ActionView::Base.send :include, DfsPathHelpers
    end
  end

end