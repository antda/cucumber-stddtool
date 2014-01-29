# encoding: utf-8
# features/support/twitter_formatter.rb
require 'rubygems'
require 'json'
require 'ostruct'
require 'cucumber/formatter/io'
require 'gherkin/formatter/argument'
require 'base64'

require 'objects'

  class STDDTool

    def initialize(step_mother, io, options)
      @buildnr = ENV['BUILD']
      @job = ENV['JOB']
      @url = ENV['STDD_URL'] ? ENV['STDD_URL'] : ['http://www.stddtool.se']
      @proxy = ENV['http_proxy'] ? URI.parse('http://'+ENV['http_proxy']) : OpenStruct.new
      # Generate string as runId
      o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
      @runID = (0...50).map{ o[rand(o.length)] }.join
      @delayed_messages = []
      p @runID
      p "Initiating STDDTool(#{@url}) formatter for #{@job} : #{@buildnr}"
      @inside_outline = false
    end

    def embed(src, mime_type, label)
      p "got embedding"
      case(mime_type)
      when /^image\/(png|gif|jpg|jpeg)/
        buf = Base64.encode64(open(src) { |io| io.read })
        embeddingObj=EmbeddingObj.new(mime_type,buf)
        p "starts to post embedding"
        postEmbedding(@scenarioID,embeddingObj)
        p "posted embedding to scenario with id : #{@scenarioID}"
      end
    end

    def puts(message)
      @delayed_messages << message
    end



    def before_feature(feature)
      # puts feature.source_tag_names
      featureObj=FeatureObj.new(@job,@buildnr,feature.title,feature.description,feature.file,feature.source_tag_names,@runID)
      postFeature(featureObj)

      @feature_element = FeatureElement.new
      @feature_element.tags  = Array.new
      @feature_element.feature_ID = @featureID

    end


    def before_feature_element(feature_element)
      # @feature_element = FeatureElement.new
      # @feature_element.tags  = Array.new
      # @feature_element.feature_ID = @featureID
    end

    def tag_name(tag_name)
      @feature_element ? @feature_element.tags.push({'name' => tag_name}) : true
    end

    def before_background(background)
        # @in_background = true
    end

    def after_background(background)
      # @in_background = nil
    end

    def before_step(step)
      @delayed_messages = []
      @start_time = Time.now
    end

    def before_step_result(*args)
      @duration = Time.now - @start_time
    end


    def background_name(keyword, name, file_colon_line, source_indent)
      p "Background #{name}"
      @feature_element.name=name
      @feature_element.keyword = keyword
      postFeatureElement(@feature_element)
    end

    def scenario_name(keyword, name, file_colon_line, source_indent)
      p "scenario #{name}"
      @feature_element.name=name
      @feature_element.keyword = keyword
      postFeatureElement(@feature_element)
    end

    def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
        step_name = step_match.format_args(lambda{|param| "*#{param}*"})
        stepObj=StepObj.new(keyword,step_name,status,exception, @duration,@delayed_messages)
        postStep(@scenarioID,stepObj)
      #end
    end

    def postFeature(featureObj)
      p "posting feature #{featureObj.feature_title}"
      uri = URI.parse(@url)
      http = Net::HTTP::Proxy(@proxy.host, @proxy.port).new(uri.host, uri.port)
      request = Net::HTTP::Post.new("/collectionapi/features")
      request.add_field('X-Auth-Token', '97f0ad9e24ca5e0408a269748d7fe0a0')
      request.body = featureObj.to_json
      response = http.request(request)
      case response.code 
        when /20\d/
          #success
        else
          p response.body
          exit 
      end
      parsed = JSON.parse(response.body)

      if parsed["error"]
        p parsed["error"]
      end
      @featureID =  parsed["_id"]

    end

  # #additional code for scenario-outline

  # def before_outline_table(outline_table)
  #   p "before outline table"
  #   @inside_outline = true
  #   @outline_row = 0
  # end

  # def after_outline_table(outline_table)
  #   p "after outline table"
  #   @outline_row = nil
  #   @inside_outline = false
  # end

  # def before_examples(examples)
  #    @examples_array = Array.new
  #    @examplesRowNumber=0;
  # end

  # def examples_name(keyword, name)
  #   p "keyword: #{keyword}"
  #   p "name: #{name}"
  # end
      
  # # def  after_examples_array(arg1)
  # #   p "after examples array: #{arg1}"
  # # end
  # def before_table_row(table_row)
  #   # @cellArray = Array.new
  # end

  # def table_cell_value(value, status)
  #   scenarioExampleCell=ScenarioExampleCell.new(@examplesRowNumber,value,status)
  #   postScenarioExampleCell(@scenarioID,scenarioExampleCell)
  # end

  # def after_table_row(table_row)
    
  #     p @cellArray
  #   if table_row.exception
  #     p "tr exception: #{table_row.exception}"
      
  #   end
  #   p "after table row"
  #   if @outline_row
  #     @outline_row += 1
  #   end
  #   @examplesRowNumber = @examplesRowNumber +1
  # end

  # def after_examples(examples)
  #   p "after examples"
  # end




    def postStep(scenarioID,stepObj)
      p "posting step #{stepObj.step_name}"
      uri = URI.parse(@url)
      path = "/collectionapi/scenarios/#{scenarioID}"
      req = Net::HTTP::Put.new(path, initheader = { 'X-Auth-Token' => '97f0ad9e24ca5e0408a269748d7fe0a0'})
      req.body = stepObj.to_json
      response = Net::HTTP::Proxy(@proxy.host, @proxy.port).new(uri.host, uri.port).start {|http| http.request(req) }
    end

    def postEmbedding(scenarioID,embeddingObj)
      uri = URI.parse(@url)
      path = "/collectionapi/scenarios/#{scenarioID}"
      req = Net::HTTP::Put.new(path, initheader = { 'X-Auth-Token' => '97f0ad9e24ca5e0408a269748d7fe0a0'})
      req.body = embeddingObj.to_json
      response = Net::HTTP::Proxy(@proxy.host, @proxy.port).new(uri.host, uri.port).start {|http| http.request(req) }
    end

    def postFeatureElement(feature_element)
      p "posting featureElement #{feature_element.name}"
      uri = URI.parse(@url)
      http = Net::HTTP::Proxy(@proxy.host, @proxy.port).new(uri.host, uri.port)
      request = Net::HTTP::Post.new("/collectionapi/scenarios")
      request.add_field('X-Auth-Token', '97f0ad9e24ca5e0408a269748d7fe0a0')
      request.body = feature_element.to_json
      response = http.request(request)
      # puts response.body
      parsed = JSON.parse(response.body)
      @scenarioID =  parsed["_id"]
    end

    # def postScenarioExampleCell(scenarioID,scenarioExampleItem)
    #   p "posting postScenarioExampleCell"
    #   uri = URI.parse(@url)
    #   path = "/collectionapi/scenarios/#{scenarioID}"
    #   req = Net::HTTP::Put.new(path, initheader = { 'X-Auth-Token' => '97f0ad9e24ca5e0408a269748d7fe0a0'})
    #   req.body = scenarioExampleItem.to_json
    #   response = Net::HTTP::Proxy(@proxy.host, @proxy.port).new(uri.host, uri.port).start {|http| http.request(req) }
    # end




end
