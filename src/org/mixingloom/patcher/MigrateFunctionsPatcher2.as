/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/23/11
 * Time: 1:34 PM
 */
package org.mixingloom.patcher
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import mx.messaging.channels.StreamingAMFChannel;
	
	import org.as3commons.bytecode.abc.ConstantPool;
	import org.as3commons.bytecode.abc.IConstantPool;
	import org.as3commons.bytecode.abc.LNamespace;
	import org.as3commons.bytecode.abc.Multiname;
	import org.as3commons.bytecode.abc.MultinameG;
	import org.as3commons.bytecode.abc.QualifiedName;
	import org.as3commons.bytecode.abc.TraitInfo;
	import org.as3commons.bytecode.abc.enum.NamespaceKind;
	import org.as3commons.bytecode.io.AbcDeserializer;
	import org.as3commons.bytecode.tags.DoABCTag;
	import org.as3commons.bytecode.util.AbcSpec;
	import org.bytearray.explorer.SWFExplorer;
	import org.mixingloom.SwfContext;
	import org.mixingloom.SwfTag;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.managers.PatchManager;
	import org.mixingloom.utils.ByteArrayUtils;
	import org.mixingloom.utils.HexDump;
	
	
	public class MigrateFunctionsPatcher2 extends AbstractPatcher {
		
		static public var dictClass : Dictionary = new Dictionary(true); 
		/**
		 * need to know name of loaded swfs or something 
		 * */
		static public var Count : int = 0 ;
		/**
		 * version of class name with dots
		 * */
		private var classNameDot:String;
		
		public var className:String;
		
		public var propertyOrMethodName:String;
		
		public function MigrateFunctionsPatcher2(className:String, propertyOrMethodName:String)
		{
			this.className = className;
			this.classNameDot = className.replace( new RegExp(':','gi'), '.' ) ; 
			this.propertyOrMethodName = propertyOrMethodName;
		}
		
		override public function apply( invocationType:InvocationType, swfContext:SwfContext ):void {
			/*		Count++
			if ( Count < 1 ) 
			return
			var by : ByteArray = PatchManager.Swf; 
			by.position = 0; 
			var explorer:SWFExplorer = new SWFExplorer();
			var definitions:Array = explorer.parse(by);
			
			// outputs : org.groove.Funk,org.funk.Soul,org.groove.Jazz
			trace( definitions );
			
			// outputs : org.groove.Funk,org.funk.Soul,org.groove.Jazz
			trace( explorer.getDefinitions() );
			*/
			
			for each (var swfTag:SwfTag in swfContext.swfTags)
			{
				//trace(swfTag.type);
				if (swfTag.type == DoABCTag.TAG_ID)
				{
					
					// skip the flags
					swfTag.tagBody.position = 4;
					
					var abcStartLocation:uint = 4;
					while (swfTag.tagBody.readByte() != 0)
					{
						abcStartLocation++;
					}
					abcStartLocation++; // skip the string byte terminator
					
					var startOfConstPoolPosition:uint = abcStartLocation + 4;
					
					swfTag.tagBody.position = 0;
					
					var abcDeserializer:AbcDeserializer = new AbcDeserializer(swfTag.tagBody);
					swfTag.tagBody.position = startOfConstPoolPosition;
					var cp:IConstantPool = new ConstantPool();
					abcDeserializer.deserializeConstantPool(cp);
					//is it a class? if so string position is first /2 in string pool 
					var pos_ClassName:int = cp.getStringPosition(className);
					//these are in namespace pool as well 
					var pos_Forbiddden:int = cp.getStringPosition('http://adobe.com/AS3/2006/builtin')		
					var pos_Forbiddden2:int = cp.getMultinamePositionByName('http://www.adobe.com/2006/flex/mx/internal')		
					if ( pos_ClassName > -1 && pos_ClassName < 4 && pos_Forbiddden == -1 ) 
					{
						trace('class here'); 
					}
					else
					{
						continue; 
					}
					
					//get all properties 
					//add all native flex/flash types //check against those defined in another namespace?
					//i don't think xml is in the strings? 
					var props : Array = this.getProps( cp ) ; 
					//this.listNamePool(cp.multinamePool) 
					//this.listNamePool(cp.) 
					
					//clean up private names
					props = this.cleanUpPropertyNames( props ) 
					//wiht each property store in static some we can reginerate
					dictClass[this.classNameDot] = props
					//all private properties need to be made public
					//replace strings in string lookup table 
					this.replaceProps2( props, swfTag, cp ) 
					 continue; 
					
					// search the multinamePool for the location of the property or method
					for (var i:uint = 0; i < cp.multinamePool.length; i++) 
					{
						var item : Object = cp.multinamePool[i]
						if ( item is QualifiedName) 
						{
							var qn:QualifiedName = cp.multinamePool[i];
						}
						else
						{
							continue;
						}
						// trace('name', qn.nameSpace.name, qn.name ) ; 
						if ( (qn.nameSpace.kind == NamespaceKind.PRIVATE_NAMESPACE) && 
							((qn.nameSpace.name == LNamespace.ASTERISK.name) ||
								(qn.nameSpace.name == LNamespace.PUBLIC.name) ||
								(qn.nameSpace.name == className)) )
						{ 
							trace('accept', qn.name , qn.fullName) ; 
							var nsppos:int = cp.getNamespacePosition(qn.nameSpace);
							var sppos:int = cp.getStringPosition(qn.name);
							
							// create a bytearray the should match the constant pool private qname for the property or method
							var origBA:ByteArray = new ByteArray();
							origBA.writeByte(0x07); // qname
							AbcSpec.writeU30(nsppos, origBA);
							AbcSpec.writeU30(sppos, origBA);
							
							// create a replacement bytearray that uses the public namespace for this qname
							var repBA:ByteArray = new ByteArray();
							repBA.writeByte(0x07); // qname
							AbcSpec.writeU30(cp.getNamespacePosition(LNamespace.PUBLIC), repBA);
							AbcSpec.writeU30(sppos, repBA);
							
							repBA = new ByteArray();
							repBA.writeByte(0x07); // qname
							AbcSpec.writeU30(cp.getNamespacePosition(LNamespace.PUBLIC), repBA);
							AbcSpec.writeU30(sppos, repBA);							
							
							// replace the qname in the constant pool
							swfTag.tagBody = ByteArrayUtils.findAndReplaceFirstOccurrence(swfTag.tagBody, origBA, repBA);
							
							//----------------------------------------------------------
							var fxPosition:int = cp.getStringPosition(qn.nameSpace.name+'/'+qn.nameSpace.kind.description+':'+propertyOrMethodName);
							var fxPosition2:int = cp.getStringPosition(propertyOrMethodName);
							//var sppos:int = cp.getStringPosition(qn.name);
							
							var originalString:String = ''+propertyOrMethodName
							var replacementString:String = 'inject_'+propertyOrMethodName
							
							var searchByteArray:ByteArray = new ByteArray();
							AbcSpec.writeStringInfo(originalString, searchByteArray);
							
							var replacementByteArray:ByteArray = new ByteArray();
							AbcSpec.writeStringInfo(replacementString, replacementByteArray);
							
							swfTag.tagBody = ByteArrayUtils.findAndReplaceFirstOccurrence(swfTag.tagBody, searchByteArray, replacementByteArray);
							swfTag.tagBody = ByteArrayUtils.findAndReplaceFirstOccurrence(swfTag.tagBody, searchByteArray, replacementByteArray);								
							
						}
						else 
						{
							if ( qn.name == 'getBar2') 
							{
								trace('pub'); 
							}
							trace('reject....b', qn.name , qn.fullName) ; 
							continue;
						}	
					}
					
				}
			}
			
			invokeCallBack();
		}
		
		private function replaceProps2(props:Array, swfTag:SwfTag, cp:IConstantPool):void
		{			
			var output : Array = [] ; 
			for each ( var prop : String in props ) 
			{
				//var fxPosition:int = cp.getStringPosition(qn.nameSpace.name+'/'+qn.nameSpace.kind.description+':'+propertyOrMethodName);
				var fxPosition2:int = cp.getStringPosition(prop);
				//var sppos:int = cp.getStringPosition(qn.name);
				var originalString:String = ''+prop
				var replacementString:String = 'inject_'+prop
				
				var namePublicVar : String = this.className+'/'+prop
				var namePrivatedVar : String = this.className+'/'+'private:'+prop; 
				
				var position_IfPrivate:int = cp.getStringPosition(namePrivatedVar);
				var position_IfPublic:int = cp.getStringPosition(namePublicVar);
				
				var  namePublicVar_Rep : String = this.className+'/'+replacementString
				var namePrivatedVar_Rep : String = this.className+'/'+'private:'+replacementString; 
				
				if ( position_IfPrivate == -1 && position_IfPublic == -1 ) 
				{
					trace('var', prop ) 
					var r : Array = dictClass[this.classNameDot] as Array
					r.splice( r.indexOf( prop ), 1 ) 
					continue; 
				}
				
				
				var searchByteArray:ByteArray = new ByteArray();
				AbcSpec.writeStringInfo(originalString, searchByteArray);
				
				var replacementByteArray:ByteArray = new ByteArray();
				AbcSpec.writeStringInfo(replacementString, replacementByteArray);
				
				swfTag.tagBody = ByteArrayUtils.findAndReplaceFirstOccurrence(swfTag.tagBody, 
					searchByteArray, replacementByteArray);
				/*fxPosition2 = cp.getStringPosition(prop); //these dont' change in real time ... 
				//var sppos:int = cp.getStringPosition(qn.name);
				position_IfPrivate = cp.getStringPosition(this.className+'/'+'private:'+prop);
				position_IfPublic = cp.getStringPosition(this.className+'/'+prop);*/
				/*	swfTag.tagBody = ByteArrayUtils.findAndReplaceFirstOccurrence(swfTag.tagBody, 
				searchByteArray, replacementByteArray);	*/		
				//you don' replace twice, get the whole string otu of there
				if ( position_IfPublic != -1 ) 
				{
					originalString = namePublicVar
					replacementString = namePublicVar_Rep
					
					searchByteArray = new ByteArray();
					AbcSpec.writeStringInfo(originalString, searchByteArray);
					
					replacementByteArray = new ByteArray();
					AbcSpec.writeStringInfo(replacementString, replacementByteArray);
					
					swfTag.tagBody = ByteArrayUtils.findAndReplaceFirstOccurrence(swfTag.tagBody, 
						searchByteArray, replacementByteArray);
				}
				////////////////////////////////////////////////
				
				if ( position_IfPrivate != -1 ) 
				{
					originalString = namePrivatedVar
					replacementString = namePrivatedVar_Rep
					
					searchByteArray = new ByteArray();
					AbcSpec.writeStringInfo(originalString, searchByteArray);
					
					replacementByteArray = new ByteArray();
					AbcSpec.writeStringInfo(replacementString, replacementByteArray);
					
					swfTag.tagBody = ByteArrayUtils.findAndReplaceFirstOccurrence(swfTag.tagBody, 
						searchByteArray, replacementByteArray);				
				}
			}	
		}
		
		/**
		 * Strip out the package from a ny properties
		 * */
		private function cleanUpPropertyNames(props:Array):Array
		{
			var output : Array = [] ; 
			for each ( var name : String in props ) 
			{
				//trace(); 
				if ( name.indexOf( this.className ) == 0 ) 
					name = name.replace(this.className+'.', '' ) ; 
				output.push( name ) ; 
			}
			return output;
		}
		
		private function getProps(cp:IConstantPool):Array
		{
			var props : Array = [] ; 
			
			for (var i:uint = 0; i < cp.multinamePool.length; i++) 
			{
				
				var item : Object = cp.multinamePool[i]
				if ( item is QualifiedName) 
				{
					var qn:QualifiedName = cp.multinamePool[i];
				}
				else
				{
					continue;
				}
				trace('examine', qn.name , qn.fullName );
				var reservedWordFound:Boolean = false
				
				for each ( var reservedWord : String in ['int', 'void', 'String', 'trace', 'Function', 'void', 'Object', '*', 
					'Array', 'Number', 'XML', this.classNameDot] )
				{
					if ( qn.fullName == reservedWord ) 
					{
						trace('reserved word', qn.name , qn.fullName, qn.nameSpace.kind, qn.nameSpace.name, qn.poolIndex, 
							qn.toHash() ) ; 
						reservedWordFound= true
					}
				}
				if ( reservedWordFound ) 
				{
					continue;
				}
				trace('prop', qn.name , qn.fullName, qn.nameSpace.kind, qn.nameSpace.name, qn.poolIndex, 
					qn.toHash() ) ; 
				props.push(qn.fullName ) ; 
			}
			
			return props
		}
		/**
		 * Check if in const pool strings
		 * */
		private function listNamePool(pool:Array):void
		{
			for (var i:uint = 0; i < pool.length; i++) 
			{
				var item : Object = pool[i]
				var str : String = item.toString(); 
				trace( str ) ; 
				/*	
				QName[Namespace[namespace::*]:*]
				QName[Namespace[public]:trace]
				QName[Namespace[public]:String]
				QName[Namespace[public]:void]
				QName[Namespace[public]:int]
				QName[Namespace[public]:xF]				
				QName[Namespace[public]:en_US$effects_properties]
				QName[Namespace[public::mx.core]:IFlexModuleFactory]
				QName[Namespace[packageInternalNamespace]:styleManager]
				QName[Namespace[packageInternalNamespace]:styleNames]
				QName[Namespace[packageInternalNamespace]:i]
				QName[Namespace[public]:int]
				QName[Namespace[public]:void]
				QName[Namespace[public]:init]
				QName[Namespace[public]:_MixingLoom_FlexInit]
				QName[Namespace[public]:Object]		
				QName[Namespace[private::blah:Foo]:getPrivateBar2]
				QName[Namespace[public]:getBar]
				QName[Namespace[public]:getBar2]
				QName[Namespace[public]:Function]
				QName[Namespace[public::blah]:Foo]
				QName[Namespace[public]:Object]
				*/
				if ( str.indexOf('pace[public]:' ) == -1 )
					continue; 
				/*['int]', ':void]', ':Object]', ':init]', ']:String]' , ']:trace]' ]
				if ( str.indexOf('pace[public]:' ) == -1 )
				continue; */
				//trace( pool[i].toString(),pool.prototype ) ; 
			}
		}
		
	}
}