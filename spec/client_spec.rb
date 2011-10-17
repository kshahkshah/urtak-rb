require File.join( File.dirname(File.expand_path(__FILE__)), 'base')

describe Urtak::Api do

  it "should set up an API Client when given valid settings" do
    settings = {
      :publication_key => "670af63c794ed3475b43c3f7945c1b08", 
      :api_key         => "fc84ad2e81928c5f045c0cea92e4f1a9444611a0"
    }

    expect { Urtak::Api.new(settings) }.to_not raise_error
  end

  context "accounts" do
    it "should create an account"
    it "should find your account"
  end

  context "publications" do
    it "should find a publication" do
      settings = {
        :publication_key => "670af63c794ed3475b43c3f7945c1b08", 
        :api_key         => "fc84ad2e81928c5f045c0cea92e4f1a9444611a0"
      }

      @urtak = Urtak::Api.new(settings)

      expect { @urtak.get_publication(settings[:publication_key]) }.to_not raise_error
    end

    it "should create a publication"
    it "should update a publication"
  end

  context "urtaks" do
    it "should list urtaks"
    it "should find an urtak"
    it "should create an urtak"
    it "should update an urtak"
  end

  context "urtak-questions" do
    it "should list questions on an urtak"
    it "should find a question on an urtak"
    it "should create a question"
    it "should approve a question"
    it "should reject a question"
    it "should mark a question as spam"
    it "should mark a question as ham"
  end

end