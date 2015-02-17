class Kind < ActiveRecord::Base #EntityType
	has_many :entities
	
	@id
	@name
	@description
	
	@crmClass
	
	def crmClass
    return @crmClass
  end
  
  def crmClass=(crmClass)
    @crmClass = crmClass
  end
	
end
