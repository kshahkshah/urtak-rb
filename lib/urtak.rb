require 'urtak/version'
require 'rest_client'
require 'digest/sha1'

# XML is supported by the API, but this wrapper does not parse it automatically!
require 'json'

module Urtak
  module Errors
    class Unimplemented < StandardError ; end
    class NoToken < StandardError ; end
  end
  
  class Api
    attr_accessor :options
    
    def initialize(user_options = {})
      @options = {
        :api_key          => nil,
        :publication_key  => nil,
        :email            => nil,
        :user_id          => nil,
        :api_base         => "https://urtak.com/api",
        :api_format       => "JSON",
        :client_name      => "Urtak API Wrapper for Ruby, v#{Urtak::VERSION}"
      }.merge(user_options)
      
      raise Urtak::Errors::NoApiKey if options[:api_key].empty?
    end
    
    # ACCOUNTS
    def get_account(id)
      Response.new(fire(:get, "accounts/#{id}"))
    end
    
    def create_account(attributes)
      Response.new(fire(:post, "accounts", {:account => attributes}))
    end
    
    # PUBLICATIONS
    def get_publication(key = options[:publication_key])
      Response.new(fire(:get, "publications/#{key}"))
    end
    
    def create_publication(attributes)
      Response.new(fire(:post, "publications", {:publication => attributes}))
    end
    
    def update_publication(key, attributes)
      Response.new(fire(:put, "publications/#{key}", {:publication => attributes}))
    end
    
    # URTAKS
    def list_urtaks(options = {})
      Response.new(fire(:get, "urtaks", options))
    end

    def get_urtak(property, value, options = {})
      if property == :id
        path = "urtaks/#{value}"
      elsif property == :post_id
        path = "urtaks/post/#{value}"
      elsif property == :permalink
        path = "urtaks/permalink/#{value}"
      end
      
      Response.new(fire(:get, path, options))
    end
    
    def create_urtak(urtak_attributes, questions=[])
      Response.new(fire(:post, 'urtaks', {:urtak => urtak_attributes.merge(:questions => questions)}))
    end
    
    def update_urtak(property, attributes)
      value = attributes.delete(property)
      
      if property == :id
        path = "urtaks/#{value}"
      elsif property == :post_id
        path = "urtaks/post/#{value}"
      elsif property == :permalink
        path = "urtaks/permalink/#{value}"
      end
      
      Response.new(fire(:put, path, {:urtak => attributes}))
    end
    
    # URTAK QUESTIONS
    def list_urtak_questions(property, value, options = {})
      if property == :id
        path = "urtaks/#{value}/questions"
      elsif property == :post_id
        path = "urtaks/post/#{value}/questions"
      elsif property == :permalink
        path = "urtaks/permalink/#{value}/questions"
      end
      
      Response.new(fire(:get, path, options))
    end
    
    def get_urtak_question(property, value, id, options = {})
      if property == :id
        path = "urtaks/#{value}/questions/#{id}"
      elsif property == :post_id
        path = "urtaks/post/#{value}/questions/#{id}"
      elsif property == :permalink
        path = "urtaks/permalink/#{value}/questions/#{id}"
      end

      Response.new(fire(:get, path, options))
    end
    
    def create_urtak_questions(property, value, questions)
      if property == :id
        path = "urtaks/#{value}/questions"
      elsif property == :post_id
        path = "urtaks/post/#{value}/questions"
      elsif property == :permalink
        path = "urtaks/permalink/#{value}/questions"
      end

      Response.new(fire(:post, path, {:questions => questions}))
    end
    
    def approve_urtak_question(property, value, id)
      if property == :id
        path = "urtaks/#{value}/questions/#{id}/approve"
      elsif property == :post_id
        path = "urtaks/post/#{value}/questions/#{id}/approve"
      elsif property == :permalink
        path = "urtaks/permalink/#{value}/questions/#{id}/approve"
      end

      Response.new(fire(:put, path))
    end
    
    def reject_urtak_question(property, value, id)
      if property == :id
        path = "urtaks/#{value}/questions/#{id}/reject"
      elsif property == :post_id
        path = "urtaks/post/#{value}/questions/#{id}/reject"
      elsif property == :permalink
        path = "urtaks/permalink/#{value}/questions/#{id}/reject"
      end

      Response.new(fire(:put, path))
    end
    
    def spam_urtak_question(property, value, id)
      if property == :id
        path = "urtaks/#{value}/questions/#{id}/spam"
      elsif property == :post_id
        path = "urtaks/post/#{value}/questions/#{id}/spam"
      elsif property == :permalink
        path = "urtaks/permalink/#{value}/questions/#{id}/spam"
      end

      Response.new(fire(:put, path))
    end
    
    def ham_urtak_question(property, value, id)
      if property == :id
        path = "urtaks/#{value}/questions/#{id}/ham"
      elsif property == :post_id
        path = "urtaks/post/#{value}/questions/#{id}/ham"
      elsif property == :permalink
        path = "urtaks/permalink/#{value}/questions/#{id}/ham"
      end

      Response.new(fire(:put, path))
    end
    
    private
    def fire(method, path, data={})
      if method == :get
        RestClient.get "#{options[:api_base]}/#{path}", 
          "User-Agent" => options[:client_name],
          :params => retrieve_token.merge(data).merge(create_signature), 
          :accept => create_accept
      elsif method == :head
        RestClient.head "#{options[:api_base]}/#{path}", 
          "User-Agent" => options[:client_name],
          :params => retrieve_token.merge(data).merge(create_signature), 
          :accept => create_accept
      elsif method == :post
        RestClient.post "#{options[:api_base]}/#{path}", 
          JSON.generate(retrieve_token.merge(data).merge(create_signature)),
          "User-Agent" => options[:client_name],
          :accept => create_accept, 
          :content_type => :json
      elsif method == :put
        RestClient.put "#{options[:api_base]}/#{path}", 
          JSON.generate(retrieve_token.merge(data).merge(create_signature)),
          "User-Agent" => options[:client_name],
          :accept => create_accept, 
          :content_type => :json
      end
    end
    
    def retrieve_token
      {:publication_key => options[:publication_key]}
    end
    
    def create_signature
      timestamp = Time.now.to_i
      signature = Digest::SHA1.hexdigest("#{timestamp} #{options[:api_key]}")
      {:timestamp => timestamp, :signature => signature}
    end
    
    def create_accept
      if options[:api_format] == "JSON"
        "application/vnd.urtak.urtak+json; version=1.0"
      else
        "application/vnd.urtak.urtak+xml; version=1.0"
      end
    end
  end

  class Response
    attr_accessor :raw, :body
    
    def initialize(response)
      @raw = response

      if response.headers[:content_type].nil?
        @body = response
      elsif response.headers[:content_type].match(/json/)
        @body = JSON.parse(response)
      elsif response.headers[:content_type].match(/xml/)
        raise Urtak::Errors::Unimplemented
      end
    end
    
    def code
      raw.code
    end

    def error
      response.body['error'] ? response.body['error']['message'] : nil
    end
    
    def headers
      raw.headers
    end

    def success?
      code >= 200 && code < 400
    end
    
    def failure?
      code >= 400
    end
    
    def not_found?
      code == 404
    end

    # naive
    def found?
      code == 200 || code == 304
    end
    
  end
end
