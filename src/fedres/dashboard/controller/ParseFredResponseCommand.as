package  fedres.dashboard.controller
{
	import fedres.dashboard.model.EconomyDashboardModel;
	import fedres.dashboard.model.vo.IndicatorVO;
	import fedres.dashboard.model.vo.ObservationVO;
	import fedres.dashboard.model.vo.ScaleRangeVO;
	import fedres.dashboard.services.FredAPIService;
	import fedres.dashboard.view.utils.LoadFile;
	
	import flash.events.Event;
	
	import mx.controls.DateField;
	import mx.formatters.DateFormatter;
	
	import org.robotlegs.mvcs.Command;
	import org.syncon.popups.controller.ShowPopupEvent;
 
	/**
	 * 
	 */
	public class ParseFredResponseCommand extends  Command
	{
		 [Inject] public var event:  ParseFredResponseTriggerEvent;
		 [Inject] public var model: EconomyDashboardModel;
		 [Inject] public var fred:  FredAPIService;		
		 
		override public function execute():void
		{
			if ( event.type ==  ParseFredResponseTriggerEvent.PARSE_FRED_SERIES_ARRAY) 
				loadSeriesArray()
			//var ee : LoadFile = new LoadFile( event.file, onLoaded, event.fxFault ) 
		}
		
		
		private function loadSeriesArray( ):void
		{
			var list : XMLList = event.xml.descendants( 'series' ) ;
			var series :   Array = []
			for each (var i:XML in list ) {
				var new_series :  IndicatorVO = new IndicatorVO()
				new_series.id = i.@id
				new_series.series_id = i.@id
				//augment with fred
	/*			if ( event.loadObservations )
				{
					fred.loadSeriesObservations( new_series.series_id, this.handleDataServiceResult, [new_series] ) 
					//fred.loadSeriesInformation( new_series.series_id, this.handleSeriesInformationServiceResult, [new_series] ) 
				}*/
				
				new_series.name = i.@id
				handleSeriesInformationServiceResult( i, new_series )				
				
				series.push( new_series ) 
			} 
			trace( 'parsed ' +  series.length + ' series ' ) ; 
			this.resultResult( series  )  
		}
		
		private function resultResult ( o  : Object ) : void
		{
			if ( this.event.fxComplete == null ) 
				return; 
			if ( this.event.prependParameters == null  )
			{
				this.event.fxComplete( o ) 
			}
			else
			{
				var args : Array = this.event.prependParameters 
				args.push( o ) 
				this.event.fxComplete.apply( this, args ) 
			}
		}
		
		/*
		private function load1Series(e: Event):void
		{
				var new_series :  IndicatorVO = new IndicatorVO()

				var obs : Array = []; 
				var observations : XMLList = i.descendants( 'observation' ) ;
 
				obs = proc_parseObservations( observations )
				new_series.series_id = i.@id
					
				//augment with fred
				if ( i.@load_fred_data == null ||  i.@load_fred_data == true || i.hasOwnProperty('load_fred_data') == false )
				{
					fred.loadSeriesObservations( new_series.series_id, this.handleDataServiceResult, [new_series] ) 
					fred.loadSeriesInformation( new_series.series_id, this.handleSeriesInformationServiceResult, [new_series] ) 
				}
				
				this.proc_Observations( new_series, obs )
				
				new_series.name = i.@id
				new_series.whatIsIt = i.@what_is_it
				
				
				series.push( new_series ) 
	 
			}
			*/
			public function fault(e:Event) : void
			{
				//ddint' find it , u want to search for file
				var str : String = e.currentTarget.data; 
			}
			
			
			public function handleDataServiceResult( e: Object , indicator :  IndicatorVO) : void
			{
				trace('data recieved' ) ; 
			}
			
			public function handleSeriesInformationServiceResult( e: Object , indicator :  IndicatorVO) : void
			{
				indicator.name = e.@title; 
				indicator.observation_start = this.parseDate_YYYYMMDD(e.@observation_start) 
				indicator.observation_end = this.parseDate_YYYYMMDD(e.@observation_end) 				
				//frequency="Annual"
				indicator.frequency = e.@frequency; 
				//units="Billions of Chained 2005 Dollars"
				indicator.units = e.@units; 
				//last_updated="2010-07-30 15:01:12-05"
				indicator.last_updated = this.parseDate_YYYYMMDD(e.@last_updated.toString().split(' ')[0]) 					
				indicator.updated(); 
				indicator.notes = e.@notes; 
			}			
			
			/**
			 * Parse date_string in YYYY-MM-DD
			 * */
			public function parseDate_YYYYMMDD( date_string :  String ) : Date
			{
				var d : Date = new Date(); 
				d = DateField.stringToDate(date_string, 'YYYY-MM-DD'  )
				return d; 
			}
			
			public function openPopupFor( i : IndicatorVO ) : void
			{
				/*
				this.dispatch( new   ShowPopupEvent( ShowPopupEvent.SHOW_POPUP, 
					'PopupHistoricalData', [i]) ) 
				*/	
				/*
				this.dispatch( new ShowPopupEvent( ShowPopupEvent.SHOW_POPUP, 
					'PopupEditDashboard' ) ) 			
				*/	
				var indicator : IndicatorVO = new IndicatorVO()
				indicator.name = 'decanter'
				indicator.setup( 'decanter', '', -10, 10 , 5, null, 1, 4)
				var ranges : Array = []
				var range : ScaleRangeVO = new ScaleRangeVO()
				range.setup( 'Falling off', 'When fed falls down this is what happens', -5, 50, -3, 1 ) 
				ranges.push( range ) 	
				range = new ScaleRangeVO()
				range.setup( 'Falling off2', 'When fed2', -0, 10, -3, 1 ) 
				ranges.push( range ) 						
				indicator.ranges = ranges
				/*this.dispatch( new ShowPopupEvent( ShowPopupEvent.SHOW_POPUP, 
					'EditSeriesPopup', [indicator] ) ) 	*/	
				/*	
				this.dispatch( new ShowPopupEvent( ShowPopupEvent.SHOW_POPUP, 
					'EditSeriesPopup', [series] ) ) 	*/	
					
			}
			
			/**
			 * Converts values into ObservationVO objects
			 * */
			private function proc_parseObservations( observations : XMLList ) :  Array
			{
				var obs : Array = []
				for each (var observation:XML in observations ) 
				{
					var o :  ObservationVO = new ObservationVO()
					o.setDateString = observation.@date
					o.value = observation.@value 
					obs.push( 	o )
				}
				return obs
			}
			private function proc_3MonthTrend(i : IndicatorVO, reversed_orderered_observations :  Array ) :  Array
			{
				var date :  Date = new  Date()
				var o : Object;
				var threeMonthTrend : Array  = []
				var threeMonthsAgo : Date = new Date()
				threeMonthsAgo.setTime( date.getTime()-(90*24*60*60*1000) ) 
					
				for each (o in reversed_orderered_observations ) 
				{
					if ( o.date.getTime() > threeMonthsAgo.getTime() ) 
						threeMonthTrend.push( 	o )
				}	
				
				
				//3 month trend 
				var threeMonthTrendA : ObservationVO; 
				var threeMonthTrendB : ObservationVO; 
				threeMonthTrendA = reversed_orderered_observations[reversed_orderered_observations.length-1] 
				//if don't have enough observations, extend out the range to get at least 2
				if ( threeMonthTrend.length <= 1  ) 
				{
					threeMonthTrendB = reversed_orderered_observations[reversed_orderered_observations.length-2] 
				}
				else
				{
					//revDate was in descendting order
					threeMonthTrendB = threeMonthTrend[0] 
				}
				i.threeMonthTrendPositive = true; 
				var dir : Number = threeMonthTrendA.value - threeMonthTrendB.value
				if ( dir <= 0 ) 
					i.threeMonthTrendPositive = false
						
				
				return threeMonthTrend;
			}
			
			private function proc_GetLastYearsData(i : IndicatorVO, reversed_orderered_observations :  Array ) : void
			{
				var oneYearAgo : Date = new Date(); //( new Date().fullYearUTC-1, new Date().month )
				oneYearAgo.fullYear -= 1
				var lastYears : Array = []; 
				
				var o : Object;
				for each (o in reversed_orderered_observations ) 
				{
					if ( o.date.getTime() > oneYearAgo.getTime() ) 
						lastYears.push( 	o )
				}				
				
				i.lastYears = lastYears; 	
			}			
			
			/**
			 * Calculates typitcail values for a series
			 * */
			private function proc_Get95Ranges( i : IndicatorVO, ordered_observations :  Array) : void
			{
				var indexMin : int = ordered_observations.length * .5
				var indexMax : int = ordered_observations.length * .95			
				i.typicalLo = ordered_observations[indexMin].value
				i.typicalHi = ordered_observations[indexMax].value
					
				i.typicalLoObservation = ordered_observations[indexMin]
				i.typicalHiObservation = ordered_observations[indexMax]					
			}			
			/**
			 * Calculates typitcail values for a series
			 * */
			private function proc_GetMaxMin( i : IndicatorVO, ordered_observations :  Array) : void
			{
				i.lo = ordered_observations[0].value
				i.hi = ordered_observations[ordered_observations.length-1].value	
				i.loObservation = ordered_observations[0] 
				i.hiObservation = ordered_observations[ordered_observations.length-1]		
			}					
			
			/**
			 * Calls all proccessing functions
			 * */
			private function proc_Observations( i : IndicatorVO,  unordered_observations :  Array) : void
			{
				//go back 1 year or something .... 
				i.allDataPoints = unordered_observations
				i.currentValue = unordered_observations[unordered_observations.length-1].value
				i.currentObservation = unordered_observations[unordered_observations.length-1]
					
				var ordered : Array = unordered_observations.concat([] )
				ordered.sortOn( ['value'] ) 
				var revDate : Array = unordered_observations.concat([] )
				revDate.sortOn( ['dateString'], [Array.DESCENDING] )  
				
				proc_3MonthTrend( i, revDate ) 
				proc_GetLastYearsData( i, revDate ) 
				
				this.proc_Get95Ranges( i, ordered ) 
				this.proc_GetMaxMin( i, ordered ) 
					
					
			}					
		
	}
}