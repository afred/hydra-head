# properties datastream: catch-all for info that didn't have another home.  Particularly depositor
module Hydra::Datastream
  class Properties < ActiveFedora::NokogiriDatastream
    set_terminology do |t|
      t.root(:path=>"fields", :xmlns => '', :namespace_prefix => nil) 
      # This is where we put the user id of the object depositor -- impacts permissions/access controls
      t.depositor :xmlns => '', :namespace_prefix => nil
      
      # Deprecated Fields 
      # Collection should be tracked in RELS-EXT RDF
      # t.collection :xmlns => '', :namespace_prefix => nil
      # Title should be tracked in descMetadata
      # t.title :xmlns => '', :namespace_prefix => nil
    end

    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.fields
      end

      builder.doc
    end
  end
end
