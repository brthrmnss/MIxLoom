package  fedres.dashboard.view
{
	import fedres.dashboard.controller.CustomEvent;
	import fedres.dashboard.model.EconomyDashboardModel;
	import fedres.dashboard.model.EconomyDashboardModelEvent;
	import fedres.dashboard.model.vo.IndicatorVO;
	 
	import mx.collections.ArrayList;
	import mx.formatters.DateFormatter;
	
	import org.robotlegs.mvcs.Mediator;
	import org.syncon.popups.controller.HidePopupEvent;
	import org.syncon.popups.controller.ShowPopupEvent;
 
	public class DashboardMediator extends Mediator  
	{
		[Inject] public var ui:  dashboard;
		[Inject] public var model :  EconomyDashboardModel;
			
		public function DashboardMediator()
		{
		} 
		
		override public function onRegister():void
		{
 			eventMap.mapListener(eventDispatcher, 
				EconomyDashboardModelEvent.DASHBOARD_SERIES_CHANGED, 
				this.onDatesChanged);	
			this.ui.addEventListener( dash_renderer.CLICK_HISTORICAL_DATA, this.onHistoricalData ) 
			this.ui.addEventListener( dash_renderer.ROLLOVER_UI, this.onRolloverUI ) 
			this.ui.addEventListener( dash_renderer.ROLLOUT_UI, this.onRolloutUI ) 
		}
		
		private function formatDate( date : Date , useAlternateFormat :  Boolean = false)  : String
		{
			var ee : DateFormatter = new DateFormatter()
			ee.formatString = 'MMMM DD, YYYY'; 
			if ( useAlternateFormat ) 
				ee.formatString = 'MM/DD/YY'; 
			return ee.format( date )
			
		}
		
		private function bold( str :  String )  : String
		{
			return '<b>' + str +  '</b>'  
		}		
		
		public function onRolloverUI ( e :  CustomEvent )  : void
		{
			var comp : Object = e.data; 
			var str : String = ''; 
			var alignment :  String = 'tl'; 
			var dashboard_renderer : dash_renderer = new dash_renderer()
			var renderer : dash_renderer = comp.parentDocument
			var indicator : IndicatorVO = renderer.indicator; 
			var xOffset : Number = 0
			var yOffset : Number = 0; 
			var newWidth : Number = 0
			var newHeight : Number = 0; 	
			
			if ( comp.id  ==  dashboard_renderer.txtLeftScale.id ) 
			{
				str = 'left lo';
				alignment = 'tr'
				str = 'The lowest recorded value occured on ' + 
				'<b>' + this.formatDate( indicator.loObservation.date ) +  '</b>'  
				xOffset = 10
				yOffset = 5
				newWidth = 180
				newHeight = 40
			}
			if ( comp.id  ==  dashboard_renderer.txtRightScale.id ) 
			{
				alignment = 'tl'				
				str = 'The highest recorded value occured on '  + 
					'<b>' + this.formatDate( indicator.hiObservation.date ) +  '</b>'  
				xOffset = -10
				yOffset = 5	
				newWidth = 180
				newHeight = 40
			}	
			if ( comp.id  ==  dashboard_renderer.typicalRange.id ) 
			{
				alignment = 'c'				
				str = '<b><font size="16">90%</font></b>' + 
					' of the historical values ranged between '  +
					this.bold(indicator.loObservation.value.toString())+
					' and ' +
					this.bold(indicator.hiObservation.value.toString() ) 
				//xOffset = 150/2
				yOffset = -80-10	
				yOffset = 70
				newWidth = 150
				newHeight = 60				
			}	
			if ( comp.id  ==  dashboard_renderer.txtName.id) 
			{
				alignment = 'bl'				
				str = '<b><font size="16">90%</font></b>' + 
				' of the historical values ranged between '  +
				indicator.loObservation.value +
				' and ' +
				indicator.hiObservation.value  
				xOffset = 0
				yOffset = 10	
				newWidth = 150
				newHeight = 80						
			}	
			if ( comp.id  ==  dashboard_renderer.arrowNo.id  ) 
			{
				alignment = 'c'				
				str = 'As of '+this.formatDate( indicator.currentObservation.date, true)+ ',  '
				str += '<b><font size="16">'
				if ( indicator.currentObservation.value >= indicator.typicalLoObservation.value &&
					indicator.currentObservation.value <= indicator.typicalHiObservation.value )
				{
					str += 'within typical.'  
				}
				if ( indicator.currentObservation.value < indicator.typicalLoObservation.value  ) 
				{
					if (  indicator.threeMonthTrendPositive )
						str += 'trending from typical.' 
					else
						str += 'trending towards typical.'  
				}
				if ( indicator.currentObservation.value > indicator.typicalHiObservation.value  ) 
				{
					if (  indicator.threeMonthTrendPositive  )
						str +=   'trending from typical.'  
					else
						str += 'trending towards typical.'  
				}
 
				str += '</b></font>'
				yOffset = -80-10	
				yOffset = -90
				newWidth = 160
				newHeight = 60			
			}				
			this.dispatch( new ShowPopupEvent(  ShowPopupEvent.SHOW_POPUP, 
				'PopupTooltip', [e.data, str, alignment, xOffset, yOffset, 
											newWidth, newHeight]) ) 
		}
		public function onRolloutUI ( e :  CustomEvent )  : void
		{
			this.dispatch( new HidePopupEvent(  HidePopupEvent.HIDE_POPUP, 
				'PopupTooltip', [e.data]) ) 
		}		
			/*
			this.onDatesChanged( null ) 
			this.ui.addEventListener( DateXMLEditor.DELETE_DATE, this.onDeleteDate ) 
			this.ui.addEventListener( DateXMLEditor.EDIT_DATE, this.onEditDate ) 
			this.ui.addEventListener( DateXMLEditor.ADD_DATE, this.onAddDate ) 
		}
		/*
		public function onAddDate ( e : CustomEvent )  : void
		{
			var d : DateXMLVO = new DateXMLVO()
			d.setDate = new Date()
			this.model.dates.addItemAt( d, 0 ); 
			
			this.model.currentDate = d;
		}
			*/	
		public function onHistoricalData ( e :  CustomEvent )  : void
		{
			this.dispatch( new ShowPopupEvent(  ShowPopupEvent.SHOW_POPUP, 
				'PopupHistoricalData', [e.data]) ) 
		}
		private function onDatesChanged(e: EconomyDashboardModelEvent): void
		{
			this.ui.list.dataProvider =  this.model.series  
		}		
 /*
		private function  onChangedDistrict ( e :  CustomEvent )  : void
		{
			var newCurrentDistrict : int  = this.model.currentDistrict + e.data as int
			if ( newCurrentDistrict < 1 )
				newCurrentDistrict = 12; 
			if ( newCurrentDistrict > 12 )
				newCurrentDistrict = 1; 			
			this.model.currentDistrict = newCurrentDistrict
		}
		
		public function onEditDate ( e : CustomEvent )  : void
		{
			this.model.currentDate = e.data as DateXMLVO;
		}
			
		
		public function onDeleteDate ( e : CustomEvent )  : void
		{
			var index : int = this.model.dates.getItemIndex( e.data )
			if ( index != -1 ) this.model.dates.removeItemAt( index ) 
		}	*/	
	}
}