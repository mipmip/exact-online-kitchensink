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
end

desc 'gen_resources: generate all resource classes'
task :gen_resources do

  require "exact_online_apidoc_parser"
  require "json"

  output_dir = "api_resources/"
  sh "rm -Rf #{output_dir}"
  sh "mkdir -p #{output_dir}"

  parser = ExactOnlineApidocParser::Parse.new('tmp/cache')
  tree = parser.api_tree

  tree.each do | node,vals |
    p node
  end

  File.open("api_resources/data.json", 'w') { |file| file.write(tree.to_json)}
end

