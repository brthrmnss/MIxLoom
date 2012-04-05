package  fedres.dashboard.controller
{
	import flash.events.Event;
	
	public class TestCommand1TriggerEvent extends Event
	{
		static public  var LOAD_FILE : String = 'loadFileX' 
		static public  var LOAD_FILE2 : String = 'loadFileXs' 
		public var fxComplete :  Function; 
		public var fxFault : Function;   
		public var file : String = '';		   
		public static var LOAD_FILE3:String = 'loadFileXs3' ;
		public static var LOAD_FILE4:String = 'loadFileXs4' ;
		 public static var LOAD_FILE5:String = 'loadFileXs5' ;
		 public static var LOAD_FILE6:String = 'loadFileXs6' ;
		public function TestCommand1TriggerEvent(type:String='', file :  String='' , fxComplete : Function=null, 
											 fxFault : Function = null ) 
		{ 
			this.fxComplete = fxComplete; 		 	
			this.fxFault = fxFault; 
			this.file = file;   
			super(type, true, true);
		}
	}
}