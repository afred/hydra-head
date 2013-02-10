require 'spec_helper'

describe DownloadsController do

  before(:all) do
    @f = ActiveFedora::Base.new
    @f.set_title_and_label('world.txt')
    @.add_file_datastream('foobar', :dsid=>'content', :mimeType => 'image/png')
    @.save
  end

  after(:all) do
    @f.destroy
  end

  describe "routing" do
    it "should route" do
      assert_recognizes( {:controller=>"downloads", :action=>"show", "id"=>"test1"}, "/downloads/test1?filename=my%20dog.jpg" )
    end
  end

  describe "when logged in as reader" do
    before do
      sign_in FactoryGirl.find_or_create(:archivist)
      User.any_instance.stub(:groups).and_return([])
    end
    after do
      arch = FactoryGirl.find(:archivist) rescue
      arch.delete if arch
    end
    describe "show" do
      it "should default to returning configured default download" do
        DownloadsController.default_content_dsid.should == "content"
        controller.should_receive(:send_data).with('foobar', {:filename => 'world.png', :disposition => 'inline', :type => 'image/png' })
        get "show", :id => "test1"
        response.should be_success
      end
      it "should return requested datastreams" do
        controller.should_receive(:send_data).with('desc content', {:filename => 'descMetadata', :disposition => 'inline', :type => "text/plain"})
        get "show", :id => @f.pid, :datastream_id => "descMetadata"
        response.should be_success
      end
      it "should support setting disposition to inline" do
        controller.should_receive(:send_data).with('foobar', {:filename => 'world.png', :type => 'image/png', :disposition => "inline"})
        get "show", :id => "test1", :disposition => "inline"
        response.should be_success
      end
      it "should allow you to specify filename for download" do
        controller.should_receive(:send_data).with('foobar', {:filename => "my%20dog.png", :disposition => 'inline', :type => 'image/png'}) 
        get "show", :id => "test1", "filename" => "my%20dog.png"
      end
    end
  end

  describe "when not logged in as reader" do
    before do
      sign_in FactoryGirl.find_or_create(:user)
      User.any_instance.stub(:groups).and_return([])
    end
    after do
      user = FactoryGirl.find(:user) rescue
      user.delete if user
    end
    
    describe "show" do
      it "should deny access" do
        get "show", :id =>@f.pid 
        response.should redirect_to("/assets/NoAccess.png")
      end
    end
  end
end
