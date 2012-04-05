/**
* Main Model for Application 
*/
package  fedres.dashboard.model
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Actor;
 
	public class   EconomyDashboardModel   extends  Actor 
	{
			
		private var _boardName : String = 'Monetary Policy Dashboard'; 
		public function get boardName ( ) : String { return this._boardName }	
		public function set boardName ( n:  String ) : void  { 
			this._boardName  = n 
			this.dispatch( new EconomyDashboardModelEvent ( 
				EconomyDashboardModelEvent.NAME_CHANGED,  n) )
		}	
		private var _customBoard : Boolean = false; 
		public function get customBoard ( ) : Boolean { return this._customBoard }	
		public function set customBoard ( n:  Boolean ) : void  { 
			this._customBoard  = n 
			this.dispatch( new EconomyDashboardModelEvent ( 
				EconomyDashboardModelEvent.CUSTOM_BOARD_CHANGED,  n) )
		}			
		//public var thirdPartyWarningText : String = ''; 
		
		public function set seriesAsArray ( p :  Array )  : void
		{
			this._series.removeAll()
			for each ( var i  : Object in p ) 
			{this._series.addItem( i )} 
			this.dispatch( new EconomyDashboardModelEvent ( 
				EconomyDashboardModelEvent.DASHBOARD_SERIES_CHANGED, this._series ) )
		}		
		
		private var _series :    ArrayCollection = new ArrayCollection()
		 
		public function get  series ( ) :  ArrayCollection  { return this._series   }		
		
		public function alert( s : String ) : void
		{
			
		}
		
		public function calc( val : Number, lo : Number, hi : Number ) :  Number
		{
			//0 on range of -10,10 = .5, or    0-(-10)/10-(-10) = 10/20 = 0.5
			
			return ( val  - lo )  / ( hi - lo )  
		/*	this.scaleRangeBg.x = this.scaleBg.width * ( this.indicator.typicalLo-this.indicator.lo)/(this.indicator.range )
			this.scaleRangeBg.width =  (this.scaleBg.width * 
				( this.indicator.typicalHi-this.indicator.lo)/(this.indicator.range ))
				- this.scaleRangeBg.x;	*/
		}
				
		
		
	}
}