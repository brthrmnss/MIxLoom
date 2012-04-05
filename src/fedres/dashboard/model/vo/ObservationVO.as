package   fedres.dashboard.model.vo
{
	import flash.events.EventDispatcher;
	
	import mx.controls.DateField;
	
	public class ObservationVO  extends  EventDispatcher
	{
		public function ObservationVO()
		{
			
		}
		public var id : String = ''; 
		[Bindable] public var text : String = ''; 
		[Bindable] public var number : int = 0; 
		[Bindable] public var quote : String = ''; 
		public var name :  String = ''; 
		
		
		private var _dateString : String = ''; 
		private var _date : Date = new Date()
		
		
		public var value :   Number ; 
		public function get date ()  : Date
		{
			return this._date; 
		}
		
		public function get dateString ()  : String
		{
			return this._dateString; 
		}		
		public function set setDateString ( dateS : String )  : void
		{
			this._date = DateField.stringToDate( dateS, ObservationVO.dateFormat )
			//this.setDate = this.date; 
			this._dateString = DateField.dateToString( this._date, ObservationVO.dateFormat )
		}			
		static public var dateFormat : String = 'YYYY-MM-DD'
		
	}
}