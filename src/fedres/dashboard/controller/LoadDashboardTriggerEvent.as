package  fedres.dashboard.controller
{
	import flash.events.Event;
	
	public class LoadDashboardTriggerEvent extends Event
	{
		static public  var LOAD_FILE : String = 'loadFile' 
		static public  var LOAD_ARRAY : String = 'loadArray' 			
		public var fxComplete :  Function;
		public var fxFault : Function; 
		public var file : String = '';		
		public var array : Array ; 
		public function LoadDashboardTriggerEvent(type:String, file :  String , fxComplete : Function=null, 
											 fxFault : Function = null, array : Array = null ) 
		{
			this.fxComplete = fxComplete; 			
			this.fxFault = fxFault; 
			this.file = file; 
			this.array = array; 
			super(type, true, true);
		}
	}
}