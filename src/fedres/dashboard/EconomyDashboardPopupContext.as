package  fedres.dashboard
{
	import fedres.dashboard.view.popup.*;
	import fedres.dashboard.view.popup.default_popups.popup_confirm;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.robotlegs.core.ICommandMap;
	import org.robotlegs.core.IContext;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IMediatorMap;
	import org.robotlegs.mvcs.Context;
	import org.syncon.popups.controller.*;
	import org.syncon.popups.controller.default_commands.*;
	import org.syncon.popups.model.PopupModel;
	import org.syncon.popups.view.popups.default_popups.*;

	public class EconomyDashboardPopupContext extends Context
	{
		
		public function EconomyDashboardPopupContext()
		{
			super();
		}
		
		public function subLoad( this_ : Context,  injector_ : IInjector, commpandMap_ : ICommandMap, mediatorMap_ : IMediatorMap ) : void
		{
			this.injector = injector_
			this.commandMap = commpandMap_
			this.mediatorMap = mediatorMap_
			this._this_ = this_
			this.startupPopupSubContext()
			this.customContext()				
		}
		
		private var _this_   :Context;
		public function get _this () :  Context
		{
			if ( this._this_ == null ) return this; 
			return this._this_ 
		}
		
		
		
		override public function startup():void
		{
			// Model
			// Controller
			// Services
			// View
			
			this.startupPopupSubContext()
		}
		
		public function startupPopupSubContext()  : void
		{
			// Model
			injector.mapSingleton( PopupModel  )		
			// Controller
			//commandMap.mapEvent(StockPricePopupEvent.CREATE_POPUP, CreateStockPricePopupCommand, StockPricePopupEvent);	
			commandMap.mapEvent(CreatePopupEvent.REGISTER_AND_CREATE_POPUP, CreatePopupCommand, CreatePopupEvent);		
			commandMap.mapEvent(CreatePopupEvent.REGISTER_POPUP, CreatePopupCommand, CreatePopupEvent);			
			commandMap.mapEvent(RemovePopupEvent.REMOVE_POPUP, RemovePopupCommand, RemovePopupEvent);			
			commandMap.mapEvent(ShowPopupEvent.SHOW_POPUP, ShowPopupCommand, ShowPopupEvent);			
			commandMap.mapEvent(HidePopupEvent.HIDE_POPUP, HidePopupCommand, HidePopupEvent);			

			//default popups
			commandMap.mapEvent(ShowConfirmDialogTriggerEvent.SHOW_CONFIRM_DIALOG_POPUP, ShowConfirmDialogCommand, ShowConfirmDialogTriggerEvent);			
			commandMap.mapEvent(ShowAlertMessageTriggerEvent.SHOW_ALERT_POPUP, ShowAlertMessageCommand, ShowAlertMessageTriggerEvent);				
			
			commandMap.mapEvent(AddKeyboardShortcutToOpenPopupEvent.ADD_KEYBOARD_SHORTCUTS, AddPopupsKeyboardShortcutsCommand, AddKeyboardShortcutToOpenPopupEvent);	
			commandMap.mapEvent(AddKeyboardShortcutToOpenPopupEvent.ENABLE_KEYBOARD_SHORTCUTS, AddPopupsKeyboardShortcutsCommand);				

			// Services
			// View
			mediatorMap.mapView( popup_modal_bg , PopupModalMediator , null, true, true );	
			this._this.dispatchEvent( new CreatePopupEvent( CreatePopupEvent.REGISTER_AND_CREATE_POPUP,  popup_modal_bg, 'popup_modal_bg', true ) );
			this._this.dispatchEvent( new CreatePopupEvent( 
				CreatePopupEvent.REGISTER_POPUP,  fedres.dashboard.view.popup.default_popups.popup_message, 'popup_alert' ) );
			this._this.dispatchEvent( new CreatePopupEvent( CreatePopupEvent.REGISTER_POPUP, 
				fedres.dashboard.view.popup.default_popups.popup_confirm , 'popup_confirm' ) );			

			this._this.dispatchEvent( new AddKeyboardShortcutToOpenPopupEvent( AddKeyboardShortcutToOpenPopupEvent.ENABLE_KEYBOARD_SHORTCUTS  ) );
			this._this.dispatchEvent( new AddKeyboardShortcutToOpenPopupEvent( AddKeyboardShortcutToOpenPopupEvent.ADD_KEYBOARD_SHORTCUTS, 
				'popup3', 89 ) ); //ctrl+Y			
			//this.dispatchEvent( new ShowPopupEvent( ShowPopupEvent.SHOW_POPUP,  'popup_modal_bg' ) );	
			
			
		}
		
		public function customContext() : void
		{
			this._this.dispatchEvent( new CreatePopupEvent( CreatePopupEvent.REGISTER_POPUP, 
				PopupHistoricalData, 'PopupHistoricalData',  true ) );
			mediatorMap.mapView( PopupHistoricalData , 
				PopupHistoricalDataMediator, null, false, false );	
			
			this._this.dispatchEvent( new CreatePopupEvent( CreatePopupEvent.REGISTER_POPUP, 
				PopupEditDashboard, 'PopupEditDashboard',  true ) );
			mediatorMap.mapView( PopupEditDashboard , 
				PopupEditDashboardMediator, null, false, false );				
			
			this._this.dispatchEvent( new CreatePopupEvent( CreatePopupEvent.REGISTER_POPUP, 
				EditSeriesPopup, 'EditSeriesPopup',  true ) );
			mediatorMap.mapView( EditSeriesPopup , 
				EditSeriesPopupMediator, null, false, false );				
			
			this._this.dispatchEvent( new CreatePopupEvent( CreatePopupEvent.REGISTER_POPUP, 
				AddSeriesPopup, 'AddSeriesPopup',  true ) );
			mediatorMap.mapView( AddSeriesPopup , 
				AddSeriesPopupMediator, null, false, false );				
			
			this._this.dispatchEvent( new CreatePopupEvent( CreatePopupEvent.REGISTER_POPUP, 
				SearchSeriesPopup, 'SearchSeriesPopup',  true ) );
			mediatorMap.mapView( SearchSeriesPopup , 
				SearchSeriesPopupMediator, null, false, false );					
			
			this._this.dispatchEvent( new CreatePopupEvent( CreatePopupEvent.REGISTER_POPUP, 
				PopupTooltip, 'PopupTooltip',  false ) );
			mediatorMap.mapView( PopupTooltip , 
				PopupTooltipMediator, null, false, false );					
		}
		
		public function onInit()  : void
		{
			 import flash.utils.setTimeout; 
			// this.contextView.alpha = 0.3
			//setTimeout( this.onInit2 , 2000 ) 
			this._this.dispatchEvent( new ShowPopupEvent( 
				ShowPopupEvent.SHOW_POPUP,  'popup_login' ) );	
		}
		public function onInit2()  : void
		{
			/*import flash.utils.setTimeout; 
			setTimeout( this.onInit2 , 10000 )*/
			this._this.dispatchEvent( new ShowPopupEvent( 
				ShowPopupEvent.SHOW_POPUP,  'popup_login' ) );	
			
		}		
		
	 
	}
}