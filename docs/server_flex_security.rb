require 'rubygems'
require 'rack'
require 'sinatra'
require "sinatra/reloader"

set :bind, 'localhost'
set :port, 7126
STDOUT.sync = true

get '/' do
	'Hello world!'
end
 

get '/crossdomain.xml' do
file = "<?xml version=\"1.0\"?>
    <!DOCTYPE cross-domain-policy SYSTEM \"http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd\">
    <cross-domain-policy>
    <allow-access-from domain=\"*\" />
    </cross-domain-policy> "
end
#getProxy
 get '/play_sound' do
	 require 'open-uri'
	 puts "ho"
	 if params['url'] != nil 
		 uri = URI.parse( params['url'])
		 uri.open {|f|
			content = f.read
			return content;
		}

		 #content= uri.read
		 return content
	end
      filename = 'evernote_eod_form.html'
      displayfile = File.open(filename, 'r')
      content = displayfile.read()
      content
end
 get '/get_url' do
	require 'open-uri'
	url = params['url'] 

	uri = URI.parse( params['url'])
	content = nil
	uri.open {|f|
		content = f.read 
	}
	return content
end
 post '/move_files' do
	puts "move files." 
	files = params['files']
	files = files.split(", "); 
	puts files.length#, files.class, params.inspect
	negate = false
	negate = true if  params['negation'] == 'true'
	folder = params['folder']
	move_to = params['move_to']
		puts negate
	opts = {}
	#opts[:encoding] = "UTF-8"
	files_in_dir = Dir.entries(folder, opts)
	skip = ['.', '..' ] 
	dirs = [] 
	#raise files.inspect
	not_found = [] ; found = [] 
	puts 'files ' + files_in_dir.length.to_s
	files_in_dir.each_with_index do | file, i | 
		 next if skip.include?(file)
		 
		 path = folder+'/'+file
		 next if File.directory?(path)
		 if negate 
			next if (files.include?(file))
				
			not_found.push( path )
		end
		if negate == false
			next if ( ! files.include?(file))
				
			found.push( path )
		end
		 #dirs.push( file) if File.directory?(path)
	end
	
	move_files=  found
	if negate 
		move_files = not_found
	end
	
	puts 'not found ' + not_found.length.to_s
	#puts files
	#~ files.each do | file |
		#~ puts file
	#~ end
	if ( ! move_to.include?('/') ) 
		move_to = folder + '/'  + move_to
	end
	require 'fileutils'
	if ( File.exists?(move_to) == false ) 
		#require 'fileutils'
		FileUtils::mkdir_p(move_to)
	end
	
	if ( File.directory?(move_to)  && File.exists?(move_to) )
	else
		raise  "Folder not found '#{move_to}'"
	end
	
	move_files.each_with_index do | file, i | 
		#make_unique_in_folder =  folder + '/' + 'ripped'
		FileUtils.mv( file, move_to ) 
	end
	return ''
end
 get '/gf' do
	folder = params['folder']
	file = params['file']
	path = folder+'/'+file
	path =  file if folder.empty?
	#return "File Not Found" if File.exists?(path) == false
	
	File.open(path, "r") do |aFile|
		contents = aFile.read
		return contents
	end
	 
    end
    
post '/sf' do
	folder = params['folder']
	file = params['file']
	#if folder is empty, try to fill it from file 
	#so we can create directory if needed
	if folder == '' 
		folder = File.path(file)
		file = File.basename(file)
	end
	#raise params.inspect + ' ' + file + ' ' + folder
	if ( File.exists?(folder)==false) 
		require 'fileutils'
		FileUtils::mkdir_p(folder)
	end
	
	contents = params['contents']
	File.open(folder+'/'+file, "w") do |aFile|
		aFile.puts contents  
	end
	return contents
