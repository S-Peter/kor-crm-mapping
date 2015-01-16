class CrmProperty #< ActiveRecord::Base
  @uri
  @label
  @notation
  @comment
  
  @domain
  @range
  
  @inverseOf
  
  @superProperties = Array.new
  @subProperties = Array.new
  
  def uri=(uri)
    @uri = uri
  end

  def uri
    @uri
  end
  
  def comment=(comment)
    @comment = comment
  end

  def comment
    @comment
  end
  
  def label=(label)
    @label = label
  end

  def label
    @label
  end
  
   def notation=(notation)
    @notation = notation
  end

  def notation
    @notation
  end
  
  def domain=(domain)
    @domain = domain
  end

  def domain
    @domain
  end
  
  def range=(range)
    @range = range
  end

  def range
    @range
  end
  
  def inverseOf=(inverseOf)
    @inverseOf = inverseOf
  end

  def inverseOf
    @inverseOf
  end
  
  def addSuperProperty superProperty
    if @superProperties == nil
      @superProperties = Array.new
    end
    @superProperties.push superProperty
  end
  
  def superProperties
    @superProperties
  end
  
  def addSubProperty subProperty
    if @subProperties == nil
      @subProperties = Array.new
    end
    @subProperties.push subProperty
  end
  
    def subProperties
    @subProperties
  end
end
