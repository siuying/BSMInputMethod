require 'rubygems'
require 'bundler'
Bundler.require
require 'fileutils'

PROJECT_NAME = "BSMInputMethod"

namespace "build" do
  task :compile do
    puts `xcodebuild -project '#{PROJECT_NAME}.xcodeproj' -scheme '#{PROJECT_NAME}'`
  end

  task :install => ["build:compile"] do
    # kill any running instance of the IME
    `ps ax | grep BSMInputMethod.app | awk '{print $1}' | head -1 | xargs kill`

    # find build folder
    output = `xcodebuild -showBuildSettings`
    config = output.split("\n")
      .collect{|cmd| cmd.strip.split("=") }
      .select {|cmd| cmd.size == 2 }
      .inject({}){|map, val| map[val[0].strip] = val[1].strip; map }
    build_root = config["BUILD_ROOT"]

    # copy the IME to Input Method folder
    app     = Dir["#{build_root}/Debug/*.app"].first
    target  = File.expand_path("~/Library/Input\ Methods")
    FileUtils.cp_r app, target
    puts "    Installed to #{target}"
  end

  task :clean do
    puts `xcodebuild -project '#{PROJECT_NAME}.xcodeproj' -scheme '#{PROJECT_NAME}' clean`
  end
end

task :default => "build:install"
