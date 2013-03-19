require 'rubygems'
require 'sinatra'
require 'json'
require 'omniauth'
require 'omniauth-github'
require 'omniauth-facebook'
require 'omniauth-twitter'
require 'sequel'
require 'pg'
require 'pry'

class SinatraApp < Sinatra::Base

  DB = Sequel.connect(ENV['DATABASE_URL'])

  configure do
    set :sessions, true
    set :inline_templates, true
  end

  use OmniAuth::Builder do
    provider :github, 'ece9da5a3cff23b3475f','eb81c6098ba5d08e3c2dbd263bf11de5f3382d55'
    provider :facebook, '290594154312564','a26bcf9d7e254db82566f31c9d72c94e'
    provider :twitter, 'cO23zABqRXQpkmAXa8MRw', 'TwtroETQ6sEDWW8HEgt0CUWxTavwFcMgAwqHdb0k1M'
  end

  get '/' do
    erb "
    <a href='/auth/github'>Login with Github</a><br>
    <a href='/auth/facebook'>Login with facebook</a><br>
    <a href='/auth/twitter'>Login with twitter</a><br>"
    ## <a href='/auth/att-foundry'>Login with att-foundry</a>"
  end

  get '/data/boligtyper' do
    content_type :json
    DB[:bolig_type].to_a.to_json
  end

  get '/data/historikk/type/:housing_type/omrade/:housing_area' do
    binding.pry
  end

  get '/auth/:provider/callback' do
    session[:authenticated] = true
    session[:omniauth] =  request.env['omniauth.auth']
    erb "<h1>#{params[:provider]}</h1>
         <pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>"
  end

  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
  end

  get '/auth/:provider/deauthorized' do
    erb "#{params[:provider]} has deauthorized this app."
  end

  get '/protected' do
    throw(:halt, [401, "Not authorized\n"]) unless session[:authenticated]
    binding.pry
    erb "<h1>Protected content</h1>"

    # erb "<pre>#{JSON.pretty_generate(request.env['omniauth.auth'].to_json)}</pre>"
    # erb "<pre>#{request.env['omniauth.auth'].to_json}</pre><hr>
    #      <a href='/logout'>Logout</a>"
  end

  get '/logout' do
    session[:authenticated] = false
    redirect '/'
  end

end

SinatraApp.run! if __FILE__ == $0

__END__

@@ layout
<html>
  <head>
    <link href='http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css' rel='stylesheet' />
  </head>
  <body>
    <div class='container'>
      <div class='content'>
        <%= yield %>
      </div>
    </div>
  </body>
</html>
