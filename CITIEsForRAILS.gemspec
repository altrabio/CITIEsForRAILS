# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{CITIEsForRAILS}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Laurent Buffat & Pierre-Emmanuel JOUVE"]
  s.date = %q{2011-02-16}
  s.description = %q{CITIEsForRAILS (Class Inheritance & Table Iheritance Embeddings For RAILS) is a solution that extends Single/Multiple/Class Table Inheritance. This solution is based on classical Ruby class inheritance, single table inheritance as well as DB views.


  For Full Information GO TO : http://altrabio.github.com/CITIEsForRAILS/}
  s.email = %q{citiesforrails @nospam@ gmail.com}
  s.extra_rdoc_files = ["lib/citiesforrails.rb", "lib/citiesforrails/acts_as_cities.rb", "lib/citiesforrails/core_ext.rb"]
  s.files = ["Rakefile", "lib/citiesforrails.rb", "lib/citiesforrails/acts_as_cities.rb", "lib/citiesforrails/core_ext.rb", "Manifest", "CITIEsForRAILS.gemspec"]
  s.homepage = %q{https://github.com/altrabio/CITIEsForRAILS}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "CITIEsForRAILS", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{citiesforrails}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{CITIEsForRAILS (Class Inheritance & Table Iheritance Embeddings For RAILS) is a solution that extends Single/Multiple/Class Table Inheritance. This solution is based on classical Ruby class inheritance, single table inheritance as well as DB views.   For Full Information GO TO : http://altrabio.github.com/CITIEsForRAILS/}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
