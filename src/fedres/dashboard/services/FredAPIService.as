/**
* Main Model for Application 
*/
package  fedres.dashboard.services
{

	
	import fedres.dashboard.controller.ParseFredResponseTriggerEvent;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.http.HTTPService;
	
	import org.robotlegs.mvcs.Actor;
 
	public class FredAPIService extends  Actor 
	{
		protected static const FRED_API_KEY:String = "599bfd752c11f5ca3fbcfd02414a0c4f";
		protected static const FLICKR_SECRET:String = "8f7e19a3ae7a25c9";
		//http://api.stlouisfed.org/fred/series/observations?series_id=FEDFUNDS&api_key=599bfd752c11f5ca3fbcfd02414a0c4f
		public var BASE_URL :  String = 'http://api.stlouisfed.org/fred/';
		
		import flash.utils.Dictionary;		
		
		public function FredAPIService()
		{
			super();
		}
		
		public function get searchAvailable():Boolean
		{
			return false;
		}
		
		public function loadSeriesObservations( series_id :  String , fx : Function , paramsPassThrough : Array = null):void
		{
			var service: HTTPService = new HTTPService();
			var responder: Responder = new Responder(loadSeriesObservations_Result, loadSeriesObservations_Fault);
			var token:  AsyncToken;
			service.resultFormat = "e4x";
			//http://api.stlouisfed.org/fred/series/observations?series_id=FEDFUNDS&api_key=599bfd752c11f5ca3fbcfd02414a0c4f
			service.url = BASE_URL+'series/observations?'+"series_id="+series_id+"&api_key="+FRED_API_KEY;
			token = service.send();
			token.returnFx = fx
			token.paramsPassThrough = paramsPassThrough
			token.addResponder(responder);
		}
	 
			protected function loadSeriesObservations_Result(event:Object):void
			{
				if ( event.token.returnFx != null ) 
				{
					if ( event.token.paramsPassThrough == null ) 
						event.token.returnFx(event.result)
					else
					{
						var fx : Function = event.token.returnFx as Function
						var args : Array = event.token.paramsPassThrough
						args.unshift(event.result) 
						fx.apply(this, args)
					}
				}
			}
			
			protected function loadSeriesObservations_Fault(event:Object):void
			{
				trace('could not load series observation data')
				trace(event);
				trace()
			}
 
				
		
			public function loadSeriesInformation( series_id :  String , fx : Function , 
												   paramsPassThrough : Array = null, fxFault : Function = null,
												   convertOutputToVOs : Boolean = true):void
			{
				var service: HTTPService = new HTTPService();
				var responder: Responder = new Responder(loadSeriesInformation_Result, loadSeriesInformation_Fault);
				var token:  AsyncToken;
				service.resultFormat = "e4x";
				//http://api.stlouisfed.org/fred/series/observations?series_id=FEDFUNDS&api_key=599bfd752c11f5ca3fbcfd02414a0c4f
				service.url = BASE_URL+'series?'+"series_id="+series_id+"&api_key="+FRED_API_KEY;
				token = service.send();
				token.convertOutputToVOs = convertOutputToVOs
				token.returnFx = fx
				token.fxFault = fxFault; 
				token.paramsPassThrough = paramsPassThrough
				token.addResponder(responder);
			}
			
			protected function loadSeriesInformation_Result(event:Object):void
			{
				if ( event.token.returnFx != null ) 
				{
					var result : Object = event.result
					
					if ( event.token.paramsPassThrough == null ) 
						event.token.returnFx(result)
					else
					{
						var fx : Function = event.token.returnFx as Function
						var args : Array = event.token.paramsPassThrough
						args.unshift(event.result) 
						fx.apply(this, args)
					}
				}
			}
			
			protected function loadSeriesInformation_Fault(event:Object):void
			{
				if ( event.token.fxFault != null ) 
				{
					event.token.fxFault(event.fault)
					return; 
				}				
				trace('could not load series info')
				trace(event);
				trace()
			}			
			
		
			public function searchSeries( query  :  String , fx : Function ,
										  paramsPassThrough : Array = null, 
										  convertOutputToVOs : Boolean = true ):void
			{
				var service: HTTPService = new HTTPService();
				var responder: Responder = new Responder(searchSeries_Result, searchSeries_Fault);
				var token:  AsyncToken;
				service.resultFormat = "e4x";
				//http://api.stlouisfed.org/fred/series/observations?series_id=FEDFUNDS&api_key=599bfd752c11f5ca3fbcfd02414a0c4f
				service.url = BASE_URL+'series/search?search_text='+query+"&api_key="+FRED_API_KEY;
				token = service.send();
				
				token.convertOutputToVOs = convertOutputToVOs
				
				token.returnFx = fx
				token.paramsPassThrough = paramsPassThrough
				token.addResponder(responder);
			}
				
				private function searchSeries_Result(event:Object, parsedSeries:Array=null):void
				{
					
					if ( event.token.returnFx != null ) 
					{
						var result : Object = event.result
						if ( event.token.convertOutputToVOs ) 
						{
							if ( parsedSeries != null ) 
								result = parsedSeries
							else 
							{
								this.dispatch( new ParseFredResponseTriggerEvent( 
									ParseFredResponseTriggerEvent.PARSE_FRED_SERIES_ARRAY, 
									event.result, this.searchSeries_Result, [event] ) 
								)
								return;
							}
							
						}
						
						if ( event.token.paramsPassThrough == null ) 
							event.token.returnFx(result)
						else
						{
							var fx : Function = event.token.returnFx as Function
							var args : Array = event.token.paramsPassThrough
							args.unshift(result) 
							fx.apply(this, args)
						}
					}
				}
			
				private function searchSeries_Fault(event:Object):void
				{
					trace('could not load series info')
					trace(event);
					trace()
				}			
			
	}
}