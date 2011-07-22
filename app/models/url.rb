require 'digest/md5'

class Url
  include Mongoid::Document
  include Mongoid::Timestamps # adds automagic fields created_at, updated_at
  
  field :short_url, type:  String
  field :long_url, type:  String
  
  field :host, type:  String
  field :expand_count, type:  Integer, :default => 1
  
  index :short_url, unique: true, background: true
  
  def as_json(options={})
    super(:only => [:short_url, :long_url, :expand_count])
  end
  
  def to_xml(options={})
    super(:only => [:short_url, :long_url, :expand_count])
  end
  
  # Class functions
  class << self
    def find_or_create_url(short_url)
      # Remove trailing slash if it exists
      short_url.sub!(/(\/)+$/,'')
    
      url = Url.first(conditions: { short_url: short_url })
    
      # Ok, we don't have this url
      if(url.nil?)
        # Check the cache for invalid urls before trying to expand it.
        if Url.read_from_cache(short_url).nil?
          begin
            long_url = UrlExpander::Client.expand(short_url)
            url = Url.create(:short_url => short_url, :long_url => long_url, :host => URI.parse(short_url).host)
        
          # If Urlexpader was unable to expand the url:
          # => Cache the error
          # => Reraise the exception
          rescue UrlExpander::Error, ArgumentError => e
            Url.write_to_cache(short_url)
            raise e
          end
        else
          raise ArgumentError.new('Unknow url') 
        end
      else
        # increment the expand count
        url.inc(:expand_count, 1)
      end
      url
    end
  
    # Check if we have an invalid url in cache.
    def read_from_cache(url)
      domain_digest = Digest::MD5.hexdigest(url)
      Rails.cache.read(domain_digest)
    end
  
    # Write an invalid url to cache.
    def write_to_cache(url)
      domain_digest = Digest::MD5.hexdigest(url)
      Rails.cache.write(domain_digest, false)
    end
  end
end