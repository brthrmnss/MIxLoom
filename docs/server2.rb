require 'rubygems'
require 'rack'
require 'sinatra'

set :bind, 'localhost'
set :port, 7125


get '/' do
  'Hello world!'
end


get '/evernote_eod_form.html' do
      filename = 'evernote_eod_form.html'
      displayfile = File.open(filename, 'r')
      content = displayfile.read()
      content
end

post '/submit.html' do
      "#{params['user']}"
  filename = 'evernote_end_of_day.rb'; 
        #  x = system("ruby #{filename} #{input}")
        mycontents = IO.read(filename); 
         input = params['user']
         input = input.gsub("\r", '' )        
        result = eval mycontents 
        result = result.gsub("\n", '<br />' )
        result = result.gsub("\r", '' ) 
                result = result.gsub('\r', '' )     
         '<html>bbbbbbbbbbb'+result+'</html>';      
end