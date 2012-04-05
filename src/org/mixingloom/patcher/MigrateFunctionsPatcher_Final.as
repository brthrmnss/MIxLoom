/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/23/11
 * Time: 1:34 PM
 */
package org.mixingloom.patcher
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.as3commons.bytecode.tags.DoABCTag;
	import org.mixingloom.SwfContext;
	import org.mixingloom.SwfTag;
	import org.mixingloom.byteCode.ModifiedByteLoader;
	import org.mixingloom.invocation.InvocationType;
	
	/**
	 * Gave up on the bytecode tilli learn how to add an anoyouse function ....
	 * 
	 * */
	public class MigrateFunctionsPatcher_Final extends AbstractPatcher {
		
		private var paths:Array;
		private var migrates:Array=[];
		private var count:int;
		/**
		 * Call static methods to migrate prototypes 
		 * */
		static public var PostProcessFx:Function;
		static public var ProcessedClasses : Dictionary = new Dictionary(true); 
		static public var SkippedClasses : Dictionary = new Dictionary(true); 		
		private var firstTime_ProcessingClasses:Boolean;
		private var swf:SwfContext;
		private var classList:Array= [];
		
		public function MigrateFunctionsPatcher_Final(paths_:Array , secondTime :Boolean = false)
		{
			this.paths = []; 
			this.firstTime_ProcessingClasses = ! secondTime 
			//clean up paths .... refactor 
			for each ( var path : String in paths_ )
			{
				path = path.split('.').join('/')			
				this.paths.push( path.toLowerCase() ) 
			}
		}
		
		override public function apply( invocationType:InvocationType, swfContext:SwfContext ):void {
			var dbg1 : Array = [ProcessedClasses, SkippedClasses]
			this.swf = swfContext
			if ( swfContext.swfTags.length == 0 ) 
				this.invokeCallBack()
			
			for each (var swfTag:SwfTag in swfContext.swfTags)
			{
				
				if (swfTag.type != DoABCTag.TAG_ID)
				{
					continue
				}
				//trace( 'tag', swfTag.name ); 
				if ( swfTag.name.indexOf('mx/') == 0 ) 
					continue; 
				if ( swfTag.name.indexOf('spark/') == 0 ) 
					continue; 
				if ( swfTag.name.indexOf('_') == 0 ) 
					continue; 
				if ( swfTag.name.indexOf('$') != -1 ) //en_US$components_properties
					continue; 
				if ( swfTag.name.indexOf('/') == -1 ) //Base Application
					continue; 
				if ( swfTag.name.indexOf('flashx/textLayout') == 0 ) //Tlf
					continue;
				if ( swfTag.name.indexOf('org/mixingloom') == 0 ) //Tlf
					continue;
				if ( swfTag.name.indexOf('org/robotlegs') == 0 ) //Tlf
					continue;
				if ( swfTag.name.indexOf('org/swifts') == 0 ) //Tlf
					continue;
				//LoadSwcc.reload_DirsExclude
				//['org/mixingloom/', '', '']				
				if ( this.firstTime_ProcessingClasses ) 
				{
					var found : Boolean = false; 
					if (this.isClassInAccetablePaths(swfTag.name ) == false ) 
					{
						SkippedClasses[swfTag.name] = true; 
						continue;
					}
					/*					for each ( var path : String in this.paths )
					{
					if ( found ) continue; 
					if ( swfTag.name.toLowerCase().indexOf(path) == 0 ) 
					found = true; 				
					}
					if ( found == false ) 
					continue; */
					ProcessedClasses[swfTag.name] = true
				}
				else
				{
					
					//senario: user creates new class after inital compile ...
					//if class not found, only if name is blank try to add newly created class
					if ( SkippedClasses[swfTag.name] == null && ProcessedClasses[swfTag.name] == null) 
					{ 
						//addedum, on 1+ iteration, keep adding classes
						if (this.isClassInAccetablePaths(swfTag.name ) ) 
							ProcessedClasses[swfTag.name] = true
						else
							SkippedClasses[swfTag.name] = true; 
					}
					//if class not found, continue
					if ( ProcessedClasses[swfTag.name] == null ) 
					{
						continue; 
					}
				}
				
				
				if ( this.classList.length > 0 && this.classList.indexOf( swfTag.name ) == -1 ) 
					continue; 
				//var migrate : MigrateUtils = new MigrateUtils()
				var migrate : MigrateUtilsPrototypes = new MigrateUtilsPrototypes()
				this.migrates.push( migrate ) ; 
				migrate.makeClass( swfTag, null, swfContext.swfTags ) 
				//migrate.makeClass( swfTag,this.onInvoke, swfContext.swfTags ) 
			}
			this.onInvoke(true)//this is not async? 
			var dbg : Array = [ProcessedClasses, SkippedClasses]
			/*invokeCallBack();*/
		}
		
		private function isClassInAccetablePaths(swfTagName:String):Boolean
		{
			for each ( var path : String in this.paths )
			{
				if ( swfTagName.toLowerCase().indexOf(path) == 0 ) 
				{
					return true; 
				}
			}
			return false; 
		}
		
		public function onInvoke(force:Boolean=false) :void
		{
			this.count++
			if ( force == false && this.count < this.migrates.length )
				return; 
			
			invokeCallBack();
			PostProcessFx = this.loadedClasses ;
			return;
		}
		
		
		public function loadAndPatch(swfContext:SwfContext):void
		{
			var modifier:ModifiedByteLoader = new ModifiedByteLoader();
			modifier.loaderContext = null;// loaderContext;
			modifier.setCallBack( invokeCallBack );
			modifier.setCallBack( this.loadedClasses ); 
			modifier.applyModificiations( swfContext );
			
		}
		/*	public function initClassScrapning() : void
		{
		this.loadedClasses(null, false ) 
		}
		???
		*/
		private function loadedClasses(e:Event=null ):void
		{
			// TODO Auto Generated method stub
			trace('LoadSwc', 'calledback'); 
			for each ( var m : MigrateUtilsPrototypes in this.migrates ) 
			{
				m.loadedHandler( null ) ; 
			}
			
			for each ( m in this.migrates ) 
			{
				m.reloadInstances( ) ; 
			}
		}
		
		/**
		 * take in list of dot seperated adn replace with '/'
		 * */
		public function allowedClassList(modifiedClassList:Array):void
		{
			// TODO Auto Generated method stub
			this.classList = [] ;
			var reg : RegExp = /\./gi
			for each ( var clazz : String in modifiedClassList ) 
			{
				clazz = clazz.replace( reg, '/' );
				classList.push( clazz ) ; 
			}
		}
	}
}