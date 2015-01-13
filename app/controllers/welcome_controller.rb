class WelcomeController < ApplicationController
  def index
	puts ActiveRecord::Base.connection.current_database
	@kinds = Kind.take(2)
	@relations = Relation.take(2)
	@entities = Entity.take(2)
	@relationships = Relationship.take(2)
	deriveActualRelationsFromRelationships
  end 
  
  private
  def deriveActualRelationsFromRelationships
    #@relationships = Relationship.all
	for relationship in @relationships
		relationOfRelationship = relationship.relation
		domainClassOfRelationship = relationship.domain.kind
		rangeClassOfRelationship = relationship.range.kind
			
		actualRelations = relationOfRelationship.actualRelations
		actualRelationWithSameDomainAndRangeExists = false;
		if !actualRelations.nil?
			for actualRelation in actualRelations
				if actualRelation.domain == domainClassOfRelationship and actualRelation.range == rangeClassOfRelationship
					actualRelationWithSameDomainAndRangeExists=true;
				end
			end
			if actualRelationWithSameDomainAndRangeExists == false
				newActualRelation = ActualRelation.new relationOfRelationship, domainClassOfRelationship, rangeClassOfRelationship
				actualRelations.push newActualRelation
			end
		else
			newActualRelation = ActualRelation.new relationOfRelationship, domainClassOfRelationship, rangeClassOfRelationship
			actualRelations = Array.new
			actualRelations.push newActualRelation
			relationOfRelationship.actualRelations=actualRelations
		end
		puts newActualRelation.relation.name
		puts newActualRelation.domain.name
		puts newActualRelation.range.name
	end
  end
end
