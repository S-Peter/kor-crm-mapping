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
  @@rdfsRange = RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#range")
  @@rdfsDomain = RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#domain")
  @@owlInverseOf = RDF::URI.new("http://www.w3.org/2002/07/owl#inverseOf")
  @@rdfsSubPropertyOfURI = RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#subPropertyOf")
  
  def index  
    #Load KOR-Resources
  	puts ActiveRecord::Base.connection.current_database
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
      loadCRMProperties
  	end
  end 
  
  private
  def deriveActualRelationsFromRelationships
    #@relationships = Relationship.all #TODO decomment for full application
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
			 end #end?
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
    file = File.new("ecrm_ntriples", "w")
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
    puts "Number of properties: #{statements.count}"
    @crmProperties = Array.new
    statements.each_subject do |subject|
      if subject.uri?
        if subject.starts_with? @@ecrmNamespace
          crmProperty = CrmProperty.new
          crmProperty.uri = subject
          
          statements = @graph.query([subject, @@rdfsLabelURI, nil])
          statements.each_object do |object|
            crmProperty.label = object
          end
        
          statements = @graph.query([subject, @@rdfsCommentURI, nil])
           statements.each_object do |object|
            crmProperty.comment = object
          end
        
          statements = @graph.query([subject, @@skosNotationURI, nil])
          statements.each_object do |object|
            crmProperty.notation = object
          end
          
          #domain
          statements = @graph.query([subject, @@rdfsDomain, nil])
          if statements.first != nil #functional property
            object = statements.first.object 
            if object.uri?
              if object.starts_with? @@ecrmNamespace
                crmProperty.domain = getClassOfUri object
              end
            end
          end
        
          #range
          statements = @graph.query([subject, @@rdfsRange, nil])
          if statements.first != nil #functional property
            object = statements.first.object
            if object.uri?
              if object.starts_with? @@ecrmNamespace
                crmProperty.range = getClassOfUri object
              end
            end
          end         
        end
      end
      @crmProperties.push crmProperty
    end
    addSuperSubInverseProperties
    completeMissingDomainAndRange
    printCRMProperties
  end
  
 private 
 def getClassOfUri uri
   existingCrmClass = nil
   @crmClasses.each do |crmClass|
     if (crmClass.uri.eql? uri) && (existingCrmClass == nil)
       existingCrmClass = crmClass
     end
   end
   return existingCrmClass
 end
 
 private 
 def getPropertyOfUri uri
   existingCrmProperty = nil
   @crmProperties.each do |crmProperty|
     if (crmProperty.uri.eql? uri) && (existingCrmProperty == nil)
       existingCrmProperty = crmProperty
     end
   end
   return existingCrmProperty
 end
 
 #Add Super-, Sub- and InverseProperties
 private 
 def addSuperSubInverseProperties
    @crmProperties.each do |crmProperty|
      statements = @graph.query([crmProperty.uri, @@rdfsSubPropertyOfURI, nil])
      statements.each_object do |object|
        if object.uri?
          if object.starts_with? @@ecrmNamespace
            superProperty = getPropertyOfUri object
            crmProperty.addSuperProperty superProperty
            superProperty.addSubProperty crmProperty
          end
        end 
      end
      statements = @graph.query([crmProperty.uri, @@owlInverseOf, nil])
      statements.each_object do |object|
        if object.uri?
          if object.starts_with? @@ecrmNamespace
            inverseProperty = getPropertyOfUri object
            if crmProperty.inverseOf == nil
              crmProperty.inverseOf = inverseProperty
            end       
          end
        end 
      end
    end
 end
 
 # complete missing domain and range deriving them from 1) inverseProperty, 2) superProperties
 private
 def completeMissingDomainAndRange
    @crmProperties.each do |crmProperty|
      inverseProperty = crmProperty.inverseOf
      if crmProperty.domain == nil        
        if inverseProperty != nil && inverseProperty.range != nil #derive from inverse
          crmProperty.domain = inverseProperty.range
        else #derive from superproperteis
          crmProperty.domain = deriveDomainFromSuperProperty crmProperty.superProperties.first
        end
      end
      if crmProperty.range == nil
        if inverseProperty != nil && inverseProperty.domain != nil #derive from inverse
          crmProperty.range = inverseProperty.domain
        else #derive from superproperties
          crmProperty.range = deriveRangeFromSuperProperty crmProperty.superProperties.first
        end     
      end
    end
 end
 
 private
 def deriveDomainFromSuperProperty crmProperty
   domain = crmProperty.domain
   if domain != nil
     return domain
   else 
     return deriveDomainFromSuperProperty crmProperty.superProperties.first
   end
 end
 
 private
 def deriveRangeFromSuperProperty crmProperty
   range = crmProperty.range
   if range != nil
     return range
   else 
     return deriveRangeFromSuperProperty crmProperty.superProperties.first
   end
 end
 
 private
 def printCRMProperties
    file = File.new("crmProperties", "w")
    puts "CRMProperties:"
    @crmProperties.each do |crmProperty|
      file.write crmProperty.uri.inspect
      file.write "\n" 
      file.write "Label: #{crmProperty.label}"
      file.write "\n"
      file.write "Comment: #{crmProperty.comment}"
      file.write "\n" 
      file.write "Notation: #{crmProperty.notation}"
      file.write "\n"
      file.write "Domain: "
      if crmProperty.domain != nil
        file.write crmProperty.domain.uri.inspect
      end
      file.write "\n"
      file.write "Range: "
      if crmProperty.range != nil
        file.write crmProperty.range.uri.inspect
      end
      file.write "\n"
      file.write "SuperProperties"
      file.write "\n"
      if crmProperty.superProperties != nil
        crmProperty.superProperties.each do |superProperty|
          file.write superProperty.uri.inspect
          file.write "\n"
        end
      end
      file.write "SubProperties"
      file.write "\n"
      if crmProperty.subProperties != nil
        crmProperty.subProperties.each do |subProperty|
         file.write subProperty.uri.inspect
         file.write "\n"
        end
      end  
      file.write "InverseOf"
      file.write "\n"
      if crmProperty.inverseOf !=nil
        file.write crmProperty.inverseOf.uri.inspect
        file.write "\n"
      end 
      file.write "-----------------------------------------------"
      file.write "\n"
      file.write "\n"
    end
    file.close
 end
  
end