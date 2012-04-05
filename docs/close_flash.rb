# To change this template, choose Tools | Templates
# and open the template in the editor.



class CloseTasks
  #@tasks @task_list @task_to_PID
  def initialize trace = false
	@tasks = ''
      @task_to_PID = {}
      @task_list  = []
      @trace = trace
      puts "CloseTasks"
  end
  
  def get_task_list
      @tasks = run_cmd 'tasklist /NH /fo CSV'
      #task_list
      @pids = []
      @task_list  = []
      array_tasks = @tasks.split("\n")
      #puts 'length ' +array_tasks.length.to_s #@tasks.inspect
      #asd.g
      array_tasks.each do | x |
		name_split = x.split('","')
		name = name_split[0]
		name.slice!(0)
		pid = name_split[1] 
		if @trace 
			#puts 'Tasks & PID'
			puts  name + ' ' + pid  
		end
		@task_list.push( name )
		@pids.push( pid )
		
	end

  end

	#kills process for given id
  def kill_process pid
      #result = run_cmd 'tskill ' + pid
      result = run_cmd "taskkill /f /PID #{pid}" 
  end

  def display_tasks 
	@task_list.each do | task |
			puts task
	end
  end

  #tries to close all instances of task_name
  def close_process task_name  
	get_task_list
	
	#return if ! @task_list.includes?(task_name)
	#puts task_name 
	#return
	#get task list and try to close each by PID
	@task_list.each_with_index do | task, i |
		#puts "compared #{task} == #{task_name}" #if @trace
		if task == task_name
			#puts "compared #{task} == #{task_name}" #if @trace
			kill_process(@pids[i]) 
			puts "killed #{task} #{@pids[i]}"
		end
	end
  end

  #tries to close all instances of task_name
  def close_processes_by_name names  
	names.each do  | name | 
		close_process( name )  
	end
  end


  def run_cmd cmd 

      cmd2 =  "#{cmd} "
      puts 'command' + ' ' + cmd2  if  @trace
      hostname = `#{cmd2}`.chomp

      puts  'host name 1 ' +  hostname if @trace
 

      hostname
  end

end
g = CloseTasks.new
#g.get_task_list
#g.display_tasks
g.close_process 'adl.exe'
g.close_process 'FlexSimulator.exe'
g.close_processes_by_name [ 'flashplayer_10_sa_debug.e', 
'flashplayer_10_sa_debug.exe', 'FlashPlayer.exe', 'FlashPlayerDebugger.exe' , 
'flashplayer_11_sa_debug_32bit.exe', '_flashplayer_10_sa_debug.exe']
g.close_process 'PicasaPhotoViewer.exe'
g.close_process 'taskmgr.exe'

puts 'complete closed X tasks'






