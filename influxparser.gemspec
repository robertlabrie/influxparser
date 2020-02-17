Gem::Specification.new do |s|
  s.name               = 'influxparser'
  s.version            = '0.0.5'

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Robert Labrie']
  s.date = '2020-02-03'
  s.description = 'Unofficial influx line protocol parser'
  s.email = 'robert.labrie@gmail.com'
  s.files = Dir['lib/*.rb']
  s.test_files = ["test/test_parse_point_from_docs.rb"]
  # s.homepage = %q{http://rubygems.org/gems/hola}
  s.require_paths = %w[lib]
  # s.bindir = 'bin'
  s.rubygems_version = '1.6.2'
  s.summary = 'InfluxDB line protocol parser'

  if s.respond_to? :specification_version
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
    end
  end
end
