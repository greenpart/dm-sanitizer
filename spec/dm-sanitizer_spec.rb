require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES

  class CleanCell
    include DataMapper::Resource

    property :id,     Serial
    property :title,  String
    property :story,  Text
  end
  CleanCell.auto_migrate!

  class DirtyCell
    include DataMapper::Resource
    disable_sanitization

    property :id,     Serial
    property :title,  String
    property :story,  Text
  end
  DirtyCell.auto_migrate!


  describe DataMapper::Model do
    it "should have options" do
      CleanCell.new.sanitization_options.should be_an_instance_of(Hash)
    end
  end

  describe DataMapper::Model, 'without sanitization' do
    before(:each) do
      @object = DirtyCell.new
    end
    
    it "should have disabling option" do
      @object.sanitization_options[:disabled].should be_true
    end
    
    it "should not sanitize before save (sanitize! should return false)" do
      @object.should_receive(:sanitize!).and_return(false)
      @object.save
    end
  end

  describe DataMapper::Model, "with sanitization" do
    before(:each) do
      @object = CleanCell.new
    end
    
    it "should call sanitize! once before save" do
      @object.should_receive(:sanitize!).with().once.and_return(true)
      @object.save
    end
    
    it "should sanitize String and Text properties by default" do
      @object.should_receive(:sanitize_property!).with(:title,anything).once.ordered
      @object.should_receive(:sanitize_property!).with(:story,anything).once.ordered
      @object.save
    end
    
    it "should not sanitize property if its exluded" do
      @object.class.sanitize :exclude => [:title]
      @object.should_not_receive(:sanitize_property!).with(:title,anything)
      @object.should_receive(:sanitize_property!).with(:story,anything).once.ordered
      @object.save
    end
    
    it "should use changed default_mode" do
      @object.class.sanitize :default_mode => :basic
      @object.should_receive(:sanitize_property!).with(:title, :basic)
      @object.should_receive(:sanitize_property!).with(:story, :basic)
      @object.save
    end
    
    it "should use changed mode" do
      @object.class.sanitize :modes => {:restricted => :title, :relaxed => :story}
      @object.should_receive(:sanitize_property!).with(:title, :restricted)
      @object.should_receive(:sanitize_property!).with(:story, :relaxed)
      @object.save
    end
    
    it "should accept array style mode setting" do
      @object.class.sanitize :modes => {:restricted => [:title, :story]}
      @object.should_receive(:sanitize_property!).with(:title, :restricted)
      @object.should_receive(:sanitize_property!).with(:story, :restricted)
      @object.save
    end
    
    it "should raise error on undefined sanitization mode" do
      lambda {
        @object.class.sanitize :modes => {:desanitizedtwice => :title}
      }.should raise_error
    end
    
    it "should not sanitize not dirty properties in not new records by default" do
      @object.should_receive(:sanitize_property!).with(:title,anything).twice
      @object.should_receive(:sanitize_property!).with(:story,anything).once
      @object.save
      @object.title = 'Really new <strong>value</strong>'
      @object.save
    end
  end
  
  describe "DataMapper::Model sanitize_property! method" do
    before(:each) do
      @object = CleanCell.new
      @object.title = '<em>hi</em>'
    end
    
    it "should call Sanitize.clean with property and mode" do
      Sanitize.should_receive(:clean).with(@object.title, @object.sanitization_options[:mode_definitions][:restricted])
      @object.sanitize_property!(:title, :restricted)
    end
    
    it "should set property to sanitized value" do
      @object.sanitize_property!(:title, :default)
      @object.title.should == Sanitize.clean(@object.title, @object.sanitization_options[:mode_definitions][:default])
    end
    
    it "should not sanitize nil properties" do
      @object.title = nil
      Sanitize.should_not_receive(:clean)
      @object.sanitize_property!(:title, :default)
      @object.title.should == nil
    end
    
    it "should not sanitize empty properties" do
      @object.title = ''
      Sanitize.should_not_receive(:clean)
      @object.sanitize_property!(:title, :default)
      @object.title.should == ''
    end
  end

end