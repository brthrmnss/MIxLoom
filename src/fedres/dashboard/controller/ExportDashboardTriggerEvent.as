package  fedres.dashboard.controller
{
	import flash.events.Event;
	
	public class ExportDashboardTriggerEvent extends Event
	{
		static public  var EXPORT_DASHBOARD : String = 'exportDashboard' 
		public var fxComplete :  Function;
		public var fxFault : Function; 
		public var result : Array = []; 
		public function ExportDashboardTriggerEvent(type:String,  fxComplete : Function=null, 
											 fxFault : Function = null ) 
		{
			this.fxComplete = fxComplete; 			
			this.fxFault = fxFault; 
			super(type, true, true);
		}
	}
}