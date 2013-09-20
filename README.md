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

```
cucumber --format STDDTool URL="http://localhost:3000" JOBNAME="jobname"
```
