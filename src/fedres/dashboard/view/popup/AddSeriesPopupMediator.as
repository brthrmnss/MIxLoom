package   fedres.dashboard.view.popup
{
	import fedres.dashboard.controller.CustomEvent;
	import fedres.dashboard.model.EconomyDashboardModel;
	import fedres.dashboard.services.FredAPIService;
	
	import org.robotlegs.mvcs.Mediator;
	import org.syncon.popups.controller.ShowPopupEvent;
	
	public class AddSeriesPopupMediator extends Mediator
	{
		[Inject] public var ui:   AddSeriesPopup;
		[Inject] public var model :   EconomyDashboardModel;
		[Inject] public var fred :  FredAPIService;
		
		public function AddSeriesPopupMediator()
		{
		} 
		
		override public function onRegister():void
		{
			this.ui.addEventListener( AddSeriesPopup.CLICKED_ADD, this.onClickedAdd ) 
			this.ui.addEventListener( 'openedPopup', this.onOpenPopup) 
		}
		 
		private function onOpenPopup(e:  CustomEvent) : void
		{
			//this.ui.list.dataProvider = this.model.series;
		}					
		
		private function onClickedAdd(e:  CustomEvent) : void
		{
			this.ui.message = ''; 
			this.verifyInput()
			
		}		
		
		private function verifyInput( ) : void
		{
			this.fred.loadSeriesInformation(this.ui.txtFredId.text , this.inputVerified , null, inputVerified_Fault)
		}			
			private function inputVerified(e:   Object) : void
			{
				this.ui.fxComplete( this.ui.txtFredId.text ) 
				this.ui.hide(); 
			}			
			private function inputVerified_Fault(e:   Object) : void
			{
				this.ui.message = 'Could not find that series. Try again.' 
			}					
	
			
	}
}