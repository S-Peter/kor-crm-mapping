class ActualRelation
	@relation
	@domain
	@range
	
	@chainLinks = Array.new
	
	def initialize(relation, domain, range)
   @relation = relation
	 @domain = domain
	 @range = range
  end
  
  def relation
		return @relation
	end
	
	def domain
		return @domain
	end
	
	def range
		return @range
	end
	
	def addChainLink resource
    if @chainLinks == nil
      @chainLinks = Array.new
    end
    @chainLinks.push resource
  end
  
  def addChainLinkProperty crmProperty
    @chainLinks = @chainLinks.insert(-2, crmProperty)
  end
  
  def addChainLinkInnerNode crmClass
    @chainLinks = @chainLinks.insert(-2, crmClass)
  end
  
  def chainLinks
    @chainLinks
  end
  
  def getLastDomainClassInChainLinks
    return @chainLinks[@chainLinks.length-2]
  end
  
end
