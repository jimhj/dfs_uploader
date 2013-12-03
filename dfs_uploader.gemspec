$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dfs_uploader/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dfs_uploader"
  s.version     = DfsUploader::VERSION
  s.authors     = ["Jimmy Huang"]
  s.email       = ["jimmy.huangjin@gmail.com"]
  s.homepage    = "http://jimhj.github.com"
  s.summary     = "An DFS path rule uploader."
  s.description = "Upload images and storing in dfs path rule."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  # s.add_dependency "rails", "~> 3.2.12"

  # s.add_development_dependency "mysql2"
end
