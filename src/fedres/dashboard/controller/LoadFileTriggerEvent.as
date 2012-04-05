package fedres.dashboard.controller
{
	import flash.events.Event;
	
	public class LoadFileTriggerEvent extends Event
	{
		static public  var LOAD_FILE : String = 'loadFile' 
		public var fxComplete :  Function;
		public var fxFault : Function; 
		public var file : String = '';		
		public function LoadFileTriggerEvent(type:String, file :  String , fxComplete : Function, 
											 fxFault : Function = null ) 
		{
			this.fxComplete = fxComplete; 			
			this.fxFault = fxFault; 
			this.file = file; 
			super(type, true, true);
		}
	}
}