class Kind < ActiveRecord::Base #EntityType
	has_many :entities
	
	@id
	@name
	@description
end
