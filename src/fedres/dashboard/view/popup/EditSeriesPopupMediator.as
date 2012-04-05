package   fedres.dashboard.view.popup
{
	import fedres.dashboard.controller.CustomEvent;
	import fedres.dashboard.model.EconomyDashboardModel;
	import fedres.dashboard.model.vo.ScaleRangeVO;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.graphics.SolidColor;
	
	import org.robotlegs.mvcs.Mediator;
	import org.syncon.popups.controller.ShowPopupEvent;
	
	import spark.components.Group;
	import spark.primitives.Rect;
	
	public class EditSeriesPopupMediator extends Mediator
	{
		[Inject] public var ui:  EditSeriesPopup;
		[Inject] public var model :   EconomyDashboardModel;
		
		public function EditSeriesPopupMediator()
		{
		} 
		
		override public function onRegister():void
		{
			this.initScale()
			this.ui.addEventListener( 'openedPopup', this.onOpenPopup) 
			this.ui.addEventListener( 'closedPopup', this.onClosePopup) 
			this.ui.addEventListener(  EditSeriesPopup.ADD_RANGE, this.onAddRange) 	
			this.ui.addEventListener(  EditSeriesPopup.SORT_RANGES, this.onSort) 	
			this.ui.addEventListener( EditSeriesPopup.DELETE_RANGE, this.onDeleteRange) 	
			
		}
		private function onDeleteRange(e:  CustomEvent) : void
		{
			this.dispatch( new ShowPopupEvent(ShowPopupEvent.SHOW_POPUP, 
				'popup_confirm', ['Are you sure you want to remove this range? ' + //delete "' +e.data.name+ '"? '+
					'This change cannot be undone.', this.onDeleteRange_Confirmed , null,
					'Delete Range', 'Delete', 'Cancel', [e.data]  ] )  )				
		}				
			private function onDeleteRange_Confirmed (p :  ScaleRangeVO) : void
			{
				this.ui.list.dataProvider.removeItemAt( this.ui.list.dataProvider.getItemIndex( p ) ) 
			}
			
		private function initScale() : void
		{
			for   ( var i : int=0 ; i < this.colorsList.length;  i++ )
			{
				var g : Group = new Group()
				var rect : Rect = new Rect()
				rect.fill = new SolidColor( this.colorsList[i] )  
				rect.top = rect.right = rect.bottom = rect.left = 0 ; 
				g.addElement( rect ) ;
				g.percentHeight = 100; 
				this.ui.scale.addElement( g ) 
			}
		}
		private function onOpenPopup(e:  CustomEvent) : void
		{

			for   ( var i : int=0 ; i < this.ui.indicator.ranges.length;  i++ )
			{
				this.ui.indicator.ranges[i].color = colorsList[i]
				this.ui.indicator.ranges[i].indicator = this.ui.indicator		
				this.listenToEvents(this.ui.indicator.ranges[i])
			}
			this.ui.list.dataProvider = new ArrayCollection( this.ui.indicator.ranges ) 
				
		}					
		
		
		private function onClosePopup(e:  CustomEvent) : void
		{
			this.cleanUpEventListeners()
		}				
		
		private function onAddRange(e:  CustomEvent) : void
		{
			if ( this.displayedRanges.length == 12 ) 
			{
				this.model.alert( 'Maximum number of series reached' ) 
				return; 
			}
			var range : ScaleRangeVO = new ScaleRangeVO()
			this.listenToEvents(range)
			range.indicator = this.ui.indicator		
			range.color = this.colorsList[this.displayedRanges.length] 
			//this.ui.list.dataProvider.addItemAt( range, 0 ) 
			this.ui.list.dataProvider.addItem( range  ) 
		}			
		
		public var colorsList : Array = [
			0x097054,0xFFDE00,0x6599FF,0xFF9900,
			0x443266,0xC3C3E5,0xF1F0FF,0x8C489F,
			0x217C7E,0xF3EFE0,0x3399FF,0x9A3334
		]				
			
		private function get displayedRanges () : ArrayCollection
		{
			return this.ui.list.dataProvider as ArrayCollection
		}
			 
		private function listenToEvents ( r :   ScaleRangeVO ) : void
		{
			r.addEventListener( ScaleRangeVO.CHANGED_RANGE, this.onScaleRangeChanged, false, 0, true  )
			listeningTo.push( r ) 
		}
		private var listeningTo : Array = []; 
		private function cleanUpEventListeners() : void
		{
			for each ( var r : ScaleRangeVO in listeningTo )
			{
				r.removeEventListener( ScaleRangeVO.CHANGED_RANGE, this.onScaleRangeChanged )
			}
		}
		
		
		private function onScaleRangeChanged (e:Event) : void
		{
			var canvas : Group = this.ui.scale
			for ( var i : int=0 ; i < canvas.numElements;  i++ )
			{
				var bar : Group = canvas.getElementAt(i )  as Group
				bar.width = 0 
				bar.x = 0 
			}
			//var diffRange : Number =  this.ui.indicator.typicalHi - this.ui.indicator.typicalLo
			var width : Number = this.ui.scale.width; 
			for (   i  =0 ; i < displayedRanges.length;  i++ )
			{
				//bar  = canvas.getElementAt(i ) as Group
				
				var range :  ScaleRangeVO = displayedRanges[i] as ScaleRangeVO
				bar  = this.getBarByColor( range.color ) 
				bar.x = width*this.model.calc( range.lo, this.ui.indicator.lo, this.ui.indicator.hi )
				bar.width = width*this.model.calc( range.hi, this.ui.indicator.lo, this.ui.indicator.hi )
				bar.width -=   bar.x
			}
		}
		
		/**
		 * Returns color bar child of sdale
		 * */
		private function getBarByColor( color :  uint ) :  Group
		{
			var index : int = this.colorsList.indexOf( color ) 
			return this.ui.scale.getElementAt( index ) as Group
		}
		//dleete? 
		
		
		
		private function onSort (e:Event) : void
		{
			var arr : Array = this.displayedRanges.toArray()
			arr.sortOn(  'lo'  ) 
			this.ui.list.dataProvider = new ArrayCollection( arr ) ; 
		}
				
		
	}
}