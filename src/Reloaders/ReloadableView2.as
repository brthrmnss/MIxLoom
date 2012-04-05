package Reloaders
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	/**
	 * Used for view componnets that can be reloaded...
	 * */
	public class ReloadableView2
	{
		static public var instances : Array = [] ; 
		static public var dict : Dictionary = new Dictionary(true); 
		static public var dict_ChildToInstance : Dictionary = new Dictionary(true); 
		
		/**
		 * pick and remove any instances ? ... what about strict typing form oparent? 
		 * ... we'll see ...
		 * */
		static public function check( className : String  ) : void
		{
			trace(debugName, 'check' ) 
			var instances : Array = dict[className] as Array
			if ( instances != null ) 
			{
				for each ( var instance : Object in instances ) 
				{
					if ( true == true )
					{
						//sparks only 
						instance.mxmlContent = []
						var proto : Object = getDefinitionByName(className ).prototype;  
						instance.fauxConstructor();
						
						import mx.core.mx_internal;
						use namespace mx_internal;
						
						var stuff : Array =instance.mx_internal::getMXMLContent()
						var lastChild : Object = stuff[stuff.length-1]
						lastChild.addEventListener( FlexEvent.CREATION_COMPLETE,  onCreationDone ) 
						dict_ChildToInstance[lastChild] = instance; 
					}
					else
					{
						/*instance.parent.removeChild( instance ) 
						var newInstance : Object = new newClass(); 
						instance.parent.addChildAt( newInstance as  DisplayObject, index   )*/
					}
				}
			}
		}
	 
		static public function onCreationDone( e : Event ) : void
		{
			var ct : Object = e.currentTarget; 
			var inst : Object = dict_ChildToInstance[ct]
			inst.dispatchEvent( new FlexEvent( FlexEvent.CREATION_COMPLETE, false, true ) ) ;
			ct.removeEventListener( FlexEvent.CREATION_COMPLETE,  onCreationDone ) 
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
		private static var debugName:String= 'ReloadableView2';
	}
}