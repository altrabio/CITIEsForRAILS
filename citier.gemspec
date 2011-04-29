# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{citier}
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter Hamilton, Originally from Laurent Buffat, Pierre-Emmanuel Jouve"]
  s.date = %q{2011-04-29}
  s.description = %q{CITIER (Class Inheritance & Table Inheritance Embeddings for Rails) is a solution for single and multiple class table inheritance.
    For full information: http://peterejhamilton.github.com/citier/
    For the original version by ALTRABio see www.github.com/altrabio/}
  s.email = %q{peter@inspiredpixel.net}
  s.extra_rdoc_files = ["lib/citier.rb",
    "lib/citier/acts_as_citier.rb",
    "lib/citier/core_ext.rb",
    "lib/citier/class_methods.rb",
    "lib/citier/instance_methods.rb",
    "lib/citier/child_instance_methods.rb",
    "lib/citier/root_instance_methods.rb"]
  s.files = ["Rakefile",
    "lib/citier.rb",
    "lib/citier/acts_as_citier.rb",
    "lib/citier/core_ext.rb",
    "lib/citier/class_methods.rb",
    "lib/citier/instance_methods.rb",
    "lib/citier/child_instance_methods.rb",
    "lib/citier/root_instance_methods.rb",
    "Manifest",
    "citier.gemspec"]
  s.homepage = %q{https://github.com/peterejhamilton/citier/}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "citier", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{citier}
  s.rubygems_version = %q{1.3.7}
  s.summary = s.description

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
  end
end
