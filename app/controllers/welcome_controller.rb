require 'bundler/setup'
Bundler.require(:default)

class WelcomeController < ApplicationController
  @@ecrmNamespace = "http://erlangen-crm.org/140617/"
  @@owlClassURI = RDF::URI.new("http://www.w3.org/2002/07/owl#Class")
  @@rdfTypeURI = RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")
  @@owlObjectPropertyURI = RDF::URI.new("http://www.w3.org/2002/07/owl#ObjectProperty")
  @@owlDatatypePropertyURI = RDF::URI.new("http://www.w3.org/2002/07/owl#DatatypeProperty")
  @@rdfsSubClassOfURI = RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#subClassOf")
  @@rdfsCommentURI = RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#comment")
  @@rdfsLabelURI = RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#label")
  @@skosNotationURI = RDF::URI.new("http://www.w3.org/2004/02/skos/core#notation")
  
  def index  
  #Load KOR-Resources
	#puts ActiveRecord::Base.connection.current_database
	@kinds = Kind.take(2)
	@relations = Relation.take(2)
	@entities = Entity.take(2)
	@relationships = Relationship.take(2)
	deriveActualRelationsFromRelationships
	
	#Load CRM-Resources
	if @graph == nil
	  @graph = RDF::Graph.load("http://erlangen-crm.org/140617/", :format => :rdfxml)
    puts "Number of statements of graph: #{@graph.size}"
      loadCRMClasses
      #loadCRMProperties
	end
	
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
  
  private 
  def writeNTriplesToFile
    file = File.new("newfile", "w")
    RDF::RDFXML::Reader.open("http://erlangen-crm.org/140617/") do |reader|
      reader.each_statement do |statement|
      file.write statement.inspect
      file.write "\n"
    end
    file.close
  end    
end

  private 
  def loadCRMClasses
    statements = @graph.query([nil, @@rdfTypeURI, @@owlClassURI])
    #puts "Number of classes: #{statements.count}"
    @crmClasses = Array.new
    statements.each_subject do |subject|
      if subject.uri?
        if subject.starts_with? @@ecrmNamespace
        crmClass = CrmClass.new
        crmClass.uri = subject
        
        statements = @graph.query([subject, @@rdfsLabelURI, nil])
        statements.each_object do |object|
          crmClass.label = object
        end
        
        statements = @graph.query([subject, @@rdfsCommentURI, nil])
        statements.each_object do |object|
          crmClass.comment = object
        end
        
        statements = @graph.query([subject, @@skosNotationURI, nil])
        statements.each_object do |object|
          crmClass.notation = object
        end
        end
     end
        
     @crmClasses.push crmClass
    end
    
    #Add Super & Sub Classes
    @crmClasses.each do |crmClass|
      statements = @graph.query([crmClass.uri, @@rdfsSubClassOfURI, nil])
      statements.each_object do |object|
        puts "add super and subclasses"
        if object.uri?
          if object.starts_with? @@ecrmNamespace
            puts object.inspect
            superClass = getClassOfUri object
            crmClass.addSuperClass superClass
            superClass.addSubClass crmClass
          end
        end 
      end
    end
    
    puts "CRMClasses:"
    @crmClasses.each do |crmClass|
      puts crmClass.uri.inspect
      puts crmClass.label
      puts crmClass.comment
      puts crmClass.notation
      puts "SuperClasses"
      if crmClass.superClasses != nil
        crmClass.superClasses.each do |superClass|
         puts superClass.uri.inspect
      end
      end
      puts "SubClasses"
      if crmClass.subClasses != nil
        crmClass.subClasses.each do |subClass|
         puts subClass.uri.inspect
      end
      end    
    end
  end
  
  private 
  def loadCRMProperties
    statements = @graph.query([nil, @@rdfTypeURI, @@owlObjectPropertyURI || @@owlDatatypePropertyURI])
    #puts "Number of properties: #{statements.count}"
    @crmProperties = Array.new
    statements.each_subject do |subject|
      if subject.uri?
        if subject.starts_with? @@ecrmNamespace
        crmProperty = CrmProperty.new
        crmProperty.uri = subject
        end
      end
    end
    
    #puts "CRMProperties:"
    #@crmProperties.each do |crmProperty|
    #  puts crmProperty.inspect
    #end
  end
  
 private 
 def getClassOfUri uri
   existingCrmClass = nil
   @crmClasses.each do |crmClass|
     #puts "getClassOfUri"
     if (crmClass.uri.eql? uri) && (existingCrmClass == nil)
       existingCrmClass = crmClass
     end
   end
   return existingCrmClass
 end
  
end