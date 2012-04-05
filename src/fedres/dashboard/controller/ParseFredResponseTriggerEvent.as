package fedres.dashboard.controller
{
	import flash.events.Event;
	
	public class ParseFredResponseTriggerEvent extends Event
	{
		static public  var PARSE_FRED_SERIES : String = 'parseFredResponse' 
		static public  var PARSE_FRED_SERIES_ARRAY : String = 'parseFredSeriesArray' 			
		
		public var xml :  XML;
		public var fxComplete :  Function;
		public var prependParameters :  Array; 
		
		public function ParseFredResponseTriggerEvent(type:String, xml :  XML , 
													  fxComplete : Function, 
													  prependParameters :  Array = null ) 
		{
			this.xml = xml; 			
			this.fxComplete = fxComplete; 
			this.prependParameters = prependParameters; 
			super(type, true, true);
		}
	}
}