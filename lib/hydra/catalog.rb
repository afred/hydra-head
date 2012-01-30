# *Using this Module is not necessary if you're writing Controllers in Rails3.*  
# In a Rails3 app, simply define regular Rails Controllers to expose the Resources & Actions you need and use Hydra::Controller to add Hydra support.
# For search & discovery in those apps, use Blacklight and customize the "index" partials for each type of content to include links to the show/edit actions of the corresponding Controllers.
#
# This Module extends Blacklight Catalog behaviors to give you a "Hydra" Catalog with edit and show behaviors on top of the Blacklight search behaviors.
# Include this module into any of your Blacklight Catalog classes (ie. CatalogController) to add Hydra functionality.
#
module Hydra::Catalog
  
  def self.included(klass)
    # Other modules to auto-include
    klass.send(:include, Hydra::Controller)
    klass.send(:include, Hydra::UI::Controller)
    
    
    # Controller filters
    # Also see the generator (or generated CatalogController) to see more before_filters in action
    klass.before_filter :load_fedora_document, :only=>[:show,:edit]
    
    # View Helpers
    klass.helper :hydra_uploader
    klass.helper :article_metadata
  end
  
  def edit
    show
    render "show"
  end
  
  # This will render the "delete" confirmation page and a form to submit a destroy request to the assets controller
  def delete
    show
    render "show"
  end

end
