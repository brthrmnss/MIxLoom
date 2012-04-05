package   fedres.dashboard.view.popup
{
	import fedres.dashboard.controller.CustomEvent;
	import fedres.dashboard.model.EconomyDashboardModel;
	
	import org.robotlegs.mvcs.Mediator;
	import org.syncon.popups.controller.ShowPopupEvent;
	
	public class PopupTooltipMediator extends Mediator
	{
		[Inject] public var ui:   PopupTooltip;
		[Inject] public var model :   EconomyDashboardModel;
		
		public function PopupTooltipMediator()
		{
		} 
		
		override public function onRegister():void
		{
			this.ui.addEventListener( 'openedPopup', this.onOpenPopup) 
		}
		
		private function onOpenPopup(e:  CustomEvent) : void
		{
		 
		}					
		
	}
}