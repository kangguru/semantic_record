require 'rubygems'
require 'lib/semantic_record'
require 'spec/rake/spectask'
require 'echoe'

Echoe.new('semantic_record', '0.0.9') do |p|
  p.description    = "use sesame as backend"
  p.url            = "http://semanticrecord.aufnahme.com"
  p.author         = "Lars Brillert"
  p.email          = "development@aufnahme.com"
  p.ignore_pattern = ["coverage/*", "pkg/*"]
  p.development_dependencies = []
end

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList["spec/*_spec.rb"].sort
  t.spec_opts = ["--options", "spec/spec.opts"]
end

desc "Run all specs and get coverage statistics"
Spec::Rake::SpecTask.new('coverage') do |t|
  t.spec_opts = ["--options", "spec/spec.opts"]
  t.spec_files = FileList["spec/*_spec.rb"].sort
  t.rcov_opts = ["--exclude", "spec", "--exclude", "gems"]
  t.rcov = true
end


task :default => :spec
