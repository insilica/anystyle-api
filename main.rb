require 'rubygems'
require 'sinatra'
require "sinatra/namespace"
require "sinatra/cors"
require 'anystyle'



# CORS configs
set :allow_origin, "*"
set :allow_methods, "GET,HEAD,POST"
set :allow_headers, "content-type,if-modified-since"
set :expose_headers, "location,link"

# Endpoints
get '/' do
  "Hello world! try /api/v1/parse endpoint."
end


namespace '/api/v1' do

    get '/status' do
        status 200
        "OK"
    end

    post '/parse' do
      request.body.rewind  # in case someone already read it
      data = JSON.parse(request.body.read)

      text = data['text']
      if !text
          status 400
          "text param required!"
      else
          result = AnyStyle.parse(text)
          content_type :json
          result.to_json
      end
    end
end
