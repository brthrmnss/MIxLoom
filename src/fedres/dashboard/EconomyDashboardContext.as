package  fedres.dashboard
{
	
	import Reloaders.ReloadableGen;
	
	import fedres.dashboard.controller.*;
	import fedres.dashboard.model.SimpleModel;
	import fedres.dashboard.view.*;
	
	import mx.core.UIComponent;
	
	import org.robotlegs.mvcs.Command;
	import org.robotlegs.mvcs.Context;
	import org.robotlegs.mvcs.Mediator;
	
	
	public class EconomyDashboardContext extends Context
	{
		public var r  : ReloadableGen 
		public function EconomyDashboardContext()
		{
			if ( r == null ) 
			{
				r = new ReloadableGen(this)
				r.callProps = ['startup']; 
				ReloadableGen.add( r )
			}			
			super();
		}
		public function startup2() : void
		{
			this.commandMap.mapEvent(TestCommand1TriggerEvent['LOAD_FILE'],
				TestCommand1   , TestCommand1TriggerEvent );
			trace('2', 'Econossssssssssssmy', 'called d..888sdd88.cd');
			injector.mapSingleton(   SimpleModel  )
			//mediatorMap.mapView( dashboard,  DashboardMediator );		
			
			//commandMap
			this.commandMap.mapEvent(TestCommand1TriggerEvent.LOAD_FILE,
				TestCommand1   , TestCommand1TriggerEvent );
			this.commandMap.mapEvent(TestCommand1TriggerEvent.LOAD_FILE2,
				TestCommand1   , TestCommand1TriggerEvent );
			 this.commandMap.mapEvent(TestCommand1TriggerEvent.LOAD_FILE3,
			 TestCommand1   , TestCommand1TriggerEvent );
			 this.commandMap.mapEvent(TestCommand1TriggerEvent.LOAD_FILE4,
				 TestCommand1   , TestCommand1TriggerEvent );
		 
			if ( 1 == 0 )
			{
				this.commandMap.mapEvent(TestCommand1TriggerEvent['LOAD_FILE'],
					TestCommand1   , TestCommand1TriggerEvent );
			} 
			var dbg : Array = [this.mediatorMap, this['mediatorMap'] ] 
			//mediatorMap.mapView(  TestView,  TestViewMediator );
			 this.dispatchEvent( new TestCommand1TriggerEvent(TestCommand1TriggerEvent.LOAD_FILE3, '', null, null) ) 
			 this.dispatchEvent( new TestCommand1TriggerEvent(TestCommand1TriggerEvent.LOAD_FILE4, '', null, null) )
			  
			trace('LOAD_FILE5', TestCommand1TriggerEvent['LOAD_FILE6'])
			 this.commandMap.mapEvent(TestCommand1TriggerEvent.LOAD_FILE6,
				 TestCommand1   , TestCommand1TriggerEvent );	
			 this.dispatchEvent( new TestCommand1TriggerEvent(TestCommand1TriggerEvent.LOAD_FILE6, '', null, null) )
			 
				    
			//fedres.dashboard.view.TestViewf
			//	var ee : TestViewMediator 
			
		}
		override public function startup():void
		{ 
			/*	var x : Object = {}
			x.name = 'marco'*/
			/*var fx : Function = this['startup2']
			fx.call( this );//, 5, x ); 
			*/
			trace('Economy', 'called CstdxDs...c');
			
			/*	// Model
			injector.mapSingleton(   EconomyDashboardModel  )	
			injector.mapSingleton(  FredAPIService )
			// Controller
			//commandMap.mapEvent(LoadDefaultDataTriggerEvent.SETUP_BOARD,  LoadDefaultDataCommand, null, false );				
			commandMap.mapEvent(LoadDashboardTriggerEvent.LOAD_FILE,
			LoadDashboardCommand , LoadDashboardTriggerEvent );		
			
			commandMap.mapEvent(LoadDashboardTriggerEvent.LOAD_ARRAY,
			LoadDashboardCommand , LoadDashboardTriggerEvent );		
			
			commandMap.mapEvent(ExportDashboardTriggerEvent.EXPORT_DASHBOARD,
			ExportDashboardCommand , ExportDashboardTriggerEvent );					
			
			commandMap.mapEvent(LoadDashboardSeriesTriggerEvent.LOAD_FILE,
			LoadDashboardSeriesCommand , LoadDashboardSeriesTriggerEvent );					
			
			commandMap.mapEvent(ParseFredResponseTriggerEvent.PARSE_FRED_SERIES,
			ParseFredResponseCommand , ParseFredResponseTriggerEvent );		
			
			commandMap.mapEvent(ParseFredResponseTriggerEvent.PARSE_FRED_SERIES_ARRAY,
			ParseFredResponseCommand , ParseFredResponseTriggerEvent );					
			
			
			mediatorMap.mapView( dashboard,  DashboardMediator );		
			mediatorMap.mapView( headerTop,  HeaderTopMediator );		
			*/
			
			//subContext.subLoad( this, this.injector, this.commandMap, this.mediatorMap ) 				
			super.startup();
			
			
			var wait : Boolean = true;
			if ( wait ) 
			{
				setTimeout( this.onInit, 1500 )
			}
			else
				this.onInit()	
			
			this['startup2'](); 
		}
		import flash.utils.setTimeout;
		/*public var subContext : EconomyDashboardPopupContext =  
		new EconomyDashboardPopupContext()*/
		public function onInit()  : void
		{
			this.dispatchEvent( new LoadDashboardTriggerEvent( 
				LoadDashboardTriggerEvent.LOAD_FILE, 
				'dashboard.xml' )) 
			 
			 
			this.dispatchEvent( new TestCommand1TriggerEvent(TestCommand1TriggerEvent.LOAD_FILE, '', null, null) ) 
			
		}
		
		public function mapView(viewer: UIComponent):void
		{
			var dbg : Array = [EconomyDashboardContext, this.mediatorMap, this['mediatorMap'], mediatorMap ] 
			this.mediatorMap.mapView(  TestViewf,  TestViewMediator );
			
			this.mediatorMap.createMediator( viewer ); 
		}
	}
}