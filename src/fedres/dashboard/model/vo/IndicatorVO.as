package  fedres.dashboard.model.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class IndicatorVO  extends EventDispatcher
	{
		static public var INDICATOR_UPDATED : String = 'indicatorUpdated' 
		public var id : String = ''; 
		[Bindable] public var text : String = ''; 
		[Bindable] public var number : int = 0; 
		[Bindable] public var quote : String = ''; 
		public var name :  String = ''; 
		public var notes  :  String = ''; 
		public var desc :  String = '';
		
		public var series_id :  String = ''; 
		
		public var data : Object; 
		
		public var hi : Number = 0; 
		public var lo : Number = 0; 
		public var hiObservation : ObservationVO = new ObservationVO; 
		public var loObservation : ObservationVO = new ObservationVO; 
		public var currentObservation : ObservationVO = new ObservationVO; 		
		
		public var typicalLo : Number = 0; 
		public var typicalHi : Number = 0; 		
		public var typicalLoObservation : ObservationVO = new ObservationVO; 
		public var typicalHiObservation : ObservationVO = new ObservationVO; 		
		
		public  var currentValue : Number  =0; 
		
		public function setup( name_ :  String, desc_ :  String, 
							   lo_ : Number, hi_ : Number, currentValue_ : Number, 
							   data_ :  Object,
							   typicalLo_ : Number, typicalHi_ : Number) : void
		{
			this.name = name_
			this.desc = desc_
			this.hi = hi_
			this.lo = lo_
			this.currentValue = currentValue_
			this.data= data_	
			this.typicalHi = typicalHi_
			this.typicalLo = typicalLo_				
		}
			
		public function get range ()  : Number
		{
			return this.hi - lo 
		}
		
		public var lastYears: Array; 
		public var allDataPoints : Array = []; 
		
		public var threeMonthTrendPositive : Boolean = false; 
		//pubilc var 
		
		public var ranges : Array = []; 
		[Bindable] public var multipler :  Number = 0 ; 
		public var rationale :  String = ''; 
		public var score : String = ''; 
		
		
		public var whatIsIt : String = ''; 
		
		public function updated() : void
		{
			this.dispatchEvent( new Event( IndicatorVO.INDICATOR_UPDATED  ) )  
		}
		
		public var frequency :   String = '';
		public var units :   String = '';		
		
		public var last_updated : Date = new Date(); 
		public var observation_start : Date = new Date(); 
		public var observation_end : Date = new Date(); 		
		
	}
}