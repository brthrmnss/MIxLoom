package 
{
	import Reloaders.ReloadableView;
	
	import com.adobe.serialization.json.JSON;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	
	import org.bytearray.explorer.SWFExplorer;
	import org.mixingloom.SwfContext;
	import org.mixingloom.byteCode.ByteParser;
	import org.mixingloom.byteCode.ModifiedByteLoader;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.patcher.MigrateFunctionsPatcher;
	import org.mixingloom.patcher.MigrateFunctionsPatcher2;
	import org.mixingloom.patcher.MigrateFunctionsPatcher3_Test;
	import org.mixingloom.patcher.MigrateFunctionsPatcher_Final;
	import org.mixingloom.patcher.RevealPrivatesPatcher;
	
	public class LoadSwc
	{
		private var secAddDomain:ApplicationDomain;
		public var fxReturnedClasses:Function;
		private var classList:Array;
		private var lc:LoaderContext;
		
		public function init():void	{
		}
		
		public function loadSwc(swc:String = null):void
		{
			// TODO Auto Generated method stub
			var rawSWC:FZip = new FZip();
			rawSWC.addEventListener(Event.COMPLETE, swcLoaded);
			//rawSWC.load(new URLRequest('../../lib/bin/SharedClass.swc'));//can he get oflders liek this?
			if ( swc == null ) 
			{
				swc = 'swcs/test.swc'
				swc = 'swcs/bin/EvalLib.swc'
			}
			rawSWC.load(new URLRequest(swc));
			
			// this class isn't loaded yet - this line is moved down to line #69
			// var t:Tracer = new Tracer();
		}
		
		
		private function swcLoaded(e:Event):void{
			e.target.removeEventListener(e.type, arguments.callee);
			
			var rawSWC:FZip = e.target as FZip;
			
			// this is our actual swf file in binary
			var codeSWF:FZipFile = rawSWC.getFileByName('library.swf');
			var swcCataalog:FZipFile = rawSWC.getFileByName('catalog.xml');
			var data:ByteArray = swcCataalog.content; //(swcCataalog);
			var cat : String = swcCataalog.getContentAsString(); 
			
			if ( mode_LoadIntoCurrentContext )
			{
				this.getClassList(cat); 
				//trace(data.toString());
				this.loadSwf(codeSWF)
			}
			else
			{
				this.getClassList(cat); 
				this.loadSwf_Modify(codeSWF  )
			}
			return;
			/*
			//rawSWC.getFileByName(
			// we'll use the Loader class to unpack the swf...
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoaded);
			
			// this is the magic! This tells the loader to bring the code in
			// the swf into our local code space instead of it's own little bubble
			var appDomain:ApplicationDomain = new ApplicationDomain();
			this.secAddDomain = appDomain; 
			//this.secAddDomain = ApplicationDomain.currentDomain; 
			//var context:LoaderContext = new LoaderContext(false, appDomain);
			var c:LoaderContext = new LoaderContext(false, appDomain )//ApplicationDomain.currentDomain);
			
			l.loadBytes(codeSWF.content, c);
			*/
		}
		
		private function loadSwf(codeSWF:FZipFile ):void
		{
			var swfContent : ByteArray = codeSWF.content; 
			
			this.modifySwfContent_AndLoadIntoContext( swfContent, classList ) 
			
			return
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoaded2);
			
			// this is the magic! This tells the loader to bring the code in
			// the swf into our local code space instead of it's own little bubble
			var appDomain:ApplicationDomain = new ApplicationDomain();
			this.secAddDomain = appDomain; 
			//this.secAddDomain = ApplicationDomain.currentDomain; 
			//var context:LoaderContext = new LoaderContext(false, appDomain);
			var c:LoaderContext = new LoaderContext(false, appDomain )//ApplicationDomain.currentDomain);
			
			l.loadBytes(swfContent, c)
		}
		
		private function modifySwfContent_AndLoadIntoContext(swfContent:ByteArray, classList:Array):void
		{
			// TODO Auto Generated method stub
			var parser : ByteParser = new ByteParser(); 
			
			var swfContext : SwfContext = new SwfContext()
			swfContext.originalUncompressedSwfBytes = parser.uncompressSwf( swfContent );;
			swfContent.position = 0 ; 
			swfContext.swfTags = parser.getAllSwfTags(swfContext.originalUncompressedSwfBytes)
			
			var reg : RegExp = /\./gi
			for each ( var className : String in this.classList ) 
			{
				var found : Boolean = false
				for each ( var fixablePath : String in reload_DirsInclude ) 
				{
					if ( className.indexOf( fixablePath ) == 0 ) 
					{
						found = true
					}
					
				}
				if ( found == false ) 
					continue
				var classNameColon : String = className.replace( reg, ':')
				/*var m : MigrateFunctionsPatcher = new MigrateFunctionsPatcher(className, '' )
				*/
				var m : MigrateFunctionsPatcher2 = new MigrateFunctionsPatcher2(classNameColon, '' )
				
				//var m : RevealPrivatesPatcher = new RevealPrivatesPatcher("blah:Foo", "getPrivateBar" )
				//.swfContext.swfTags = parser.getAllSwfTags(swfContent)
				m.apply( new InvocationType( InvocationType.INIT, '' ), swfContext ) 
				
				var m3 : MigrateFunctionsPatcher3_Test = new MigrateFunctionsPatcher3_Test(classNameColon, '' )
				m3.apply( new InvocationType( InvocationType.INIT, '' ), swfContext ) 
				
				var props : Array = MigrateFunctionsPatcher2.dictClass[className]
				for each ( var prop : String in props ) 
				{
					var m2 : RevealPrivatesPatcher = new RevealPrivatesPatcher(classNameColon, 'inject_'+prop )
					m2.apply( new InvocationType( InvocationType.INIT, '' ), swfContext ) 
				}
			}
			
			var modifier:ModifiedByteLoader = new ModifiedByteLoader();
			lc = new LoaderContext(); 
			this.secAddDomain = new ApplicationDomain(); 
			lc.applicationDomain = this.secAddDomain;
			if ( modeLoadIntoSameDomain ) 
			{
				modifier.loaderContext// = lc// this.secAddDomain.;
			}
			else
			{
				modifier.loaderContext = lc// this.secAddDomain.;
			}
			modifier.setCallBack( invokeCallBack );
			modifier.applyModificiations( swfContext );
			
			return;
		}
		
		/**
		 * Seconary version above functions, 
		 * only modifies swfs, does not load them 
		 * */
		private function loadSwf_Modify(codeSWF:FZipFile ):void
		{
			var swfContent : ByteArray = codeSWF.content; 
			
			this.modifySwfContent( swfContent, classList ) 
			
			return
		}
		
		private function modifySwfContent(swfContent:ByteArray, classList:Array):void
		{
			// TODO Auto Generated method stub
			var parser : ByteParser = new ByteParser(); 
			
			var swfContext : SwfContext = new SwfContext()
			swfContext.originalUncompressedSwfBytes = parser.uncompressSwf( swfContent );;
			swfContent.position = 0 ; 
			swfContext.swfTags = parser.getAllSwfTags(swfContext.originalUncompressedSwfBytes)
			
			var reg : RegExp = /\./gi
			
			var m2 : MigrateFunctionsPatcher_Final = new MigrateFunctionsPatcher_Final(  reload_DirsInclude, true ) ; 
			m2.allowedClassList( this.modifiedClassList ) ; 
			m2.apply( null, swfContext ) ; 
			m2.loadAndPatch(swfContext); 
			return;
		}
		
		private function invokeCallBack(o:Object):void
		{
			
			for each ( var className : String in this.classList ) 
			{
				var cl : Class = this.getClassDef2nd( className ) ; 
				var extendsClass  : String = ImportClassUtils.getClassExtends( cl ) ; 
				if ( extendsClass.indexOf('spark.comp') == 0 ) 
				{
					ReloadableView.check(className, cl)
					continue; 
				}
				ImportClassUtils.tryToImportClass( className, this.secAddDomain   ) 
			}
			
			//this.testBlahFoo()
		}
		
		/**
		 * get class def from 2nd class
		 * */
		private function getClassDef2nd(className:String):Class
		{
			var classObject: Class = this.secAddDomain.getDefinition(className) as Class
			return classObject;
		}
		
		public function testBlahFoo() : void
		{
			var cu : Object = ApplicationDomain.currentDomain; 
			var newClass : Object = lc.applicationDomain.getDefinition('blah.Foo')
			var origClass : Object = ApplicationDomain.currentDomain.getDefinition('blah.Foo')
			var done : String = ''; 
			var newObjFromOrigClass : Object = new origClass(); 
			newObjFromOrigClass.getPrivateBar2('newer?')		
			var newObjFromReplacementClass : Object = new newClass()
			
			var x : Object = MigrateFunctionsPatcher2.dictClass; 
			//		i['getPrivateBar']()
			//var dbg : Array =[newObjFromReplacementClass['inject_getPrivateBar2'] ,  i['getPrivateBar2'] ]
			newObjFromReplacementClass['inject_getPrivateBar2']('g')
			newObjFromOrigClass.inject_getPrivateBar2('old')
			this.postProcess( )
			newObjFromOrigClass.inject_getPrivateBar2('newer?')		
			//orig.prototype.
			//  newObjFromOrigClass  = new orig(); 
			newObjFromOrigClass.getPrivateBar2('newer?')		
			newObjFromReplacementClass.inject_getPrivateBar2('newer?')			
			return; 
		}
		
		/**
		 * create prototype functions for each class
		 * */
		private function postProcess():void
		{
			var dict : Dictionary = MigrateFunctionsPatcher.dictClass
			var reg : RegExp = /\./gi
			for each ( var className : String in this.classList ) 
			{
				//get new prototype oldPrototype:Object
				var classObject_Orig: Object = ApplicationDomain.currentDomain.getDefinition(className)
				if ( classObject_Orig == null ) 
				{
					throw 'wtf ' + ' could not find old prototype '
				}
				import flash.utils.getDefinitionByName; 
				var classNameColon : String = className.replace( reg, ':')
				var classObject: Object = this.lc.applicationDomain.getDefinition(className)
				var props : Array = dict[className]
				var newObj : Object = new classObject();
				var variables : Array = this.getVariables(classObject)
				
				var oldPrototype : Object = classObject_Orig.prototype; 
				var  newPrototype : Object = classObject.prototype; 
				
				newPrototype.variables = variables; 
				
				for each ( var prop : String in props ) 
				{
					var propRenamed : String = 'inject_'+prop 
					classObject.prototype
					trace(newObj[propRenamed], prop, propRenamed)
					//skip variables
					if ( variables.indexOf( propRenamed ) != -1 ) 
					{
						classObject.prototype[prop] = classObject.prototype[propRenamed] 
						continue;
					}
					
					//this.addFx( classObject.prototype, prop, propRenamed ) 
					//add the prop as a forwarder
					this.addFx_Forwarder( oldPrototype, prop, propRenamed, classObject) 
					
				}
				
				this.addFx_Forwarder_copyUp( oldPrototype, newPrototype ) 
				this.addFx_Forwarder_copyDown( oldPrototype, newPrototype ) 
				
				//oldPrototype[prop] = classObject.prototype[prop]
				newObj = new classObject(); 
			}
			
			
		}
		/**
		 * 
		 * before each run copy my propes to u 
		 * */
		private function addFx_Forwarder_copyDown(oldPrototype:Object, newPrototype : Object):void
		{
			//copying functions
			oldPrototype.copyDown = function():void
			{
				for each ( var variable : String in oldPrototype.variables ) 
				{
					if( newPrototype.variables.indexOf( variable ) != -1 ) //if ( this.forward.hasOwnProperty(variable) ) 
						this.forward[variable] = this[variable] 
				}
			}
		}
		
		private function addFx_Forwarder_copyUp(oldPrototype:Object, newPrototype : Object):void
		{
			oldPrototype.copyUp = function():void
			{
				for each ( var variable : String in oldPrototype.variables ) 
				{
					if( newPrototype.variables.indexOf( variable ) != -1 ) //if ( this.forward.hasOwnProperty(variable) ) 
						this[variable] = this.forward[variable] 
				}
			}
		}
		/**
		 * recreate context so we can get new propRenamed vars each time 
		 * */
		public function addFx( proto : Object, prop : String, propRenamed : String ) : void
		{
			propRenamed = propRenamed.toString()
			var fxMethod : Function = function (...args):Object
			{
				return this[propRenamed.toString()].apply(this, args)
			}
			proto[prop] = fxMethod
			fxMethod = null; 
		}
		
		public function addFx_Forwarder( proto : Object, prop : String, propRenamed : String, newerClass : Object ) : void
		{
			propRenamed = propRenamed.toString()
			var fxMethod : Function = function (...args):Object
			{
				if ( this.forward == null || this.forward.prototype != newerClass.prototype )
					this.forward = new newerClass()
				this.copyDown()
				
				var result : Object =  this.forward[propRenamed.toString()].apply(this, args)
				this.copyUp()
				return result; 
			}
			proto[prop] = fxMethod
			//proto[prop] = null
			fxMethod = null; 
		} 
		
		
		/**
		 * get list of pvariable properties
		 * */
		public function getVariables(classObject:Object):Array
		{
			import flash.utils.describeType; 
			var 	xml : XML = describeType(classObject);
			var list : XMLList = xml..variable
			var variables : Array = [] ;
			for each ( var i : Object in list ) 
			{
				var ooo : Object = i.@name.toString()
				variables.push(ooo)
			}
			return variables;
		}
		
		protected function swfLoaded2(e:Event):void
		{
			e.target.removeEventListener(e.type, arguments.callee);
			//trace('arguments?', arguments)
			// the swf is ready to go - now we can work with the Tracer type!
			//var t:Tracer = new Tracer();
			var loader : Loader = e.target as Loader
			var loaderInfo : LoaderInfo = e.currentTarget as LoaderInfo; 
			//return;
			var by : ByteArray = loaderInfo.bytes; 
			by.position = 0; 
			var explorer:SWFExplorer = new SWFExplorer();
			var definitions:Array = explorer.parse(by);
			
			// outputs : org.groove.Funk,org.funk.Soul,org.groove.Jazz
			trace( definitions );
			
			// outputs : org.groove.Funk,org.funk.Soul,org.groove.Jazz
			trace( explorer.getDefinitions() );				
			
		}
		
		private function getClassList(cat:String):void
		{
			var imported:Array = [] 
			this.classList = imported
			// TODO Auto Generated method stub
			var xml : XML = new XML(cat); 
			var xmlli : Object = xml.descendants('script')
			var dbg : Array = [xml.libraries.library.descendants('*'),xml.descendants()]
			var xmlli2 : Object = xml..script
			for each ( var i : XML in xml.descendants() ) 
			{
				var name : String = i.@name
				var nl : String = 	i.localName()
				if ( nl != 'script' ) 
					continue; 
				if ( name.indexOf('_flash_display_Sprite') != -1 )
				{
					continue; 
				}
				name = name.replace("/", '.' )
				if ( name.indexOf('spark.') == 0 ) 
					continue; 
				if ( name.indexOf('mx.') == 0 ) 
					continue; 
				if ( name.indexOf('flashx.') == 0 ) 
					continue; 				
				imported.push( name ) 
			}
			if ( this.fxReturnedClasses != null ) 
				this.fxReturnedClasses(imported ) 
		}
		
		private function swfLoaded(e:Event):void{
			
			e.target.removeEventListener(e.type, arguments.callee);
			//trace('arguments?', arguments)
			// the swf is ready to go - now we can work with the Tracer type!
			//var t:Tracer = new Tracer();
			
			
			var loader : Loader = e.target as Loader
			var loaderInfo : LoaderInfo = e.currentTarget as LoaderInfo; 
			
			//return;
			var by : ByteArray = loaderInfo.bytes; 
			by.position = 0; 
			var explorer:SWFExplorer = new SWFExplorer();
			var definitions:Array = explorer.parse(by);
			
			// outputs : org.groove.Funk,org.funk.Soul,org.groove.Jazz
			trace( definitions );
			
			// outputs : org.groove.Funk,org.funk.Soul,org.groove.Jazz
			trace( explorer.getDefinitions() );				
			
			//var Bar:Class =this.secAddDomain.getDefinition( "test.EvalCmd2")as Class;		
			// var Bar:Class =this.secAddDomain.getDefinition( "test.EvalCmd2")as Class;					 
			//var bar:Object = new Bar();
			//this.prev.push( bar ) 
			
			//var ev : EvalCmd2 = new EvalCmd2(); 
			//this.prev.push( ev ) 
		}
		
		
		
		public function setupActivate(ui:UIComponent):void
		{
			// TODO Auto Generated method stub
			ui.addEventListener( 'activate', this.onActivate ) ; 
		}
		
		/**
		 * Start of remoting requests
		 * */
		protected function onActivate(event:Event):void
		{
			//this.loadUpdatedSwf('' )
				this.loadModifiedClassList(); 
		}
		
		///upload and get file 
		public var loaderUpdatedSwf : URLLoader = new URLLoader()
		public var loader_GetModifiedFiles : URLLoader; // = new URLLoader()
		public var urlServerUpdate  : String = 'http://localhost:9001/update_dir'//?command_only=false&test=true'; 
		private var folderUpdateSrcPath : String = "G:/work2/flex4/test/MixingLoom_Mine/src";
		/**
		 * Flag if true will load it into the same doman ...
		 * */
		private var modeLoadIntoSameDomain:Boolean=false;
		static public var reload_DirsInclude: Array =  [ 'blahx', 'views', 'fedres.dashboard'] ;
		static public var reload_DirsExclude: Array =  [ 'org.robotlegs'] ;
		//static public var fixablePaths : Array = ['blah', 'views']; 
		/**
		 * If true will try to load swc's swf into the current context....
		 * */
		private var mode_LoadIntoCurrentContext:Boolean;
		private var lastReloadTime:Number;
		/**
		 * Flag, if true will reload every class in folder each time ...
		 * */
		private var mode_TestMode:Boolean;
		private var debugName:String = 'LoadSwc';
		/**
		 * Stores classes that were modified since last activation 
		 * ... 
		 * only these classes shouuld be loaded
		 * */
		private var modifiedClassList:Array;
		
		
		
		/**
		 * Step 1: see if any classes need to modified
		 * */
		public function loadModifiedClassList( ):void
		{
			if ( loader_GetModifiedFiles == null ) 
			{
				loader_GetModifiedFiles = new URLLoader()
				loader_GetModifiedFiles.addEventListener(Event.COMPLETE, onGetModifiedClassesList);
			}
			var req : URLRequest = new URLRequest(urlServerUpdate) 
			var vars : URLVariables = new URLVariables()
			vars.include_dirs =JSON.encode( reload_DirsInclude ) 
			vars.test = this.mode_TestMode
			var reg :  RegExp = new RegExp("\\", 'gi' )
			reg  = /\\/gi
			var t : String = this.folderUpdateSrcPath; 
			t=t.replace( reg, '/' )
			t=t.replace( reg, '/' )
			vars.dir = t
				vars.files_only = true
			vars.rand=Math.random()*90000
			var currentTime : Number = new Date().getTime(); 
			var loadedOnce : Boolean =  ! isNaN(this.lastReloadTime)  
			var dbg : Array = [this.lastReloadTime  + 1000  -   currentTime]
			if ( loadedOnce &&  this.lastReloadTime  + 2000 >  currentTime ) 
			{
				tracex( 'time too quick on reload...'); 
				return; 
			}
			this.lastReloadTime = currentTime; 
			//vars. 
			req.data = vars 
			loader_GetModifiedFiles.dataFormat=URLLoaderDataFormat.BINARY;
			loader_GetModifiedFiles.load(req); 
			tracex( 'requesting class list...'); 
		}
		
		
		
		public function onGetModifiedClassesList(e:Event) : void
		{
			var str :  String = e.currentTarget.data; 
			trace(str)
			if ( str == '' || str == null || str == '""' ) 
			{
				tracex ('empty'); 
				return ;//empty
			}
			var o : Array = JSON.decode( str ) as Array; 
			if (   o.length == 0 )
			{
				tracex ('empty'); 
				return ;//empty
			}
			this.modifiedClassList = o; 
			this.loadUpdatedSwf('' )
			return;
			
		}
		
		
		/**
		 * Loads swf by examining it
		 * */
		public function loadUpdatedSwf(swc:String = null):void
		{
			loaderUpdatedSwf.addEventListener(Event.COMPLETE, onUpdatedSwfLoaded);
			var req : URLRequest = new URLRequest(urlServerUpdate) 
			var vars : URLVariables = new URLVariables()
			vars.include_dirs =JSON.encode( reload_DirsInclude ) 
			vars.test = this.mode_TestMode
			var reg :  RegExp = new RegExp("\\", 'gi' )
			reg  = /\\/gi
			var t : String = this.folderUpdateSrcPath; 
			t=t.replace( reg, '/' )
			t=t.replace( reg, '/' )
			vars.dir = t
			vars.rand=Math.random()*90000
			/*var currentTime : Number = new Date().getTime(); 
			var loadedOnce : Boolean =  ! isNaN(this.lastReloadTime)  
			var dbg : Array = [this.lastReloadTime  + 1000  -   currentTime]
			if ( loadedOnce &&  this.lastReloadTime  + 2000 >  currentTime ) 
			{
				tracex( 'time too quick on reload...'); 
				return; 
			}
			this.lastReloadTime = currentTime; */
			//vars. 
			req.data = vars 
			loaderUpdatedSwf.dataFormat=URLLoaderDataFormat.BINARY;
			loaderUpdatedSwf.load(req); 
			tracex( 'reloading...'); 
			import flash.utils.setTimeout; 
			//setTimeout( function():void{loaderUpdatedSwf.load(req);}, 1);
			// this class isn't loaded yet - this line is moved down to line #69
			// var t:Tracer = new Tracer();
			
			/*
			public function loadSwc(swc:String = null):void
			{
			// TODO Auto Generated method stub
			var rawSWC:FZip = new FZip();
			rawSWC.addEventListener(Event.COMPLETE, swcLoaded);
			//rawSWC.load(new URLRequest('../../lib/bin/SharedClass.swc'));//can he get oflders liek this?
			if ( swc == null ) 
			{
			swc = 'swcs/test.swc'
			swc = 'swcs/bin/EvalLib.swc'
			}
			rawSWC.load(new URLRequest(swc));
			
			// this class isn't loaded yet - this line is moved down to line #69
			// var t:Tracer = new Tracer();
			}
			*/
		}
		
		
		
		
		
		
		public function onUpdatedSwfLoaded(e:Event) : void
		{
			var data : ByteArray = e.currentTarget.data; 
			//e.target.removeEventListener(e.type, arguments.callee);
			if (   data.length == 0 )
			{
				tracex ('empty'); 
				return ;//empty
			}
			
			
			// TODO Auto Generated method stub
			var rawSWC:FZip = new FZip();
			rawSWC.addEventListener(Event.COMPLETE, swcLoaded);
			rawSWC.loadBytes( data ) ; 
			
			
			
			
			return;
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, updatedSwfLoaded);
			
			// this is the magic! This tells the loader to bring the code in
			// the swf into our local code space instead of it's own little bubble
			var appDomain:ApplicationDomain = new ApplicationDomain();
			this.secAddDomain = appDomain; 
			//this.secAddDomain = ApplicationDomain.currentDomain; 
			//var context:LoaderContext = new LoaderContext(false, appDomain);
			var c:LoaderContext = new LoaderContext(false, appDomain )//ApplicationDomain.currentDomain);
			
			l.loadBytes(data, c);
			
		}
		
		private function tracex(... rest ):void
		{
			// TODO Auto Generated method stub
			rest.unshift( this.debugName ) ;
			trace.apply( this, rest ) 	
		}		
		
		/**
		 * Loads the swf
		 * */
		public function loadUpdatedSwf_IntoContext(swc:String = null):void
		{
			mode_LoadIntoCurrentContext = true; 
			loaderUpdatedSwf.addEventListener(Event.COMPLETE, onUpdatedSwfLoaded_IntoContext);
			var req : URLRequest = new URLRequest(urlServerUpdate) 
			var vars : URLVariables = new URLVariables()
			vars.include_dirs =JSON.encode( reload_DirsInclude ) 
			var reg :  RegExp = new RegExp("\\", 'gi' )
			reg  = /\\/gi
			var t : String = this.folderUpdateSrcPath; 
			t=t.replace( reg, '/' )
			t=t.replace( reg, '/' )
			vars.dir = t
			vars.rand=Math.random()*90000
			//vars. 
			req.data = vars 
			loaderUpdatedSwf.dataFormat=URLLoaderDataFormat.BINARY;
			loaderUpdatedSwf.load(req);
			import flash.utils.setTimeout; 
			//setTimeout( function():void{loaderUpdatedSwf.load(req);}, 1);
			// this class isn't loaded yet - this line is moved down to line #69
			// var t:Tracer = new Tracer();
			
			/*
			public function loadSwc(swc:String = null):void
			{
			// TODO Auto Generated method stub
			var rawSWC:FZip = new FZip();
			rawSWC.addEventListener(Event.COMPLETE, swcLoaded);
			//rawSWC.load(new URLRequest('../../lib/bin/SharedClass.swc'));//can he get oflders liek this?
			if ( swc == null ) 
			{
			swc = 'swcs/test.swc'
			swc = 'swcs/bin/EvalLib.swc'
			}
			rawSWC.load(new URLRequest(swc));
			
			// this class isn't loaded yet - this line is moved down to line #69
			// var t:Tracer = new Tracer();
			}
			*/
		}
		
		public function onUpdatedSwfLoaded_IntoContext(e:Event) : void
		{
			var data : ByteArray = e.currentTarget.data; 
			//e.target.removeEventListener(e.type, arguments.callee);
			if (   data.length == 0 )
			{
				trace('empty'); 
				return ;//empty
			}
			
			
			// TODO Auto Generated method stub
			var rawSWC:FZip = new FZip();
			rawSWC.addEventListener(Event.COMPLETE, swcLoaded);
			rawSWC.loadBytes( data ) ; 
			
			
			
			
			return;
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, updatedSwfLoaded);
			
			// this is the magic! This tells the loader to bring the code in
			// the swf into our local code space instead of it's own little bubble
			var appDomain:ApplicationDomain = new ApplicationDomain();
			this.secAddDomain = appDomain; 
			//this.secAddDomain = ApplicationDomain.currentDomain; 
			//var context:LoaderContext = new LoaderContext(false, appDomain);
			var c:LoaderContext = new LoaderContext(false, appDomain )//ApplicationDomain.currentDomain);
			
			l.loadBytes(data, c);
			
		}
		
		private function updatedSwfLoaded(codeSWF:FZipFile ):void
		{
			var swfContent : ByteArray = codeSWF.content; 
			
			this.modifySwfContent( swfContent, classList ) 
			
			return
		}
	}
}