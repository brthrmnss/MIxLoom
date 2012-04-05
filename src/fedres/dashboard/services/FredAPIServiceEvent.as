package   fedres.dashboard.services
{
	import flash.events.Event;
	
	public class FredAPIServiceEvent extends Event
	{
		public static const NAME_CHANGED : String = 'nameChanged' ; 
		public static const CUSTOM_BOARD_CHANGED : String = 'customBoardChanged' ; 
		
		/**
		 * When in add mode, and user clicks board, make row for them and add 
		 * compponent for the sake of simplicity
		 * */
		public static const CLICKED_BOARD : String = 'clickedBoard' ; 
		
		
		public var data: Object;
		
		public function FredAPIServiceEvent(type:String, _data:Object = null)
		{
			super(type);
			data = _data;
		}
	
	}
}