class Relation < ActiveRecord::Base #RelationshipType
	has_many :relationships

	@id
	@name
	@reverse_name
	@description
	
	@actualRelations
	
	#def initialize #if method exists no instance is created!!!
	#	@actualRelations = Array.new
	#end
	
	def actualRelations
		return @actualRelations
	end
	
	def actualRelations=(actualRelations)
		@actualRelations = actualRelations
	end
	
end
