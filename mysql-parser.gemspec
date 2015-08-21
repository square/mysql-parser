Gem::Specification.new do |s|
  s.name        = 'mysql-parser'
  s.version     = '0.0.2'
  s.summary     = "MySQL parser"
  s.description = "Used for parsing SQL commands"
  s.authors     = ["Sorawee Porncharoenwase", "Michael Finch"]
  s.email       = 'mfinch@squareup.com'
  s.homepage    = 'https://github.com/square/mysql-parser'
  s.license     = 'Apache'

  s.add_development_dependency "racc", '~> 0'
  s.add_development_dependency "rexical", '~> 0'
  s.files       = Dir.glob('lib/*') + Dir.glob('bin/*') + %w(README.md)
end
