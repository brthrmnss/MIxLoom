package  fedres.dashboard.controller
{
	import fedres.dashboard.model.EconomyDashboardModel;
	import fedres.dashboard.model.vo.IndicatorVO;
	
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Command;
 
	/**
	 * Export the series to eventually an array or XML file
	 */
	public class ExportDashboardCommand extends  Command
	{
		[Inject] public var model: EconomyDashboardModel;
		[Inject] public var event:     ExportDashboardTriggerEvent;
		override public function execute():void
		{
			this.exportDashboard()
		}
		
		private function exportDashboard( ):void
		{
				var series :   Array = []
				for each (var indicator :  IndicatorVO in this.model.series )   {
					 
					series.push( indicator ) 
				} 
				trace( 'exported ' +  series.length + ' series ' ) ; 
				event.result = series; 
				
				if ( event.fxComplete != null ) 
					event.fxComplete( event.result ) 
				return;
			}
		 		
		
	}
}