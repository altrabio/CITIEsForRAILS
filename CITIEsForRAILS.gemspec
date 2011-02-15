# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{CITIEsForRAILS}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Young"]
  s.date = %q{2011-02-15}
  s.description = %q{A gem that illustrates how to build a gem}
  s.email = %q{beesucker @nospam@ gmail.com}
  s.extra_rdoc_files = ["lib/citiesforrails.rb", "lib/citiesforrails/acts_as_cities.rb", "lib/citiesforrails/core_ext.rb"]
  s.files = ["Rakefile", "lib/citiesforrails.rb", "lib/citiesforrails/acts_as_cities.rb", "lib/citiesforrails/core_ext.rb", "Manifest", "CITIEsForRAILS.gemspec"]
  s.homepage = %q{http://github.com/tombombadil/hello_world}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "CITIEsForRAILS"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{citiesforrails}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A gem that illustrates how to build a gem}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
