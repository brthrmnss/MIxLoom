=begin
this script will monitor for recenetly changed files and recompile them in a script 
#write file with last time files checked
#when port called, check file 
find all files that need changes
send files in
=end
test = true
test = false
class FlexUtils
		
	require_relative "../exec_helpers.rb"
	require 'time'
	
	include ExecHelpers
	def initialize(dir=nil, filename=nil, command_only=false, test=false, include_dir=nil)
		@filename = 'last_time.txt' if filename == nil 
		@dir = 'G:\My Documents\work\flex4\test\MixingLoom_Mine\src' #params
		@dir = 'G:\work2\flex4\test\MixingLoom_Mine\src' #params		
		@dir = dir if dir != nil;
		@dir = convert_path @dir
		@output_command_only = command_only; 
		@test = test; 
		if ( include_dir.class == String )
			include_dir = [include_dir] 
		end
		@include_dirs = include_dir
		putss 'include:', @include_dirs, @include_dirs.class
		@excludes = ' -external-library-path "C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.5\sdks\4.5.1\frameworks\libs\spark.swc" -external-library-path  "c:\Program Files (x86)\Adobe\Adobe Flash Builder 4.5\sdks\4.5.1\frameworks\libs" -external-library-path  "c:\Program Files (x86)\Adobe\Adobe Flash Builder 4.5\sdks\4.5.1\frameworks\libs\mx" -external-library-path  "C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.5\sdks\4.5.1\frameworks\libs\player\10.2"'
		@excludes += ' -external-library-path "G:\My Documents\work\flex4\test\MixingLoom_Mine\src" '
		@excludes += ' -external-library-path "G:\My Documents\work\flex4\test\MixingLoom_Mine\libs\robotlegs-framework-v1.4.0.swc" '
		@excludes += ' -external-library-path "G:\My Documents\work\flex4\test\MixingLoom_Mine\libs\SwiftSuspenders-v1.5.1.swc" '
	end
	
	def update_folder files_only = false
		#check date
		#file = File.new(filename, "r")
		unless File.exists?(@filename)   
			write_file(@filename, '')
		end

		contents = read_file(@filename)
		putss 'Last Time:', contents 
		write_file(@filename, Time.now) if files_only == false
		
		begin
			last_checked_time = Time.parse(contents)
		rescue
			last_checked_time = Time.now - 5*60
		end
		#last_checked_time = Time.now - 5*60
		puts last_checked_time
		#asdf.g
		list = get_files_in_folder(@dir,true, false, [], true)

		update_files = [] 
		list.each do | filename | 
			#~ if @test #push them all
				#~ update_files.push(filename)
				#~ next
			#~ end

			#go through all directories to include and see if path matches it
			if @include_dirs != nil 
				found = false 
				#puts 'i '
				@include_dirs.each do |dir_s |
					#puts 'found', found
					next if found == true
					#putss filename.include?(dir_s+'/' ) , filename
					found = true if filename.include?(dir_s+'/' ) == true 
				end
				next if found == false 
			end
			
			
			#next
			file = File.new(filename, "r")
			#putss 'checking', file.mtime > last_checked_time, filename, file.mtime > last_checked_time
			if file.mtime > last_checked_time || @test 
				update_files.push(filename)
			end
		end
		putss 'checked ', list.length, 'files'
		files = [] 
		update_files.each do | file |
			file = file.gsub( @dir+'/', '' ) 
			file = file.gsub( "\\", '.' ) 
			file = file.gsub( "/", '.' ) 		
			#file = file.gsub( ".as$", '.' ) 		
			if ( file[-3,3] == '.as' )
				file = file[0..-4]
			elsif ( file =~ /.mxml$/  ) 
				file = file.gsub(/.mxml$/, '' )
			else
				next #skip non actionscript files
			end
			files.push(file)
			putss 'f:',file 
		end
		return '' if files.length == 0 
		return files if files_only
		classes = files.join(" ")
		#output_swc = 'G:\work2\flex4\Eval\swcs\output.swc'
		output_swc = @dir.split('/')[0..-2].join('/')
		output_swc += '/swcs/output.swc'
		compc = q 'C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.5\sdks\4.5.1\bin\compc'
		#compc = convert_path compc
		cmd = "#{compc} -source-path . #{@dir} "+
		"-output #{output_swc} -include-classes #{classes} "+
		@excludes
		cmd = cmd.gsub("\\", '\\\\')
		putss 'count', update_files.length
		puts 'command', cmd, 'output_command_only:', @output_command_only.class
		return cmd if @output_command_only
		#asdf.gd
		output = system(cmd)
		puts 'command output:',output
		return output_swc
	end
end

utils = FlexUtils.new()
if test 
	utils.update_folder
end

require 'rubygems'
require 'rack'
require 'sinatra'
require "sinatra/reloader"

set :bind, 'localhost'
set :port, 9001
STDOUT.sync = true
include ExecHelpers

	get '/crossdomain.xml' do
		file = "<?xml version=\"1.0\"?>
			<!DOCTYPE cross-domain-policy SYSTEM \"http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd\">
			<cross-domain-policy>
			<allow-access-from domain=\"*\" />
			</cross-domain-policy> "
	end
	#http://http://localhost:9001/update_dir?command_only=true&test=true
	get '/update_dir' do
	 #return ''
		dir = params['dir']
		include_dirs = params['include_dirs']
		require 'json'
		include_dirs = JSON.parse( include_dirs )
		include_dirs.each do | x | 
			x.gsub!('.', '/' )
		end
		#puts include_dirs
		#puts include_dirs.class
		#asdf.g
		#puts q 'yo'
		command_only = params_tf( params['command_only'] )
		test = params_tf params['test']
		test = true if params['test'] == nil 
		putss 'test?', test 
		files_only = params_tf params['files_only']
		
		
		
		#test = false
		#putss 'cm', command_only,  params['command_only']
		puts command_only
		utils = FlexUtils.new(dir, nil, command_only, test,include_dirs)
		if files_only 
			files = utils.update_folder( true)
			return files.to_json
		end
		filename = utils.update_folder 
		return "" if filename == ''
		if command_only 
			return filename 
		end
		file = File.open(filename, 'r')
		return "" if file.mtime < (Time.now() -1*60)
			
		content = file.read()
		#content_type 'application/octet-stream'
		content
		send_file(filename, :filename =>filename, :type => "application/octet-stream")
		#return 'g'
	end
	
	
 