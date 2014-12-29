PROJECT MOVED TO LEARNINGWELL INTERNAL GITLAB SERVER
======= 


Cucumber STDDTool formatter
========

[Cucumber](http://cukes.info/)-formatter that send testresults to STDDTool


Get started:
-----
In your Gemfile:

```ruby
    gem 'stddtool'
```

and in your `/support/env.rb` file or any other file under the support directory:
```ruby
    require 'stddtool'
```



Run with:

```shell
cucumber --format STDDTool STDD_URL="http://localhost:3000" JOB="myjob" BUILD="2"
```

Note: If your cucumber-features contains scenario-outlines, add the parameter --expand
