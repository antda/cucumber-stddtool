Gem::Specification.new do |s|
  s.name        = 'stddtool'
  s.version     = '0.5.0.1'
  s.date        = '2014-02-05'
  s.summary     = "Cucumber formatter for STDDTool"
  s.description = "Cucumber formatter that reports  cucumber testresults to STDDTool"
  s.authors     = ["Anton Danielsson","Anders Åslund", "Learningwell West"]
  s.email       = 'anton.danielsson@learningwell.se'
  s.files       = ["lib/stddtool.rb"]
  s.homepage    =
    'https://github.com/antda/cucumber-stddtool'
  s.license       = 'MIT'
  s.add_dependency('stdd_api', '~> 0.2.0.1')
end