# encoding: utf-8

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
  attr_accessor :feature_title
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
  attr_accessor :step_name
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

class FeatureElement
  def initialize()
    tags = Array.new
  end
  attr_accessor :feature_ID,:keyword,:tags,:name,:element_type
  def to_json
      {'featureId' => @feature_ID,'keyword' => @keyword, 'name' => @name,'tags' => @tags,'element_type' => @element_type}.to_json
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

# class ScenarioExampleCell
#   def initialize(row,value,status)
#     @row = row
#     @value=value
#     @status=status
#   end
#   def to_json
#       {"$addToSet" => 
#         {"outline.#{@row.to_s}" =>{ 
#                   "value" => @value,
#                   "status" => @status
#                 }
#         }
#       }.to_json
#   end
# end