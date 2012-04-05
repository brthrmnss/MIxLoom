package   fedres.dashboard.model.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class ScaleRangeVO  extends EventDispatcher
	{
		static public var CHANGED_RANGE : String  = 'changeRange'; 
		
		public var id : String = ''; 
		[Bindable] public var name : String = ''; 
		[Bindable] public var desc : String = ''; 
		[Bindable] public var rationale : String = ''; 		
		[Bindable] public var value : Number = 1; 
		[Bindable] public var hi : Number = 0; 
		[Bindable] public var lo : Number = 0; 
		[Bindable] public var multipler : Number = 1; 		
		
		/**
		 * Used by renders to indicate color
		 * */
		[Transient] public var color : uint = 0; 
		/**
		 * Used by renders to indicate color
		 * */
		[Transient] public var indicator :  IndicatorVO; 
		
		public function setup( name_ :  String, desc_ :  String, 
							   lo_ : Number, hi_ : Number, value_ : Number, 
							   multipler_:  Number=1 ) : void
		{
			this.name = name_
			this.desc = desc_
			this.hi = hi_
			this.lo = lo_
			this.value = value_
			this.multipler= multipler_	
		}
				
		public function rangeChanged() : void
		{
			this.dispatchEvent( new Event(CHANGED_RANGE ) ) 
		}
		
	}
}