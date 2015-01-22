class CrmClass# < ActiveRecord::Base
  @number
  @uri
  @comment
  @label
  @notation

  @superClasses = Array.new
  @subClasses = Array.new

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
    puts notation.value
    @id = notation.value.byteslice(1,notation.value.length)
    puts @id
  end

  def notation
    @notation
  end
  
  def number
    @number
  end
  
  def addSuperClass superClass
    if @superClasses == nil
      @superClasses = Array.new
    end
    @superClasses.push superClass
  end
  
  def superClasses
    @superClasses
  end
  
  def addSubClass subClass
    if @subClasses == nil
      @subClasses = Array.new
    end
    @subClasses.push subClass
  end
  
    def subClasses
    @subClasses
  end
  
  
end
