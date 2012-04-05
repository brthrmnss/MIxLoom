package   fedres.dashboard.view.popup
{
	import fedres.dashboard.controller.CustomEvent;
	import fedres.dashboard.model.EconomyDashboardModel;
	import fedres.dashboard.services.FredAPIService;
	
	import org.robotlegs.mvcs.Mediator;
	import org.syncon.popups.controller.ShowPopupEvent;
	
	public class SearchSeriesPopupMediator extends Mediator
	{
		[Inject] public var ui:   SearchSeriesPopup;
		[Inject] public var model :   EconomyDashboardModel;
		[Inject] public var fred :    FredAPIService;
		public function SearchSeriesPopupMediator()
		{
		} 
		
		override public function onRegister():void
		{
			this.ui.addEventListener( SearchSeriesPopup.CLICKED_SEARCH, this.onClickedSearch ) 
			this.ui.addEventListener( SearchSeriesPopup.CLICKED_INDICATOR, this.onClickedIndicator ) 
			this.ui.addEventListener( 'openedPopup', this.onOpenPopup) 
		}
		 
		private function onOpenPopup(e:  CustomEvent) : void
		{
			this.ui.lblMessage.text = '' 
			this.ui.lblNoResultsFound.visible = false
			this.ui.txtSearch.setFocus();
			 //this.ui.list.dataProvider = this.model.series;
		}					
		
		private function onClickedSearch(e:  CustomEvent) : void
		{
			if ( this.ui.txtSearch.text.length < 4 ) 
			{
				this.ui.lblMessage.text = 'Query too short' 
				return; 
			}
			this.ui.lblMessage.text = 'Searching...' 
			//
			//this.ui.fxComplete( this.ui.txtFredId.text ) 
			this.fred.searchSeries( this.ui.txtSearch.text, this.onSearchResultRecieved ) 
		}						
		
			private function onSearchResultRecieved( results : Array ) : void
			{
				this.ui.dp.removeAll()
				for each ( var o : Object in results ) 
				{
					this.ui.dp.addItem( o ) 
				}
				
				this.ui.lblMessage.text = 'Found ' + results.length + ' results.' 
				this.ui.lblNoResultsFound.visible = ( results.length == 0 ) 
			}
			
			private function onClickedIndicator(e:  CustomEvent) : void
			{
				 this.ui.fxComplete( e.data) 
				this.ui.hide()
			}				
		
		
	}
}