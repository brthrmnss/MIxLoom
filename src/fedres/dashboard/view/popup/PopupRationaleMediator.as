package  org.syncon.evernote.panic.view.popup.management
{
	import org.robotlegs.mvcs.Mediator;
	import org.syncon.evernote.basic.model.CustomEvent;
	import org.syncon.evernote.panic.model.PanicModel;
	import org.syncon.evernote.panic.model.PanicModelEvent;
	import org.syncon.popups.controller.ShowPopupEvent;
	
	public class PopupInviteMediator extends Mediator
	{
		[Inject] public var ui: PopupInvite;
		[Inject] public var model :  PanicModel;
		
		public function PopupInviteMediator()
		{
		} 
		
		override public function onRegister():void
		{
			this.ui.addEventListener( 'openedPopup', this.onOpenPopup) 
		}
		
		private function onOpenPopup(e:CustomEvent) : void
		{
			this.ui.txtInput.text =   this.model.boardUrl()		
			if ( this.model.board.board_password == '' || this.model.board.board_password == null ) 
				this.ui.txtMsg2.text = 'You have a no password set, so anyone will be able to view this board';
			else
				this.ui.txtMsg2.text = 'Users will be required to enter the board password before they can view it.';
			
		}					
		
	}
}