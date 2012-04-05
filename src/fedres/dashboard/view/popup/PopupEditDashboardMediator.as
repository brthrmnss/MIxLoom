package   fedres.dashboard.view.popup
{
	import fedres.dashboard.controller.CustomEvent;
	import fedres.dashboard.controller.LoadDashboardTriggerEvent;
	import fedres.dashboard.model.EconomyDashboardModel;
	import fedres.dashboard.model.vo.IndicatorVO;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Mediator;
	import org.syncon.popups.controller.ShowPopupEvent;
	
	public class PopupEditDashboardMediator extends Mediator
	{
		[Inject] public var ui: PopupEditDashboard;
		[Inject] public var model : EconomyDashboardModel;
		/**
		 * Stores inital setting of custom board, when popup first opened
		 * */
		private var initCustom : Boolean = false;
		
		public function PopupEditDashboardMediator()
		{
		} 
		
		override public function onRegister():void
		{
			this.ui.addEventListener( 'openedPopup', this.onOpenPopup) 
			this.ui.addEventListener( PopupEditDashboard.EDIT_SERIES, this.onEditSeries ) 
			this.ui.addEventListener( PopupEditDashboard.ADD_SERIES, this.onAddSeries) 
			this.ui.addEventListener( PopupEditDashboard.DELETE_SERIES, this.onDeleteSeries) 	
			this.ui.addEventListener( PopupEditDashboard.CHANGED_BOARD_NAME, this.onChangedName) 								
				
			this.ui.addEventListener( PopupEditDashboard.SAVE, this.onSave) 	
			this.ui.addEventListener( PopupEditDashboard.CANCEL, this.onCancel) 								
								
		}
		 
		private function onSave(e:  CustomEvent) : void
		{
			this.ui.hide(); 
			this.dispatch( new LoadDashboardTriggerEvent(LoadDashboardTriggerEvent.LOAD_ARRAY, 
			'', null, null, this.ui.list.dataProvider.toArray() ) ) 
		}		
		private function onCancel(e:  CustomEvent) : void
		{
			this.model.customBoard = this.initCustom 
			this.ui.hide(); 
		}				
		
		private function onOpenPopup(e:  CustomEvent) : void
		{
			this.initCustom = this.model.customBoard; 
			this.model.customBoard = true; 
			this.ui.list.dataProvider = new ArrayCollection( this.model.series.toArray() ) 
		}					
		
		private function onEditSeries(e:  CustomEvent) : void
		{
			this.dispatch( new ShowPopupEvent( ShowPopupEvent.SHOW_POPUP, 
				'EditSeriesPopup' , [e.data] ) ) 		
		}			
		
		private function onDeleteSeries(e:  CustomEvent) : void
		{
				this.dispatch( new ShowPopupEvent(ShowPopupEvent.SHOW_POPUP, 
					'popup_confirm', ['Are you sure you want to remove the series "' +e.data.name+ '"? '+
						'This change cannot be undone.', this.onDeleteSeries_Confirmed , null,
						'Delete', 'Delete', 'Cancel', [e.data]  ] )  )				
		}				
			
			
			private function onDeleteSeries_Confirmed (p :  IndicatorVO) : void
			{
				this.ui.list.dataProvider.removeItemAt( this.ui.list.dataProvider.getItemIndex( p ) ) 
				/*for each ( var p_ : PersonVO in this.model.board.people ) 
				{
					if ( p_ == p ) 
						trace('found person'); 
					this.model.board.people.indexOf( p )
				}
				this.dispatch( new PanicModelEvent(PanicModelEvent.CHANGED_PEOPLE) ) 
				this.dispatch( new PanicModelEvent(PanicModelEvent.CHANGED_PROJECTS) ) */
			}
		
		private function onAddSeries(e:  CustomEvent) : void
		{
			this.dispatch( new ShowPopupEvent( ShowPopupEvent.SHOW_POPUP, 
				'SearchSeriesPopup', [this.addSeries]  ) ) 		
		}				
			/*private function addSeries(e: String):void
			{
				var i : IndicatorVO = new IndicatorVO()
				i.name = e
				this.ui.list.dataProvider.addItemAt( i, 0 ); 
				return; 
			}*/
			private function addSeries(e: IndicatorVO):void
			{
				this.ui.list.dataProvider.addItem(  e ); 
				return; 
			}
			
			private function onChangedName(e: CustomEvent) : void
			{
				 this.model.boardName = e.data.toString()
			}				
			
	}
}