class Api::V1::UrlsController < ApplicationController
  respond_to :json, :xml
  
  def expand_url
    @url = find_url
    render_content(@url)
    
    rescue UrlExpander::Error, ArgumentError => e
      render_content(e)
  end
  
  private
  
    def find_url
      raise ArgumentError.new('Unknow url') unless params[:short_url] 
      Url.find_or_create_url(params[:short_url])
    end
    
    def render_content(data)
      respond_with(data) do |format|
        format.json {render :json => data}
        format.xml  { render :xml  => data }
        format.any  { render :text => "only JSON format are supported at the moment." }
      end
    end
end
