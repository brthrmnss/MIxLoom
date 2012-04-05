package  fedres.dashboard.view
{
	import fedres.dashboard.controller.CustomEvent;
	import fedres.dashboard.model.EconomyDashboardModel;
	import fedres.dashboard.model.EconomyDashboardModelEvent;
	
	import mx.collections.ArrayList;
	
	import org.robotlegs.mvcs.Mediator;
 
	public class HeaderTopMediator extends Mediator  
	{
		[Inject] public var ui:   headerTop;
		[Inject] public var model :  EconomyDashboardModel;
			
		public function HeaderTopMediator()
		{
		} 
		
		override public function onRegister():void
		{
 			eventMap.mapListener(eventDispatcher, 
				EconomyDashboardModelEvent.NAME_CHANGED, 
				this.onNameChanged);	
			eventMap.mapListener(eventDispatcher, 
				EconomyDashboardModelEvent.CUSTOM_BOARD_CHANGED, 
				this.onCustomChanged );	
			
			this.onNameChanged(null)
		}
	 
 
		private function onNameChanged(e: EconomyDashboardModelEvent): void
		{
			this.ui.lblTitle.text = this.model.boardName;
		}		
		private function onCustomChanged(e: EconomyDashboardModelEvent): void
		{
			if ( this.model.customBoard ) 
			{
				this.ui.currentState = 'custom' 
			}
			else
			{
				this.ui.currentState = 'normal' 
			}
		}				
  
	}
}