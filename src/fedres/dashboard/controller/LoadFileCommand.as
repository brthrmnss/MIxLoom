package   fedres.dashboard.controller
{
	import fedres.biegebook.controller.MapEvent;
	import fedres.biegebook.model.BeigeBookModel;
	
	import map.LoadFile;
	
	import org.robotlegs.mvcs.Command;
 
	/**
	 * 
	 */
	public class LoadFileCommand extends  Command
	{
		[Inject] public var model: BeigeBookModel;
		[Inject] public var event: LoadFileTriggerEvent;
		override public function execute():void
		{
		/*   if ( event.type == MapEvent.ROLLOVER_REGION ) 
		   {
			  this.model.currentDistrict = event.num
		   }*/
			var ee : LoadFile = new LoadFile( event.file, event.fxComplete, event.fxFault ) 
			//ee.
		}
			
 
		
	}
}