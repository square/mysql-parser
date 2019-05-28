require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |c|
  options = ['--color']
  options += ["--format", "documentation"]
  c.rspec_opts = options
end

desc "Generate Lexer"
task :lexer do
  `rex mysql.rex.rb -o lib/mysql-parser/lexer.rb`
end

desc "Generate Parser"
task :parser do
  `racc -t -v -O parser.output mysql.y.rb -o lib/mysql-parser/parser.rb`
end

desc "Generate literal"
task :generate_literal do
  ruby "./bin/generate-literal"
end

desc "Sanity check"
task :sanity_check do
  ruby "./bin/sanity_check"
end

desc "Generate Lexer and Parser"
task :generate => [:lexer, :parser, :sanity_check, :generate_literal,
                   :lexer, :parser]
# generate lexer/parser twice because we need :generate_literal to autogenerate
# lexer, but :generate_literal needs parser.output which is generated from
# the parser itself

# sanity check must come before generate literal to prevent generating
# bad literals

desc "Clean up"
task :cleanup do
  `rm lib/mysql-parser/lexer.rb`
  `rm lib/mysql-parser/parser.rb`
end
