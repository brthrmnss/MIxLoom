/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/23/11
 * Time: 1:34 PM
 */
package org.mixingloom.patcher
{
	import flash.utils.ByteArray;
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
	
	
	public class DropFunctionsPatcher extends AbstractPatcher {
		
		public var className:String;
		
		public var propertyOrMethodName:String;
		
		public function DropFunctionsPatcher(className:String, propertyOrMethodName:String)
		{
			this.className = className;
			this.classNameDot = className.replace( new RegExp(':','gi'), '.' ) ; 
			this.propertyOrMethodName = propertyOrMethodName;
		}
		/**
		 * need to know name of loaded swfs or something 
		 * */
		static public var Count : int = 0 ;
		/**
		 * version of class name with dots
		 * */
		private var classNameDot:String;
		override public function apply( invocationType:InvocationType, swfContext:SwfContext ):void {
	 
			
			Count++
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
					var pos_ClassName:int = cp.getStringPosition(className);
					//these are in namespace pool as well 
					var pos_Forbiddden:int = cp.getStringPosition('http://adobe.com/AS3/2006/builtin')		
					var pos_Forbiddden2:int = cp.getMultinamePositionByName('http://www.adobe.com/2006/flex/mx/internal')		
					if ( pos_ClassName > -1 &&  pos_ClassName < 4  &&  pos_Forbiddden == -1 ) 
					{
						trace('class here'); 
					}
					else
					{
						continue; 
					}
					
					
					var props : Array = this.getProps( cp ) ; 
					this.listNamePool(cp.multinamePool) 
					//this.listNamePool(cp.) 
					//abcDeserializer.deserializeClassInfos(abcFile, cp,50 )
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
						if (/*(qn.nameSpace.kind == NamespaceKind.PRIVATE_NAMESPACE) &&*/
							((qn.nameSpace.name == LNamespace.ASTERISK.name) ||
								(qn.nameSpace.name == LNamespace.PUBLIC.name) ||
								(qn.nameSpace.name == className)) )
						{ 
							if (qn.nameSpace.name != className ) 
							{
								if ( [ 'Namespace', '*' ].indexOf(qn.name) != -1 )
								{
									trace('skip A', qn.name , qn.fullName, qn.nameSpace.kind, qn.nameSpace.name, qn.poolIndex, 
										qn.toHash() ) ; 
									continue; 
								}
								var reservedWordFound: Boolean = false 
								for each ( var reservedWord : String in ['int', 'void', 'String', 'trace'] )
								{
									if ( qn.name == reservedWord ) 
									{
										trace('reserved word', qn.name , qn.fullName, qn.nameSpace.kind, qn.nameSpace.name, qn.poolIndex, 
											qn.toHash() ) ; 
										reservedWordFound = true
									}
								}
								if ( reservedWordFound ) 
								{
									continue
								}
								var fxPosition3:int = cp.getStringPosition(qn.name);
								//if ( qn.name == 'getBar' ) 
								trace('skip', qn.name , qn.fullName,fxPosition3, qn.nameSpace.kind, qn.nameSpace.name, qn.poolIndex, 
									qn.nameSpace.toString(), qn.nameSpace.kind ) ; 
								
								continue; 
							}
							/*if (qn.name != propertyOrMethodName) 
							{
							trace('reject', qn.name , qn.fullName) ; 
							continue;
							}	*/
							if (qn.name == '*' || qn.fullName == 'Namespace' ) 
							{
								trace('reject', qn.name , qn.fullName) ; 
								continue;
							}	
							
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
							/*
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
							*/
							
							
							
							
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
				var reservedWordFound:Boolean = false
				
				for each ( var reservedWord : String in ['int', 'void', 'String', 'trace', 'Function', 'void', 'Object', '*', 
				'Array', 'Number', 'XML', this.classNameDot] )
				{
					if ( qn.fullName == reservedWord ) 
					{
						trace('reserved word', qn.name , qn.fullName, qn.nameSpace.kind, qn.nameSpace.name, qn.poolIndex, 
							qn.toHash() ) ; 
						reservedWordFound=  true
					}
				}
				if ( reservedWordFound ) 
				{
					continue
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