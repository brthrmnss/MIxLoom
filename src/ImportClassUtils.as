package 
{
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import org.mixingloom.patcher.MigrateFunctionsPatcher;
	
	public class ImportClassUtils
	{
		private var secAddDomain:ApplicationDomain;
		public var fxReturnedClasses:Function;
		private var classList:Array;
		private var lc:LoaderContext;
		
		public function init():void	{
		}
		
		static public function tryToImportClass(className : String, domain : ApplicationDomain):void
		{
			var dict : Dictionary = MigrateFunctionsPatcher.dictClass
			var reg : RegExp = /\./gi
			//get new prototype oldPrototype:Object
			var classObject_Orig: Object = ApplicationDomain.currentDomain.getDefinition(className)
			if ( classObject_Orig == null ) 
			{
				throw 'wtf ' + ' could not find old prototype '
			}
			import flash.utils.getDefinitionByName; 
			var classNameColon : String = className.replace( reg, ':')
			var classObject: Object = domain.getDefinition(className)
			var props : Array = dict[className]
			var newObj : Object = new classObject();
			var variables : Array = ImportClassUtils.getVariables(classObject)
			
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
				addFx_Forwarder( oldPrototype, prop, propRenamed, classObject) 
				
			}
			
			addFx_Forwarder_copyUp( oldPrototype, newPrototype ) 
			addFx_Forwarder_copyDown( oldPrototype, newPrototype ) 
			
			//oldPrototype[prop] = classObject.prototype[prop]
			newObj = new classObject(); 
		}
		
		/**
		 * 
		 * before each run copy my propes to u 
		 * */
		static function addFx_Forwarder_copyDown(oldPrototype:Object, newPrototype : Object):void
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
		
		static private function addFx_Forwarder_copyUp(oldPrototype:Object, newPrototype : Object):void
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
		
		static public function addFx_Forwarder( proto : Object, prop : String, propRenamed : String, newerClass : Object ) : void
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
		static public function getVariables(classObject:Object):Array
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
		/**
		 * get list of pvariable properties
		 * */
		static public function getClassInfo(classObject:Object):Object
		{
			import flash.utils.describeType; 
			var 	xml : XML = describeType(classObject);
			return xml;
		}
		/**
		 * get name of class i extend
		 * */
		static public function getClassExtends(classObject:Object): String
		{
			import flash.utils.describeType; 
			var 	xml : XML = describeType(classObject);
			var list : XMLList = xml..extendsClass
			for each ( var i : XML in list ) 
			{
				//if ( i.@type.indexOf('spark.comp') == -1 )
			}
			 list = xml.factory.children()

			var str : String = ''; 
			str =  list[0].@type
			return  str;
		}
 
		private function getClassDef2nd(className:String):Class
		{
			var classObject: Class = this.secAddDomain.getDefinition(className) as Class
			return classObject;
		}
		static public function getClassList(cat:String): Array
		{
			var imported:Array = [] 
			
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
			
			return imported; 
		}
		
		
	}
}