# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  require 'bubble-wrap'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Exact Online Kitchensink OS X'
  app.pods do
    pod 'DJProgressHUD_OSX'
#    pod 'AFNetworking'
  end
end

desc 'gen_apidatafile: generate api data file from exact online rest reference'
task :gen_apidatafile do

  require "exact_online_apidoc_parser"
  require "json"

  data_file = "Resources/data.json"
  sh "rm #{data_file}"

  parser = ExactOnlineApidocParser::Parse.new('tmp/cache')
  tree = parser.api_tree

  tree.each do | node,vals |
    p node
  end

  File.open(data_file, 'w') { |file| file.write(tree.to_json)}
end

