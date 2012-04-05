require 'socket'
#~ webserver = TCPServer.new('127.0.0.1',7125)
#~ while (session = webserver.accept)
   #~ session.print "HTTP/1.1 200/OK\r\nContent-type:text/html\r\n\r\n"
   #~ puts session
   #~ request = session.gets
   #~ puts request
   
   #~ trimmedrequest = request.gsub(/GET\ \//, '').gsub(/\ HTTP.*/, '')
   #~ filename = trimmedrequest.chomp
   #~ if filename == ""
      #~ filename = "index.html"
   #~ end
   #~ begin
      #~ displayfile = File.open(filename, 'r')
      #~ content = displayfile.read()
      #~ session.print content
   #~ rescue Errno::ENOENT
      #~ session.print "File not found"
   #~ end
   #~ session.close
#~ end

require 'socket'                # Get sockets from stdlib
#puts 'go'
 server = TCPServer.new('127.0.0.1', 7125)   # Socket to listen on port 2000
 loop {                          # Servers run forever
  #Thread.start(server.accept) do |client|
  client = server.accept      
   # puts 'yes ' 
     puts client
   # client.puts(Time.now.ctime) # Send the time to the client
    request = client.gets
   #  puts client.gets
    filename = ''
     # puts 'ho4 + '  + request.inspect
    if request != nil
      #puts 'ho'
      #puts 'trimmed '  + request.gsub(/GET\ \//, '')
    trimmedrequest = request.gsub(/GET\ \//, '').gsub(/\ HTTP.*/, '')
    filename = trimmedrequest.chomp
  end
   # puts 'hdo'
   puts 'file name ' + filename.inspect
   if filename == ""
      filename = "index.html"
    end
    if filename.include?('submit.html')
        puts 'submit.html'
        puts request
         
        puts = 'post: '  + client.get_data
        data = filename.split('user=')[1]
        #require 'cgi'
        #data = CGI.unescapeHTML(data)

        require 'htmlentities'
        coder = HTMLEntities.new         
        data = coder.decode(data) # => "élan"
        data = data.replace('+', ' ')
        puts data;
        return
        input = data
        
        #system("ruby #{evernote_end_of_day.rb}")
        filename = 'evernote_end_of_day.rb'; 
        #  x = system("ruby #{filename} #{input}")
        mycontents = IO.read(filename); 
        result = eval mycontents 
        
        client.print '<html>'+result+'</html>';
        client.close     
        next
    end
   begin
      displayfile = File.open(filename, 'r')
      content = displayfile.read()
      client.puts content
   rescue Errno::ENOENT
     
      client.print "File not found"
   end    
	#client.puts "Closing the connection. Bye!"
    client.close                # Disconnect from the client
  #end
}
puts 'done'