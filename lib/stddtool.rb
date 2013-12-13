# encoding: utf-8
# features/support/twitter_formatter.rb
require 'rubygems'
require 'json'
require 'ostruct'
require 'cucumber/formatter/io'
require 'gherkin/formatter/argument'
require 'base64'

  class STDDTool

    def initialize(step_mother, io, options)
      @buildnr = ENV['BUILD']
      @job = ENV['JOB']
      @url = ENV['STDD_URL'] ? ENV['STDD_URL'] : ['www.stddtool.se']
      @proxy = ENV['http_proxy'] ? URI.parse('http://'+ENV['http_proxy']) : OpenStruct.new
      # Generate string as runId
      o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
      @runID = (0...50).map{ o[rand(o.length)] }.join
      @delayed_messages = []
      p @runID
      p "Initiating STDDTool(#{@url}) formatter for #{@job} : #{@buildnr}"
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
    end

    def before_background(background)
        @in_background = true
      end

      def after_background(background)
        @in_background = nil
      end

    def before_step(step)
      @delayed_messages = []
      @start_time = Time.now
    end

    def before_step_result(*args)
      @duration = Time.now - @start_time
    end

    def scenario_name(keyword, name, file_colon_line, source_indent)
      p "scenario #{name}"
      scenarioObj=ScenarioObj.new(@featureID,keyword,name,@embedding)
      postScenario(scenarioObj)
    end


    def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
      if @in_background == true
        # do nothing. background gets reported as step anyway
      else
         step_name = step_match.format_args(lambda{|param| "*#{param}*"})
        # message = "#{step_name} #{status}"
        # puts keyword + " "  + message
        stepObj=StepObj.new(keyword,step_name,status,exception, @duration,@delayed_messages)
        postStep(@scenarioID,stepObj)
      end
    end

    def postFeature(featureObj)
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


    def postStep(scenarioID,stepObj)
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

    def postScenario(scenarioObj)
      uri = URI.parse(@url)
      http = Net::HTTP::Proxy(@proxy.host, @proxy.port).new(uri.host, uri.port)
      request = Net::HTTP::Post.new("/collectionapi/scenarios")
      request.add_field('X-Auth-Token', '97f0ad9e24ca5e0408a269748d7fe0a0')
      request.body = scenarioObj.to_json
      response = http.request(request)
      # puts response.body
      parsed = JSON.parse(response.body)
      @scenarioID =  parsed["_id"]
    end

  end

class FeatureObj
  def initialize(job,build,title,description,file,tags,runId)
    @id = title.downcase.gsub(' ', '-')
    @job = job
    @build = build
    @feature_title=title
    @feature_description = description
    @feature_file = file
    @runID = runId

    tagArr = Array.new
    tags.each do |tag|
      tagArr.push({'name' => tag})
    end

    @feature_tags = tagArr

  end
  def to_json
    {
      'id' => @id,
      'job' => @job,
      'build' => @build,
      'runID' => @runID,
      'title' => @feature_title,
      'description' => @feature_description ,
      'file' => @feature_file,
      'tags' => @feature_tags,
      }.to_json
  end
end


class StepObj
  def initialize(keyword, name, status,exception,duration,messages)
    @step_keyword=keyword
    @step_name=name
    @step_status=status
    @step_exception = exception
    @step_duration = duration
    @step_messages = messages
  end
  def to_json
      {'$addToSet' => 
        {'steps' =>{'keyword' => @step_keyword,
                    'name' => @step_name ,
                    'result' => {'status' =>@step_status,'error_message'=> @step_exception,'duration'=>@step_duration},
                    'messages' => @step_messages
                  }
        }
      }.to_json
  end
end

class ScenarioObj
  def initialize(featureID,keyword, name,embedding)
    @feature_ID = featureID
    @scenario_keyword=keyword
    @scenario_name=name
    @scenario_embedding = embedding
  end
  def to_json
      {'featureId' => @feature_ID,'keyword' => @scenario_keyword, 'name' => @scenario_name,'embedding' => @scenario_embedding }.to_json
  end
end

class EmbeddingObj
  def initialize(mime_type,data)
    @mime_type = mime_type
    @data=data
  end
  def to_json
      {'$addToSet' =>{'embeddings' =>{'mime_type' => @mime_type,'data' => @data}}}.to_json
  end
end
