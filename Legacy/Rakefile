require 'rubygems'
require 'bundler'
Bundler.require
require 'fileutils'

require './tools/word_frequency'
require './tools/bsm_converter'

namespace "build" do
  task :compile do
    puts `xctool build`
  end

  task :install => ["build:compile"] do
    # kill any running instance of the IME
    `ps ax | grep BSMInputMethod.app | awk '{print $1}' | head -1 | xargs kill`

    # find build folder
    output = `xctool -showBuildSettings`
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
    puts `xctool clean`
  end
end

namespace "preprocess" do
  task :convert do
    @frequency = WordFrequency.new("./data/BIAU1.TXT")
    @converter = BsmConverter.new("./data/bsm.db", @frequency)
    @converter.setup

    data = open("data/bsm_applet.dat", 'r:BIG5-HKSCS').read

    ec = Encoding::Converter.new("BIG5-HKSCS", "UTF-8", :invalid => :replace, :undef => :replace )
    output = ec.convert(data)

    @converter.db.transaction do
      output.each_line do |line|
        if line =~ /(.{1,6}) (.)/
          @converter.add($1, $2)
        end
      end
    end


    extension = open("data/extension.txt", 'r').read
    @converter.db.transaction do
      extension.each_line do |line|
        if line =~ /(.{1,6}) (.)/
          @converter.add($1, $2)
        end
      end
    end
  end
end

task :test do
  system('xctool test')
end

task :default => "build:install"
