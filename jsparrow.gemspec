# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jsparrow}
  s.version = "1.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Leandro Silva"]
  s.date = %q{2010-03-06}
  s.email = %q{leandrodoze@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "lib/client.rb",
     "lib/connection.rb",
     "lib/connection/configuration.rb",
     "lib/connection/provider.rb",
     "lib/error.rb",
     "lib/javaee.rb",
     "lib/javaee/javaee-1.5.jar",
     "lib/javaee/jms.jar",
     "lib/javaee/jsparrow-essential.jar",
     "lib/jsparrow.rb",
     "lib/listener.rb",
     "lib/messaging.rb",
     "sample/sample_queue.rb",
     "sample/sample_topic.rb",
     "spec/client_spec.rb",
     "spec/connection_spec.rb",
     "spec/listener_spec.rb",
     "spec/messaging_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/leandrosilva/jsparrow}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{JSparrow is a JMS client based on JRuby}
  s.test_files = [
    "spec/client_spec.rb",
     "spec/connection_spec.rb",
     "spec/listener_spec.rb",
     "spec/messaging_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

