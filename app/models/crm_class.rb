class CrmClass < CrmRessource
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
    @number = notation.value.byteslice(1,notation.value.length).to_i
  end

  def notation
    @notation
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
  
  def getDirectOrIndirectSubClasses
    directOrIndirectSubClasses = Array.new
    if @subClasses != nil
      for subClass in @subClasses
        directOrIndirectSubClasses.push subClass
        directOrIndirectSubClasses.push subClass.getDirectOrIndirectSubClasses
      end
    end
    return directOrIndirectSubClasses
  end
  
  def getDirectOrIndirectSuperClasses
    directOrIndirectSuperClasses = Array.new
    if @superClasses != nil
      for superClass in @superClasses
        directOrIndirectSuperClasses.push superClass
        directOrIndirectSuperClasses.push superClass.getDirectOrIndirectSuperClasses
      end
    end
    return directOrIndirectSuperClasses
  end
  
  def isA? crmClass
    isA = false
    if crmClass.number == number
      isA = true
    else
      if @superClasses != nil
        for superClass in @superClasses
          isA = superClass.isA? crmClass
          if isA == true
            break
          end
        end
      end
    end
    return isA
  end
 
end
