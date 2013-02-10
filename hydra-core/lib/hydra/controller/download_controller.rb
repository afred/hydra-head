module Hydra
  module Controller
    module DownloadController
      extend ActiveSupport::Concern

      included do
        before_filter :load_asset
        before_filter :load_datastream
      end
      
      def show
        if can_download?(ds)
          # we can now examine @asset and determine if we should send_content, or some other action.
          send_content (asset)
        else 
          logger.info "Can not read #{params['id']}"
          redirect_to "/assets/NoAccess.png"
        end
      end

      protected

      def load_asset
        @asset = ActiveFedora::Base.find(params[:id], :cast=>true)
      end

      def load_datastream
        @ds = datastream_to_show()
      end

      def asset
        @asset
      end

      def datastream
        @ds
      end

      def can_download?
        can? :read, ds.pid
      end 


      def datastream_to_show(asset)
        if params.has_key?(:datastream_id)
          opts[:filename] = params[:datastream_id]
          ds = asset.datastreams[params[:datastream_id]]
        end
        ds = default_content_ds(asset) if ds.nil?
        ds
      end
      
      def send_content (asset)
          opts = {}
          opts[:filename] = asset.label || ds.dsid
          opts[:disposition] = 'inline' 
          raise ActionController::RoutingError.new('Not Found') if ds.nil?
          data = ds.content
          opts[:type] = ds.mimeType
          send_data data, opts
          return
      end
      
      
      private 
      
      def default_content_ds(asset)
        ActiveFedora::ContentModel.known_models_for(asset).each do |model_class|
          return model_class.default_content_ds if model_class.respond_to?(:default_content_ds)
        end
        if asset.datastreams.keys.include?(DownloadsController.default_content_dsid)
          return asset.datastreams[DownloadsController.default_content_dsid]
        end
      end
      
      module ClassMethods
        def default_content_dsid
          "content"
        end
      end
    end
  end
end