end


 get '/exists' do
	folder = params['folder']
	file = params['file']
	path = folder+'/'+file
	return  File.exists?(path)  
	 
    end

 get '/delete_file' do
	folder = params['folder']
	file = params['file']
	path = folder+'/'+file
	return  File.delete(path)
	 
    end

 get '/download_file' do
	require 'open-uri'
	url = params['url'] 

	#uri = URI.parse( params['url'])
	uri = URI.parse(URI.encode( url))
	content = nil
	uri.open {|f|
		content = f.read 
	}
	folder = params['folder']
	if ( File.exists?(folder)==false) 
		require 'fileutils'
		FileUtils::mkdir_p(folder)
	end
	file = params['file']
	path = folder+'/'+file
	marker_ext = '.***'
	puts path
	if file.include?(marker_ext )
		#download file, save to hd , see type, replace market
		#deltete
		#ext = File.extname(url)
		temp_file = folder+'/'+'temp'
		File.open(temp_file, "wb") do |aFile|
			aFile.puts content 
		end		
		#get type 
		cmd = "file --mime -b \"#{folder+'/'+'temp'}\""
		#~ bb = IO.popen(cmd, "w+")
		  #~ b = bb.readlines
		  #~ puts b.join
		  output = `#{cmd}`
		  puts output
		 # raise 'fool'
		 ext = '' 
		 ext = '.jpg' if output.include?('jpeg'); 
		 ext = '.png' if output.include?('image/png'); 
		 ext = '.gif' if output.include?('image/gif'); 		 
		ext = '.mp3' if output.include?('audio/mpeg'); 	
		  file = file.gsub(marker_ext, ext)
		  File.delete(temp_file)
		  #raise [output, file, ext].join(", ")
		  #asdf.g
		path = folder+'/'+file
	end
	
	#if file exists, append a number to filename
	rename_if_used = params['rename_if_used']
	rename_if_used =  true if  rename_if_used == "true" 
	skip_if_exists = params['skip_if_exists']
	skip_if_exists=  true if  skip_if_exists == "true" 
	puts 'params' +' ' + rename_if_used.inspect + ' ' +skip_if_exists.inspect + ' ' + params['skip_if_exists']
	#puts 'skip_if_exists '  + skip_if_exists_  +  ' ' + params['skip_if_exists'].class.to_s+' ' +   path
	if skip_if_exists == true #this is not remoting true is a bad idea... 3x time this has happaned
		#becareful, as we do not know contents of file ....
		puts 'skipped file test '+ path
		return File.basename(path) if File.exists?(path)
	end
	#puts ['next...;', skip_if_exists, path].join(', ')
	
	if rename_if_used == true
	  
	  path = folder+'/'+file
	  puts 'rename if used ' 	 + path
	  count = 1
	  file2 = file
	  while File.exists?(path)
		  puts 'exists'
		  count += 1
		filename_only = File.basename(file).gsub(File.extname(file), '' ) 
	    file2 = filename_only+count.to_s+File.extname(file)
	    #puts [File.basename(file),count.to_s,File.extname(file)].inspect
	    
	    #puts 'new file name ' + file 
	    #raise file2
	    path = folder+'/'+file2
	    
	    
	    #raise 'praise ' + [File.basename(file),count.to_s,File.extname(file)].join(' ') + ' ' + path
	    #raise 'ss'
	    #asdf.g
	  end
	end
	#asdf.g
	contents = params['contents']
	File.open(path, "wb") do |aFile|
		aFile.puts content
	end
	puts 'done'
	#have to take into account the updated path's filename
	return File.basename(path)
end

get '/dd' do
	folder = params['folder']
	raise "no such folder"  if File.exists?(folder)==false
	raise "not a folder"  if File.directory?(folder)==false
	Dir.delete folder   
	return 'deleted'
end

get '/df' do
	file = params['file']
	raise "no such file"  if File.exists?(file)==false
	raise "not a file"  if File.directory?(folder) 
	File.delete file
	return 'deleted'
end


#http://localhost:7126/get_sub_dirs?folder=G%3A%2FMy%20Documents%2Fwork%2Fflex4%2FMobile2%2FRosettaStoneBuilder_Flex%2Fbin-debug%2Fassets%2Funits
 get '/get_sub_dirs' do
	   require 'json'
	folder = params['folder']
	 
	opts = {}
	#opts[:encoding] = "UTF-8"
	files = Dir.entries(folder, opts)
	skip = ['.', '..' ] 
	dirs = [] 
	#raise files.inspect
	files.each_with_index do | file, i | 
		 next if skip.include?(file)
		 path = folder+'/'+file
		 dirs.push( file) if File.directory?(path)
	 end
	 #raise dirs.inspect
	 return  dirs.to_json #JSON.parse( dirs )
  end 
	 
 
 get '/get_sub_files' do
	   require 'json'
	folder = params['folder']
	 
	opts = {}
	#opts[:encoding] = "UTF-8"
	files = Dir.entries(folder, opts)
	skip = ['.', '..' ] 
	files_output = [] 
	#raise files.inspect
	files.each_with_index do | file, i | 
		 next if skip.include?(file)
		
		 path = folder+'/'+file
		files_output.push(file)  if File.file?( path)
		# dirs.push( file) if File.directory?(path)
	 end
	 #raise dirs.inspect
	 return  files_output.to_json #JSON.parse( dirs )
  end 
	 
 #if sent the .***, fix it 
