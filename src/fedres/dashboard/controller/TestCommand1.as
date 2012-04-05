package  fedres.dashboard.controller
{
	import org.robotlegs.mvcs.Command;
	
	/**
	 * 
	 */
	public class TestCommand1 extends  Command
	{
		//[Inject] public var model: EconomyDashboardModel;
		[Inject] public var event:     TestCommand1TriggerEvent;
		override public function execute():void
		{
			//var ee : LoadFile = new LoadFile( event.file, event.fxComplete, event.fxFault ) 
			trace('ok')
			this.execute2() 
		}
		
		private function execute2():void
		{ 
			trace('oks2...', event.type)
			if ( event.type == TestCommand1TriggerEvent.LOAD_FILE6 ) 
			{
				trace('asdf', TestCommand1TriggerEvent.LOAD_FILE6 )
			}
		}
	}
}