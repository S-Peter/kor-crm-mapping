require 'json'

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
        directOrIndirectSubClasses = directOrIndirectSubClasses.push subClass
        directOrIndirectSubClasses = directOrIndirectSubClasses.concat subClass.getDirectOrIndirectSubClasses
      end
    else
      puts "No subclasses for #{self.label}"
    end
    return directOrIndirectSubClasses
  end
  
  def getDirectOrIndirectSuperClasses
    directOrIndirectSuperClasses = Array.new
    if @superClasses != nil
      for superClass in @superClasses
        directOrIndirectSuperClasses = directOrIndirectSuperClasses.push superClass
        directOrIndirectSuperClasses = directOrIndirectSuperClasses.concat superClass.getDirectOrIndirectSuperClasses
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
  
  def to_s
    "CrmClass:\n   #{@uri}, #{@notation}, #{@label}, #{@comment}\n"
  end
 
  def as_json(*a)
    {
      "json_class"   => self.class.name,
      "data"         => {"uri" => uri, "notation" => notation, "label" => label, "comment" => comment }
    }.to_json(*a)
  end
 
  #def self.json_create(o)
  #  new(*o["data"])
  #end
  
  def self.json_create(o)
    #new(*o["data"])
    crmClass = new(JSON.parse(o)["data"])
    #kind.fancy = 12
    crmClass
  end
 
end
