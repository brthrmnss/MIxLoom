package   fedres.dashboard.view.popup
{
	import fedres.dashboard.controller.CustomEvent;
	import fedres.dashboard.model.EconomyDashboardModel;
	
	import mx.formatters.DateFormatter;
	
	import org.robotlegs.mvcs.Mediator;
	import org.syncon.popups.controller.ShowPopupEvent;
	
	public class PopupHistoricalDataMediator extends Mediator
	{
		[Inject] public var ui:  PopupHistoricalData;
		[Inject] public var model :   EconomyDashboardModel;
		
		public function PopupHistoricalDataMediator()
		{
		} 
		
		override public function onRegister():void
		{
			this.ui.addEventListener( 'openedPopup', this.onOpenPopup) 
		}
		
		private function onOpenPopup(e:  CustomEvent) : void
		{
			//wha tto do when out of info? 
			this.ui.txtValues.text = this.ui.indicator.frequency + ' values '
			this.ui.txtValues.text +=	 '('+this.ui.indicator.units+'): '
			var dateFormatter :  DateFormatter = new DateFormatter()
			dateFormatter.formatString = 'MMMM \'YY'
			this.ui.txtValues.text +=	 dateFormatter.format( this.ui.indicator.observation_start )
			this.ui.txtValues.text +=	 '  -  '
			this.ui.txtValues.text +=	 dateFormatter.format( this.ui.indicator.observation_end )
			this.ui.txtValues.text = this.ui.txtValues.text .toUpperCase()
			this.ui.txtName.text = this.ui.indicator.name
				
			this.ui.txtWhatIsIt.text = this.ui.indicator.desc
			/*this.ui.txtInput.text =   this.model.boardUrl()		
			if ( this.model.board.board_password == '' || this.model.board.board_password == null ) 
				this.ui.txtMsg2.text = 'You have a no password set, so anyone will be able to view this board';
			else
				this.ui.txtMsg2.text = 'Users will be required to enter the board password before they can view it.';
			*/
		}					
		
	}
}