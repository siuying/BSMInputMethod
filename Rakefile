require 'rubygems'
require 'bundler'
Bundler.require
require 'fileutils'

PROJECT_NAME = "BSMInputMethod"

task :build do
  puts `xcodebuild -project '#{PROJECT_NAME}.xcodeproj' -scheme '#{PROJECT_NAME}'`
end

task :install => ["build"] do
  output = `xcodebuild -showBuildSettings`
  config = output.split("\n")
    .collect{|cmd| cmd.strip.split("=") }
    .select {|cmd| cmd.size == 2 }
    .inject({}){|map, val| map[val[0].strip] = val[1].strip; map }
  build_root = config["BUILD_ROOT"]
  
  app     = Dir["#{build_root}/Debug/*.app"].first
  target  = File.expand_path("~/Library/Input\ Methods")
  FileUtils.cp_r app, target
end

task :clean do
  puts `xcodebuild -project '#{PROJECT_NAME}.xcodeproj' -scheme '#{PROJECT_NAME}' clean`
end