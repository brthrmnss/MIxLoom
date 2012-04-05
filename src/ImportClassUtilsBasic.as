package 
{
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	public class ImportClassUtilsBasic
	{
		private var secAddDomain:ApplicationDomain;
		public var fxReturnedClasses:Function;
		private var classList:Array;
		private var lc:LoaderContext;
		
		public function init():void	{
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
		static public function getVariables2(classObject:Object):Array
		{
			import flash.utils.describeType; 
			var 	xml : XML = describeType(classObject);
			var list : XMLList = xml..variable
			var variables : Array = [] ;
			for each ( var i : Object in list ) 
			{
				if ( i.@type.toString().indexOf('::') != -1 ) // != 'readwrite' )
					continue; 				
				var ooo : Object = i.@name.toString()
				variables.push(ooo)
			}
			
			list = xml..accessor
			for each (   i    in list ) 
			{
				if ( i.@access != 'readwrite' )
					continue; 
				//only basic types ..
				if ( i.@type.toString().indexOf('::') != -1 ) // != 'readwrite' )
					continue; 
				ooo  = i.@name.toString()
				variables.push(ooo)
			}
			
			return variables;
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