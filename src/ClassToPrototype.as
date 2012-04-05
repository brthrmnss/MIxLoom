package 
{
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	import org.mixingloom.patcher.MigrateFunctionsPatcher;
	
	public class ClassToPrototype
	{
		/**
		 * 
		 * On first tim class loaded, set the current variables to be used (for later)
		 * make protptye methods that refer to renamed class methods 
		 * variable names? can NOT reroute them so ...
		 * 
		 * how are opcodes still working with variable names being changed???
		 * 
		 * dict  - classNames as Strings to methods to replace
		 * */ 
		
		public function convertIntro( dict :Dictionary ) : void
		{
			
			for ( var name : String in dict ) 
			{
				var classObject: Object = ApplicationDomain.currentDomain.getDefinition(name)
				var props : Array = dict[name]
				var newObj : Object = new classObject(); 
	 
				var variables : Array = ImportClassUtilsBasic.getVariables(classObject)
					//store variables on prototype for next migration
				classObject.prototype.variables = variables
				for each ( var prop : String in props ) 
				{
					var propRenamed : String = 'inject_'+prop 
					classObject.prototype
					//trace(newObj[propRenamed], prop, propRenamed)
					 
					if ( variables.indexOf( propRenamed ) != -1 ) 
					{
						//say not to properties to prevent collisions?
						/* classObject.prototype[prop+'='] = function(i:int):void
						{
						trace('hit tracer2'); 
						this['inject_'+prop] = 1
						}
						classObject.prototype['set '+prop] = function(i:int):void
						{
						trace('hit tracer'); 
						this['inject_'+prop] = 1
						} */
						//set it to the old place since i couldn't prevent Patcher from injecting the variables /// from doign that ...
						classObject.prototype[prop] = classObject.prototype[propRenamed] 
						continue;
					}
					 
					this.addFx( classObject.prototype, prop, propRenamed ) 
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
		
		
		
		
		
		
		
		
		
		
	}
}