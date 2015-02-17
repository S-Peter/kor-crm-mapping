require 'json'

class Kind < ActiveRecord::Base #EntityType
	has_many :entities
	
	@id
	@name
	@description
	
	@crmClass
	
	attr_accessor :crm_class
	
	#attr_reader :crm_class
	def crmClass
    return @crmClass
  end
  
  #attr_writer :crm_class
  def crmClass=(crmClass)
    @crmClass = crmClass
  end
  
  def to_s
    "Kind:\n   #{id}, #{name}, #{description}, #{crmClass}\n"
  end
 
  def as_json(*a)
    {
      "json_class"   => self.class.name,
      "data"         => {"id" => id, "name" => name, "description" => description, "crmClass" => crmClass }
    }.as_json(*a)
  end
 
  def self.json_create(serializedObject)
    kind = new(JSON.parse(serializedObject)["data"])
    #kind.fancy = 12
    kind  
  end
	
end
