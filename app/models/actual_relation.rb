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
  
  def chainLinks
    @chainLinks
  end
  
end
