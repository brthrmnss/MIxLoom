package   fedres.dashboard.view.utils{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
 
	/**
	 * The LoadFile class loades a file from ssytem quickly
	 */ 
 
	public class LoadFile 
	{
		private var fxResult :  Function; 
		private var fxFault : Function;
		public function LoadFile( file : String, fxResult : Function, fxFailt : Function = null )
		{
				import flash.net.URLLoader;
				import flash.net.URLLoaderDataFormat;
				import flash.net.URLRequest;				
				var loader:URLLoader= new URLLoader()
				loader.dataFormat = URLLoaderDataFormat.TEXT
				loader.addEventListener(Event.COMPLETE, onLoadedFile);
				loader.addEventListener(IOErrorEvent.IO_ERROR, this.onFault ) 
				var request:URLRequest = new URLRequest( file );
				loader.load(  request );	
				this.fxResult = fxResult; 
				this.fxFault = fxFault 
		}	
			private function onLoadedFile(e:Event) : void
			{
				if ( this.fxResult != null ) 
				this.fxResult( e ) 
				//this.importBoardFromString( e.currentTarget.data ) 	
			}
			private function onFault(e:Event) : void
			{
				if ( this.fxFault != null ) 
				this.fxFault( e ) 
				//this.importBoardFromString( e.currentTarget.data ) 	
			}			
 
	}
}