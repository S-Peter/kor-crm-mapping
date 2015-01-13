class ActualRelation #< ActiveRecord::Base
	@relation
	@domain
	@range
	
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
  
end
