package   fedres.dashboard.model
{
	import flash.events.Event;
	
	public class EconomyDashboardModelEvent extends Event
	{
		public static const DISTRICT_CHANGED : String = 'districtChanged' ; 
		public static const CURRENT_DATE_CHANGED : String = 'currentDateChanged'; 
		public static const DASHBOARD_SERIES_CHANGED : String = 'datesChanged' ; 		
		public static const HIGHLIGHT_CERTAIN_ITEMS_SELECTED : String = 'highlightItemSelected' ; 
		
		public static const NAME_CHANGED : String = 'nameChanged' ; 
		public static const CUSTOM_BOARD_CHANGED : String = 'customBoardChanged' ; 
		
		/**
		 * When in add mode, and user clicks board, make row for them and add 
		 * compponent for the sake of simplicity
		 * */
		public static const CLICKED_BOARD : String = 'clickedBoard' ; 
		
		
		public var data: Object;
		
		public function EconomyDashboardModelEvent(type:String, _data:Object = null)
		{
			super(type);
			data = _data;
		}
	
	}
}