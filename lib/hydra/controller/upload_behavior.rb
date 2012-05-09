module Hydra::Controller::UploadBehavior
  
  # Creates a File Asset, adding the posted blob to the File Asset's datastreams and saves the File Asset
  #
  # @return [FileAsset] the File Asset  
  def create_and_save_file_assets_from_params
    if params.has_key?(:Filedata)
      @file_assets = []
      params[:Filedata].each do |file|
        @file_asset = create_asset_from_file(file)
        add_posted_blob_to_asset(@file_asset,file)
        @file_asset.save
        @file_assets << @file_asset
      end
      return @file_assets
    else
      render :text => "400 Bad Request", :status => 400
    end
  end
  
  # Puts the contents of params[:Filedata] (posted blob) into a datastream within the given @asset
  # Sets asset label and title to filename if they're empty
  #
  # @param [FileAsset] the File Asset to add the blob to
  # @return [FileAsset] the File Asset  
  def add_posted_blob_to_asset(asset,file)
    #file_name = filename_from_params
    file_name = file.original_filename
    options = {:label=>file_name, :mimeType=>mime_type(file_name)}
    dsid = datastream_id #Only call this once so that it could be a sequence
    options[:dsid] = dsid if dsid
    asset.add_file_datastream(file, options)
    asset.set_title_and_label( file_name, :only_if_blank=>true )
  end

  #Override this if you want to specify the datastream_id (dsID) for the created blob
  def datastream_id
    "content"
  end
  
  # Associate the new file asset with its container
  def associate_file_asset_with_container(file_asset=nil, container_id=nil)
    if container_id.nil?
      container_id = params[:asset_id]
    end
    if file_asset.nil?
      file_asset = @file_asset
    end
    file_asset.add_relationship(:is_part_of, container_id)
    file_asset.datastreams["RELS-EXT"].dirty = true
    file_asset.save
  end
  
  # Apply any posted file metadata to the file asset
  def apply_posted_file_metadata         
    @metadata_update_response = update_document(@file_asset, @sanitized_params)
    @file_asset.save
  end
  
  
  # The posted File 
  # @return [File] the posted file.  Defaults to nil if no file was posted.
  def posted_file
    params[:Filedata]
  end
  
  # A best-guess filename based on POST params
  # If Filename was submitted, it uses that.  Otherwise, it calls +original_filename+ on the posted file
  def filename_from_params
    if !params[:Filename].nil?
      file_name = params[:Filename]      
    else
      file_name = posted_file.original_filename
      params[:Filename] = file_name
    end
  end

  # Creates a File Asset and sets its label from params[:Filename]
  #
  # @return [FileAsset] the File Asset
  def create_asset_from_params    
    file_asset = FileAsset.new
    file_asset.label = params[:Filename]
    
    return file_asset
  end
  
  # Creates a File Asset and sets its label from filename
  #
  # @return [FileAsset] the File Asset
  def create_asset_from_file(file)
    file_asset = FileAsset.new
    file_asset.label = file.original_filename

    return file_asset
  end
  
  
  # This is pre-Hydra code that created an AudioAsset, VideoAsset or ImageAsset based on the
  # current params in the controller.
  #
  # @return [Constant] the recommended Asset class 
  def asset_class_from_params
    if params.has_key?(:type)
      chosen_type = case params[:type]
      when "AudioAsset"
        AudioAsset
      when "VideoAsset"
        VideoAsset
      when "ImageAsset"
        ImageAsset
      else
        FileAsset
      end
    elsif params.has_key?(:Filename)
      chosen_type = choose_model_by_filename( params[:Filename] )
    else
      chosen_type = FileAsset
    end
    
    return chosen_type
  end
  
  def choose_model_by_filename(filename)
    choose_model_by_filename_extension( File.extname(filename) )
  end
  

  private
  # Return the mimeType for a given file name
  # @param [String] file_name The filename to use to get the mimeType
  # @return [String] mimeType for filename passed in. Default: application/octet-stream if mimeType cannot be determined
  def mime_type file_name
    mime_types = MIME::Types.of(file_name)
    mime_type = mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
  end
  
end