def get_new_name  current_name,new_name_target
	# file = params['file']
	new_name =  new_name_target
	marker_ext = '.***'
	if new_name_target.include?(marker_ext )
		 ext = File.extname( current_name ) 	
		  new_name  = new_name_target.gsub(marker_ext, ext)
		#path = directory+'/'+new_name
	end
	#require 'fileutils' 
	#FileUtils.mv( current_name, path )
	new_name  
end
def get_file_path   directory, filename, rename_if_duplicate
		
	  path = directory+'/'+filename
	if rename_if_duplicate
	  count = 1
	  file2 = filename
	  while File.exists?(path)
		puts 'exists'
		count += 1
		filename_only = File.basename(filename).gsub(File.extname(filename), '' ) 
		file2 = filename_only+count.to_s+File.extname(filename)
		#puts [File.basename(file),count.to_s,File.extname(file)].inspect

		#puts 'new file name ' + file 
		#raise file2
		path = directory+'/'+file2


		#raise 'praise ' + [File.basename(file),count.to_s,File.extname(file)].join(' ') + ' ' + path
		#raise 'ss'
		#asdf.g
	  end
	end
	return path
end


 get '/download_video' do
	require './curltube'
	require 'open-uri'
	url = params['url'] 
	 
	#~ uri = URI.parse( params['url'])
	#~ content = nil
	#~ uri.open {|f|
		#~ content = f.read 
	#~ }
	
	#url = 'http://www.youtube.com/watch?v=oiWWKumrLH8'
	audio_only = params['audio_only']
	folder = params['folder']
	require 'fileutils'
	if ( File.exists?(folder)==false) 
		
		FileUtils::mkdir_p(folder)
	end
	
	file = params['file']
	path = folder+'/'+file
	
	a  = DownloadVideo.new()
	 
	downloaded_file = a.convert( url,  folder )
	
	#puts 
	#puts
	puts "file....", downloaded_file.inspect
	
	make_unique_in_folder = folder
	if ( audio_only ) 
		#folder = 
		make_unique_in_folder =  folder + '/' + 'ripped'
		FileUtils.makedirs (make_unique_in_folder) if File.directory?(make_unique_in_folder) == false
		FileUtils.mv( downloaded_file, make_unique_in_folder ) 
		downloaded_file = make_unique_in_folder + '/' + File.basename(downloaded_file)
	end
	#move file to final place 
	target_filename = get_new_name( File.basename(downloaded_file), file )
	unique_path = get_file_path(make_unique_in_folder, target_filename, true)
	puts  'moving', downloaded_file, unique_path
	#move to unique name 
	FileUtils.mv( downloaded_file, unique_path )
	if ( audio_only ) 
		 #convert audio file in folder, do not move original to any folder it is in rpiped already 
		audio_rip = a.convert_audio( nil, unique_path )
		#don't need to reget name 
		#make usre usnique in folder , up directory 
		###make_audio_file_unique_in_folder = folder
		print "audio rip", audio_rip
		unique_path = get_file_path(folder, File.basename( audio_rip) , true)
		print "unique_path", unique_path
		FileUtils.mv( audio_rip, unique_path )
		downloaded_file = unique_path; 
	end
	
	return File.basename(downloaded_file )
	#~ marker_ext = '.***'
	#~ if file.include?(marker_ext )
		#~ #download file, save to hd , see type, replace market
		#~ #deltete
		#~ #ext = File.extname(url)
		#~ temp_file = folder+'/'+'temp'
		#~ File.open(temp_file, "wb") do |aFile|
			#~ aFile.puts content 
		#~ end		
		#~ #get type 
		#~ cmd = "file --mime -b \"#{folder+'/'+'temp'}\""
		#~# bb = IO.popen(cmd, "w+")
		  #~ #b = bb.readlines
		  #~ #puts b.join
		  #~ output = `#{cmd}`
		  #~ puts output
		 #~ # raise 'fool'
		 #~ ext = '' 
		 #~ ext = '.jpg' if output.include?('jpeg'); 
		 #~ ext = '.png' if output.include?('image/png'); 
		 #~ ext = '.gif' if output.include?('image/gif'); 		 
		#~ ext = '.mp3' if output.include?('audio/mpeg'); 	
		  #~ file = file.gsub(marker_ext, ext)
		  #~ File.delete(temp_file)
		  #~ #raise [output, file, ext].join(", ")
		  #~ #asdf.g
		#~ path = folder+'/'+file
	#~ end
	

	#asdf.g
	contents = params['contents']
	File.open(path, "wb") do |aFile|
		aFile.puts content
	end
	#have to take into account the updated path's filename
	return File.basename(path)
end
