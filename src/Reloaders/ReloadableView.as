package Reloaders
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IVisualElement;
	
	import spark.components.Group;
	
	/**
	 * Used for view componnets that can be reloaded...
	 * */
	public class ReloadableView
	{
		static public var instances : Array = [] ; 
		static public var dict : Dictionary = new Dictionary(true); 
		/**
		 * pick and remove any instances ? ... what about strict typing form oparent? 
		 * ... we'll see ...
		 * */
		static public function check( className : String , newClass : Object ) : void
		{
			trace(debugName, 'check' ) 
			var instances : Array = dict[className] as Array
			if ( instances != null ) 
			{
				for each ( var instance : Object in instances ) 
				{
					var index  :  int = instance.parent.getChildIndex( instance )
					var p : DisplayObject = instance.parent; 
					if ( p.hasOwnProperty('removeElement' ) ) 
					{
						instance.mxmlContent = getNewMxml(newClass)
						/*
						//instances.splice(instances.indexOf(instance) ,1) 
						var p2 : Group = instance.parent as Group
						newInstance = new newClass();
						
						import mx.core.mx_internal;
						use namespace mx_internal;
						var stuff : Array =newInstance.mx_internal::getMXMLContent()
						var newMxml : Array = [] ; 
						for each ( var mxmlThing : Object in stuff ) 
						{
						var type : Object = flash.utils.getDefinitionByName( flash.utils.getQualifiedClassName( mxmlThing ) )
						try
						{
						//spark.skins.spark.TextInputSkin
						var skinClass : Object = flash.utils.getDefinitionByName( flash.utils.getQualifiedClassName( mxmlThing )+'Skin' )
						} 
						catch(error:Error) 
						{
						
						}
						
						var replacement : Object = new type(); 
						
						var vars : Array = ImportClassUtilsBasic.getVariables2( type )
						var skip : Array = ['height', 'width'] 
						for each ( var prop : String in vars ) 
						{
						if ( skip.indexOf(prop) != -1 &&  isNaN(mxmlThing[prop] )) 
						continue; 
						try
						{
						trace(prop,mxmlThing[prop] )
						replacement[prop] = mxmlThing[prop]
						
						} 
						catch(error:Error) 
						{
						//...
						trace('could not copy', prop ) ; 
						}
						
						}
						if ( skinClass != null ) 
						replacement.setStyle("skinClass", skinClass ) ; 
						newMxml.push( replacement ) ; 
						
						if ( mxmlThing.children() ) 
						{
						
						}
						}
						instance.mxmlContent = newMxml
						*/
						continue; 
						p2.removeElement( instance as IVisualElement ) 
						var vvv : IVisualElement = newInstance as IVisualElement
						//var load : Loader = new loa
						p2.parentApplication.addElement( newInstance ) 
						continue; 
						vvv.owner = p2
						p2.addElementAt( newInstance as IVisualElement, index   )
					}
					else
					{
						instance.parent.removeChild( instance ) 
						var newInstance : Object = new newClass(); 
						instance.parent.addChildAt( newInstance as  DisplayObject, index   )
					}
				}
			}
		}
		/**
		 * mxmlContentList --- how ot ge the construction for nested?
		 * */
		static private   function getNewMxml(newClass:Object, mxmlContentList : Array = null ):Array
		{
			if (mxmlContentList==null) 
			{
				var newInstance :Object = new newClass();
				var stuff : Array =newInstance.mx_internal::getMXMLContent()
			}
			else
			{
				stuff = mxmlContentList
			}
			//instances.splice(instances.indexOf(instance) ,1) 
			
			
			import mx.core.mx_internal;
			use namespace mx_internal;
			
			var newMxml : Array = [] ; 
			for each ( var mxmlThing : Object in stuff ) 
			{
				var type : Object = flash.utils.getDefinitionByName( flash.utils.getQualifiedClassName( mxmlThing ) )
				try
				{
					//spark.skins.spark.TextInputSkin
					var skinClass : Object = flash.utils.getDefinitionByName( flash.utils.getQualifiedClassName( mxmlThing )+'Skin' )
				} 
				catch(error:Error) 
				{
					
				}
				
				var replacement : Object = new type(); 
				
				var vars : Array = ImportClassUtilsBasic.getVariables2( type )
				var skip : Array = ['height', 'width'] 
				for each ( var prop : String in vars ) 
				{
					if ( skip.indexOf(prop) != -1 &&  isNaN(mxmlThing[prop] )) 
						continue; 
					try
					{
						trace(prop,mxmlThing[prop] )
						replacement[prop] = mxmlThing[prop]
						
					} 
					catch(error:Error) 
					{
						//...
						trace('could not copy', prop ) ; 
					}
					
				}
				replacement['height'] = mxmlThing['explicitHeight']
				replacement['width'] = mxmlThing['explicitWidth']
				if ( skinClass != null ) 
					replacement.setStyle("skinClass", skinClass ) ; 
				newMxml.push( replacement ) ; 
				
				//imports children ...
				import mx.core.mx_internal;
				use namespace mx_internal;
				
				import mx.core.mx_internal;
				use namespace mx_internal;
				try
				{
					var nestedChildren : Array =mxmlThing.mx_internal::getMXMLContent()
				} 
				catch(error:Error) 
				{
					
				}
				/*if ( mxmlThing.mx_internal::hasOwnProperty('mxmlContent') ) 
				{*/
					
				/*}*/
				//var otherNameSpace : Object = flash.utils.getDefinitionByName( flash.utils.getQualifiedClassName( mxmlThing ) )
				if ( nestedChildren != null && nestedChildren.length > 0 ) 
				{
					replacement.mxmlContent = getNewMxml(null,  nestedChildren )
				}
			}
			return newMxml;
		}
		static public function add(o : Object ) : void{
			var type :  String = flash.utils.getQualifiedClassName( o ) ;
			type = type.replace('::', '.' ) 
			var instances : Array = dict[o] as Array 
			if ( instances == null ) 
			{
				instances = []
				dict[type] = instances
			}
			instances.push( o ) 
		}
		private static var debugName:String= 'ReloadableView';
	}
}