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
cucumber --format Cucumber::Formatter::STDDTool STDD_URL="http://localhost:3000" CUSTOMER="mycustomer" PROJECT="myproject" SOURCE="mysource" REV="myrev" MODULE="mymodule"  RUN="1"
```

Or run with --out to run with other formatters and get a logile instead:

```shell
cucumber --format Cucumber::Formatter::STDDTool --out stddtool.log STDD_URL="http://localhost:3000" CUSTOMER="mycustomer" PROJECT="myproject" SOURCE="mysource" REV="myrev" MODULE="mymodule"  RUN="1"
```

REV is optional

Note: If your cucumber-features contains scenario-outlines, add the parameter --expand
