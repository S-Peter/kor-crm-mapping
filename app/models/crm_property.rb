class CrmProperty #< ActiveRecord::Base
  @number
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
    if notation.value[-1, 1].eql? "i"
      @number = notation.value.byteslice(1,notation.value.length-1).to_i * 2
    else
      @number = (notation.value.byteslice(1,notation.value.length).to_i * 2) - 1
    end
  end

  def notation
    @notation
  end
  
  def number
    @number
  end
  
  def domain=(domain)
    @domain = domain
  end

  def domain 
    @domain
  end
  
  def domainClasses #list of most abstract domain class and its subclasses
    domainClasses = Array.new
    domainClasses.push @domain
    domainClasses.push @domain.directOrIndirectSubClasses
    return domainClasses
  end
  
  def range=(range)
    @range = range
  end

  def range 
    @range
  end
  
  def getRangeClasses #list of most abstract class and its subclasses
    rangeClasses = Array.new
    rangeClasses.push @range
    rangeClasses.push @range.directOrIndirectSubClasses
    return rangeClasses
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
