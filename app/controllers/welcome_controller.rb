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
  
  @graph
  
  @crmClasses
  @crmProperties
  
  @kinds
  @relations
  
  @kindIndex
  @kind
  
=begin
  def initialize
    #Load KOR-Resources
    loadKor
    #Load CRM-Resources
    loadCRM
  end
=end  

  def index  
    #Load KOR-Resources
    loadKor
    #Load CRM-Resources
    loadCRM
    
    session[:crmClasses] = @crmClasses
    session[:crmProperties] = @crmProperties

    session[:kinds] = @kinds
    session[:relations] = @relations
   
    preMapKorKind
    
  end 
  
=begin  
  def mapKorKind
    postMapKorKind
    puts "MapKorKind"
    preMapKorRelationRange
  end
  
  def mapKorRelationRange
     postMapKorRelationRange
     puts "MapKorRelationRange"
     preMapKorRelationProperty
  end
  
  def mapKorRelationProperty
    postMapKorRelationProperty
    puts "MapKorRelationProperty"
  end
=end
  
  def preMapKorKind
    @kinds = session[:kinds]
    @kindIndex = session[:kindIndex]
    if @kindIndex == nil # no kind mapped yet
      @kindIndex = 0
      session[:kindIndex] = @kindIndex
    end 
    if @kindIndex < @kinds.length
      @kind = @kinds[@kindIndex]
      session[:kind] = @kind  
      render 'mapKorKind' 
    else # all kinds mapped -> end
      displayMapping
    end
  end
  
  def mapKorKind
    @kind = session[:kind]
    @crmClasses= session[:crmClasses]
    @relations = session[:relations]
    
    for mappedCRMClass in @crmClasses do
      if mappedCRMClass.number == params[:crmc].to_i
        break
      end
    end
    @kind.crmClass=mappedCRMClass
    
    #calculate actual relations for given domain
    @actualRelationsWithDomain = Array.new
    for relation in @relations
      if relation.actualRelations != nil
        for actualRelation in relation.actualRelations
          if actualRelation.domain == @kind
            @actualRelationsWithDomain.push actualRelation      
          end
        end
      end
    end
    session[:actualRelationsWithDomain] = @actualRelationsWithDomain
    
    #increment kindIndex
    @kindIndex = session[:kindIndex]
    @kindIndex = @kindIndex + 1
    session[:kindIndex] = @kindIndex # nötig?
    
    preMapKorRelationRange
  end
    
  def preMapKorRelationRange
    puts "preMapKorRelationRange"
    @actualRelationsWithDomain = session[:actualRelationsWithDomain]
    @actualRelationIndex = session[:actualRelationIndex]
    if @actualRelationIndex == nil # no actual relation for kind mapped yet
      @actualRelationIndex = 0
    end
    @crmClasses = session[:crmClasses]
    if @actualRelationsWithDomain != nil 
      if @actualRelationIndex < @actualRelationsWithDomain.length
        @actualRelation = @actualRelationsWithDomain[@actualRelationIndex]
        session[:actualRelation] = @actualRelation
        session[:actualRelationIndex] = @actualRelationIndex
        render 'mapKorRelationRange'
      end
    else
      preMapKorKind # all actual relations for kind mapped -> mapping of next kind
    end
  end
  
  def mapKorRelationRange
    @kind = session[:kind]
    @crmClasses= session[:crmClasses]
    @actualRelation = session[:actualRelation]
    
    for mappedCRMClass in @crmClasses do
      if mappedCRMClass.number == params[:crmc].to_i
        break
      end
    end
    
    @actualRelation.addChainLink @kind.crmClass # domain, in postmapkorkind?
    @actualRelation.addChainLink mappedCRMClass # range
    
    @actualRelationIndex = session[:actualRelationIndex]
    @actualRelationIndex = @actualRelationIndex + 1
    session[:actualRelationIndex] = @actualRelationIndex # nötig?  
    
    preMapKorRelationProperty
  end
  
  def preMapKorRelationProperty
    @fittingCRMProperties = Array.new
    crmProperties = session[:crmProperties]
    crmClasses = session[:crmClasses]
    @kind = session[:kind]
    @actualRelation = session[:actualRelation]    
    
    #crmClass = kind.crmClass # kind is domain of actual relation
    crmClass = @actualRelation.getLastDomainClassInChainLinks

    for crmProperty in crmProperties
        if crmClass.isA? crmProperty.domain
          @fittingCRMProperties.push crmProperty
        end
    end
    render 'mapKorRelationProperty' 
  end
  
  def mapKorRelationProperty
    propertyNumber = params[:property]
    crmProperties = session[:crmProperties]
    actualRelation = session[:actualRelation]
    
    puts propertyNumber
    
    for crmProperty in crmProperties
      if crmProperty.number.to_i == propertyNumber.to_i
        break
      end
    end   
    actualRelation.addChainLinkProperty crmProperty
    
    puts actualRelation.chainLinks.last.label
    puts crmProperty.label
    puts crmProperty.range.label
    
    puts actualRelation.chainLinks.last.isA? crmProperty.range
    
    if !(actualRelation.chainLinks.last.isA? crmProperty.range) #range not yet reached-> continue chain linking
      actualRelation.addChainLinkInnerNode crmProperty.range
      preMapKorRelationProperty
    else
      puts "range reached -> map next actual relation"
      #redirect_to action: "preMapKorRelationRange" and return  #range reached -> map next actual relation
      preMapKorRelationRange and return
      
    end
  end
  
  def displayMapping
    puts "--------------------------END--------------------------"
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
  def loadKor
    puts ActiveRecord::Base.connection.current_database
    @kinds = Kind.all
    @relations = Relation.all
    deriveActualRelationsFromRelationships
  end
  
  private
  def deriveActualRelationsFromRelationships
    # TODO relationships = Relationship.all
    relationships = Relationship.find([473150,473297])
    for relationship in relationships
      for relation in @relations
        if relation.id == relationship.relation.id
          relationOfRelationship = relation
        end
      end
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
     end
  end
   
  private
  def loadCRM
    if @graph == nil
      @graph = RDF::Graph.load("http://erlangen-crm.org/140617/")
      #@graph = RDF::Graph.load("http://erlangen-crm.org/140617/", :format => :rdfxml)
      #@graph = RDF::Graph.load("C:\Users\Sven\ECRM\ecrm_140617.owl.rdf", :format => :rdfxml)
      loadCRMClasses
      loadCRMProperties
    end
  end

  private 
  def loadCRMClasses
    statements = @graph.query([nil, @@rdfTypeURI, @@owlClassURI])
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
    
    #order Array
    @crmClasses = @crmClasses.sort_by {|x| x.number}
  end
  
  private 
  def loadCRMProperties
    statements = @graph.query([nil, @@rdfTypeURI, @@owlObjectPropertyURI || @@owlDatatypePropertyURI])
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
    
    #order Array
    @crmProperties = @crmProperties.sort_by {|x| x.number}
    
    #printCRMProperties
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
        else #derive from superproperties
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
 
 private
 def printCRMProperties
    file = File.new("crmProperties", "w")
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