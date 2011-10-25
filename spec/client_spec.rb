require File.join( File.dirname(File.expand_path(__FILE__)), 'base')

describe Urtak::Api do
  
  before(:all) do
    @settings = {
      :publication_key => ENV['PUB_KEY'], 
      :api_key         => ENV['API_KEY'],
      :api_base        => ENV['API_BASE'],
    }
  end

  it "should set up an API Client when given valid settings" do
    expect { Urtak::Api.new(@settings) }.to_not raise_error
  end

  it "should form http requests with proper accept headers"
  it "should form http post requests with a proper content type"
  it "should sign requests properly"

  context "accounts" do
    it "should create an account"
    it "should find your account"
  end

  context "publications" do
    it "should find a publication" do
      VCR.use_cassette('get_publication', :match_requests_on => [:method, :host, :path]) do
        @client = Urtak::Api.new(@settings)
        response = @client.get_publication(@settings[:publication_key])
        response.class.should eq(Urtak::Response)
        response.code.should eq(200)
      end
    end

    it "should create a publication" do
      VCR.use_cassette('create_publication') do
        @client = Urtak::Api.new(@settings)
        publication = {
          :name     => "Fun with VCRs",
          :domains  => "knossos.local"
        }
        response = @client.create_publication(publication)
        response.code.should eq(201)
      end
    end

    it "should update a publication" do
      VCR.use_cassette('update_publication') do
        @client = Urtak::Api.new(@settings)
        publication = {
          :name     => "Fun with VCRs",
          :domains  => "funwithvcrs.com"
        }
        response = @client.update_publication(@settings[:publication_key], publication)
        response.code.should eq(204)
      end
    end
  end

  context "urtaks" do
    it "should list urtaks" do
      VCR.use_cassette('list_urtaks', :match_requests_on => [:method, :host, :path]) do
        @client = Urtak::Api.new(@settings)
        response = @client.list_urtaks
        response.code.should eq(200)
        response.body['urtaks']['urtak'].class.should eq(Array)
      end
    end

    it "should create an urtak" do
      VCR.use_cassette('create_urtak') do
        @client = Urtak::Api.new(@settings)
        @post_id = Digest::SHA1.hexdigest("#{Time.now.to_i}")
        urtak = {
          :title      => "200 Fun Things to Do with Cassette Tape",
          :post_id    => @post_id,
          :permalink  => "http://knossos.local/#{@post_id}-200-fun-things-to-do-with-cassette-tape"
        }
        questions = [
          {:text => "Do you know what betamax is?"},
          {:text => "Are you familiar with physics behind magnetic storage?"},
          {:text => "Have you ever had to repair a cassette tape?"},
          {:text => "Have you ever pulled tape from a reel for fun?"}
        ]
        response = @client.create_urtak(urtak, questions)
        response.code.should eq(201)
      end
    end

    it "should find an urtak by id" do
      VCR.use_cassette('list_urtaks', :match_requests_on => [:method, :host, :path]) do
        @client = Urtak::Api.new(@settings)
        response = @client.list_urtaks
        @urtak = response.body['urtaks']['urtak'].last

        VCR.use_cassette('get_urtak_by_id', :match_requests_on => [:method, :host, :path]) do
          @client = Urtak::Api.new(@settings)
          response = @client.get_urtak(:id, @urtak['id'])
          response.code.should eq(200)
        end
      end
    end

    it "should find an urtak by permalink hash" do
      VCR.use_cassette('list_urtaks', :match_requests_on => [:method, :host, :path]) do
        @client = Urtak::Api.new(@settings)
        response = @client.list_urtaks
        @urtak = response.body['urtaks']['urtak'].last

        VCR.use_cassette('get_urtak_by_permalink', :match_requests_on => [:method, :host, :path]) do
          @client = Urtak::Api.new(@settings)
          response = @client.get_urtak(:permalink, @urtak['permalink'])
          response.code.should eq(200)
        end
      end
    end

    it "should find an urtak by post_id" do
      VCR.use_cassette('list_urtaks', :match_requests_on => [:method, :host, :path]) do
        @client = Urtak::Api.new(@settings)
        response = @client.list_urtaks
        @urtak = response.body['urtaks']['urtak'].last

        VCR.use_cassette('get_urtak_by_post_id', :match_requests_on => [:method, :host, :path]) do
          @client = Urtak::Api.new(@settings)
          response = @client.get_urtak(:post_id, @urtak['post_id'])
          response.code.should eq(200)
        end
      end
    end

    it "should update an urtak" do
      VCR.use_cassette('list_urtaks', :match_requests_on => [:method, :host, :path]) do
        @client = Urtak::Api.new(@settings)
        response = @client.list_urtaks
        @urtak = response.body['urtaks']['urtak'].last

        VCR.use_cassette('update_urtak') do
          @client = Urtak::Api.new(@settings)

          urtak = {
            :title      => "200 really fun things to do with a cassette tape",
            :post_id    => @urtak['post_id'],
            :permalink  => "http://knossos.local/#{@urtak['post_id']}-200-fun-things-to-do-with-cassette-tape"
          }

          response = @client.update_urtak(:post_id, urtak)
          response.code.should eq(204)
        end

      end
    end
  end

  context "urtak-questions" do
    before(:each) do
      VCR.use_cassette('list_urtaks', :match_requests_on => [:method, :host, :path]) do
        @client = Urtak::Api.new(@settings)
        response = @client.list_urtaks
        @urtak = response.body['urtaks']['urtak'].last
      end
    end

    it "should list questions on an urtak" do
      VCR.use_cassette('list_urtak_questions', :match_requests_on => [:method, :host, :path]) do
        @client = Urtak::Api.new(@settings)
        response = @client.list_urtak_questions(:id, @urtak['id'])
        response.code.should eq(200)
        response.body['questions']['question'].class.should eq(Array)
      end
    end

    it "should find a question on an urtak" do
      VCR.use_cassette('list_urtak_questions', :match_requests_on => [:method, :host, :path]) do
        @client = Urtak::Api.new(@settings)
        response = @client.list_urtak_questions(:id, @urtak['id'])
        @question = response.body['questions']['question'].last

        VCR.use_cassette('find_urtak_question', :match_requests_on => [:method, :host, :path]) do
          @client = Urtak::Api.new(@settings)
          response = @client.get_urtak_question(:id, @urtak['id'], @question['id'])
          response.code.should eq(200)
          response.body['question'].class.should eq(Hash)
          response.body['question']['status'].should eq("approved")
        end
      end
    end

    it "should create a question" do
      VCR.use_cassette('list_urtak_questions', :match_requests_on => [:method, :host, :path]) do
        VCR.use_cassette('create_urtak_question') do
          @client = Urtak::Api.new(@settings)
          question = {:text => "Have you ever owned a VCR?"}
          response = @client.create_urtak_question(:id, @urtak['id'], question)
          response.code.should eq(201)
          base = "#{@client.options[:api_base]}/urtaks/#{@urtak['id']}/questions"
          response.headers[:location].should =~ /#{Regexp.escape(base)}\/\d+/
        end
      end
    end

    it "should approve a question"
    it "should reject a question"
    it "should mark a question as spam"
    it "should mark a question as ham"
  end

end