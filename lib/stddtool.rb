# encoding: utf-8
# features/support/twitter_formatter.rb
require 'rubygems'
require 'json'
require 'ostruct'
require 'cucumber/formatter/io'
require 'gherkin/formatter/argument'
require 'base64'
require 'cucumber/ast/scenario_outline'
require 'cucumber/ast/scenario'
require 'stdd_api'




module Cucumber
  module Formatter
    class STDDTool
      include Io
      attr_reader :runtime

      AST_CLASSES = {
          Cucumber::Ast::Scenario        => 'scenario',
          Cucumber::Ast::ScenarioOutline => 'scenario_outline'
      }

      def initialize(runtime, path_or_io, options)
        @runtime, @io, @options = runtime, ensure_io(path_or_io, "stddtool"), options
        @delayed_messages = []
        @io.puts @runID
        @connection_error = nil
        @io.puts "Initiating STDDTool(#{@url}) formatter for #{@project} : #{@module}"
        @inside_outline = false
        @io.flush

        @stdd_client = STDDAPI::Client.new(ENV['STDD_URL'],ENV['http_proxy'])

        #Collect all enviroment-variables
        @customer_name = ENV['CUSTOMER']
        @project_name = ENV['PROJECT']

        @run_name = ENV['RUN']
        @run_source = ENV['SOURCE']
        @run_revision = ENV['REV']

        init_customer_project_and_run(@customer_name,@project_name,@run_name,@run_source,@run_revision)

        @module_name = ENV['MODULE']
        init_module(@module_name)

      end

      def init_module name
        return if @connection_error
        valid,response = @stdd_client.create_module(@run.id,name,'cucumber',(Time.now.to_f * 1000).to_i)
        if(valid)
          @module = response
        else
          @connection_error = response
          puts @connection_error
        end
      end

      def init_customer_project_and_run customer_name, project_name, run_name, run_source, run_revision
        return if @connection_error
        #Customer
        create_customer_if_not_exist(customer_name)
        
        #Project
        create_project_if_not_exists(@customer.id,project_name)

        #Run
        create_run_if_not_exists(@project.id,run_name,run_source,run_revision)

      end

      def create_customer_if_not_exist customer_name
        return if @connection_error
        # Kontrollera om kunden finns
        valid, response = @stdd_client.get_customer customer_name

        # Om kunden finns
        if(valid && response)
          puts "Customer already exists"
        else
          puts "Customer does not exist, creating new.."
          # Skapa en kund
          valid, response = @stdd_client.create_customer customer_name
        end

        if(valid)
          @customer = response
          return true
        else
          @connection_error = response
          puts @connection_error
          return false
        end

      end

    def create_project_if_not_exists customer_id,project_name
      return if @connection_error
      # Kontrollera om projektet finns
      valid, response = @stdd_client.get_project customer_id, project_name

      # Om projektet finns
      if(valid)
        puts "Project already exists"
        @project = response
        return true
      end

      puts "Project does not exist, creating new.."
      # Skapa ett projekt
      valid, response = @stdd_client.create_project customer_id, project_name
      if valid
        @project = response
        return true
      else
        @connection_error = response
        puts @connection_error
        return false
      end

    end

    def create_run_if_not_exists project_id,run_name,run_source,run_revision
      return if @connection_error
      # Check if run exists
      valid, response = @stdd_client.get_run project_id, run_name

      # If run exist
      if(valid)
        puts "Run already exists"
        @run = response
        return true
      end

      puts "Run does not exist, creating new.."
      # Create run
      #Run
      valid, response = @stdd_client.create_run(@project.id,run_name,run_source,run_revision)
      if(valid)
        @run = response
      else
        @connection_error = response
        puts @connection_error
      end

    end

    def embed(src, mime_type, label)
      return if @connection_error
      @io.puts "got embedding"
      case mime_type
      when /^image\/(png|gif|jpg|jpeg)/
        buf = Base64.encode64(open(src,'rb') { |io| io.read })
        embedding=STDDAPI::Objects::Embedding.new(@scenario.id,mime_type,buf)
      
        valid,response = @stdd_client.add_embedding_to_scenario(embedding)
        if(valid)
          #success
        else
          @connection_error = response
          puts @connection_error
        end
      end
    end

      def before_feature(feature)
        return if @connection_error
        # puts feature.source_tag_names
        @feature = STDDAPI::Objects::Feature.new(@module.id,feature.title,Time.now)
        @feature.description = feature.description
        @feature.tags = feature.source_tag_names
        @feature.file = feature.file

        valid,response = @stdd_client.create_feature(@feature)
        if(valid)
          @feature.id = response
        else
          @connection_error = response
          puts @connection_error
        end

        # @feature_element = FeatureElement.new
        # @feature_element.tags  = Array.new
        # @feature_element.feature_ID = @featureID
        @scenario = STDDAPI::Objects::Scenario.new(@feature.id, "",'scenario','Scenario')
        @scenario.tags=Array.new

      end

      def tag_name(tag_name)
        return if @connection_error
        @scenario ? @scenario.tags.push({'name' => tag_name}) : true
      end

      def before_step(step)
        return if @connection_error
        @delayed_messages = []
        @step_start_time = Time.now
      end

      def before_step_result(*args)
        return if @connection_error
        @step_duration = Time.now - @step_start_time
      end

      def before_feature_element(feature_element)
        return if @connection_error
        @scenario.element_type = AST_CLASSES[feature_element.class]
      end

      def background_name(keyword, name, file_colon_line, source_indent)
        return if @connection_error
        @io.puts "Background #{name}"
        @scenario.name=name
        @scenario.keyword = keyword
        post_scenario

      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        return if @connection_error
        @io.puts "scenario #{name}"
        @scenario.name=name
        @scenario.keyword = keyword
        post_scenario
        
      end

      def post_scenario
        return if @connection_error
        valid,response = @stdd_client.create_scenario(@scenario)
        if(valid)
          @scenario.id = response
        else
          @connection_error = response
          puts @connection_error
        end
      end

      def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
        return if @connection_error
        step_name = step_match.format_args(lambda{|param| "*#{param}*"})
        @step = STDDAPI::Objects::Step.new(@scenario.id,keyword, step_name)
        @step.status=status
        @step.error_message = exception
        @step.duration = @step_duration
        @step.messages = @delayed_messages 

        valid,response = @stdd_client.add_step_to_scenario(@step)
        if(valid)
          # success
        else
          @connection_error = response
          puts @connection_error
        end
      end

      def after_features(features)
        return if @connection_error
        valid, response = @stdd_client.update_module_stopTime(@module.id,(Time.now.to_f * 1000).to_i)
        if(valid)
          @module = response
        else
          @connection_error = response
          puts @connection_error
        end
      end
    end
  end
end
