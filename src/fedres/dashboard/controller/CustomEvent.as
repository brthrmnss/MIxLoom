package fedres.dashboard.controller
{
	import flash.events.Event;
	
	public class CustomEvent extends Event
	{
		public var data :   Object = null; 
		public function CustomEvent(type:String, data_ : Object = null, bubbles : Boolean = true )
		{
			this.data = data_; 
			super(type, bubbles, true);
		}
	}
}