package  fedres.dashboard.controller
{
	import fedres.dashboard.model.EconomyDashboardModel;
	import fedres.dashboard.view.utils.LoadFile;
	
	import org.robotlegs.mvcs.Command;
 
	/**
	 * 
	 */
	public class LoadDashboardSeriesCommand extends  Command
	{
		[Inject] public var model: EconomyDashboardModel;
		[Inject] public var event:    LoadDashboardSeriesTriggerEvent;
		override public function execute():void
		{
			var ee : LoadFile = new LoadFile( event.file, event.fxComplete, event.fxFault ) 
		}
	}
}