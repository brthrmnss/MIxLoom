/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/23/11
 * Time: 1:34 PM
 */
package org.mixingloom.patcher
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.as3commons.bytecode.abc.AbcFile;
	import org.as3commons.bytecode.abc.BaseMultiname;
	import org.as3commons.bytecode.abc.ClassInfo;
	import org.as3commons.bytecode.abc.ConstantPool;
	import org.as3commons.bytecode.abc.IConstantPool;
	import org.as3commons.bytecode.abc.InstanceInfo;
	import org.as3commons.bytecode.abc.LNamespace;
	import org.as3commons.bytecode.abc.MethodBody;
	import org.as3commons.bytecode.abc.MethodInfo;
	import org.as3commons.bytecode.abc.Multiname;
	import org.as3commons.bytecode.abc.NamespaceSet;
	import org.as3commons.bytecode.abc.Op;
	import org.as3commons.bytecode.abc.QualifiedName;
	import org.as3commons.bytecode.abc.SlotOrConstantTrait;
	import org.as3commons.bytecode.abc.TraitInfo;
	import org.as3commons.bytecode.abc.enum.MultinameKind;
	import org.as3commons.bytecode.abc.enum.NamespaceKind;
	import org.as3commons.bytecode.abc.enum.Opcode;
	import org.as3commons.bytecode.abc.enum.TraitKind;
	import org.as3commons.bytecode.emit.IAbcBuilder;
	import org.as3commons.bytecode.emit.IClassBuilder;
	import org.as3commons.bytecode.emit.ICtorBuilder;
	import org.as3commons.bytecode.emit.IMethodBuilder;
	import org.as3commons.bytecode.emit.IPackageBuilder;
	import org.as3commons.bytecode.emit.IPropertyBuilder;
	import org.as3commons.bytecode.emit.enum.MemberVisibility;
	import org.as3commons.bytecode.emit.impl.AbcBuilder;
	import org.as3commons.bytecode.emit.impl.MethodArgument;
	import org.as3commons.bytecode.emit.impl.MethodBuilder;
	import org.as3commons.bytecode.io.AbcDeserializer;
	import org.as3commons.bytecode.io.AbcSerializer;
	import org.as3commons.bytecode.swf.AbcClassLoader;
	import org.as3commons.bytecode.tags.DoABCTag;
	import org.as3commons.bytecode.typeinfo.Argument;
	import org.as3commons.bytecode.util.AbcSpec;
	import org.mixingloom.SwfContext;
	import org.mixingloom.SwfTag;
	import org.mixingloom.invocation.InvocationType;
	import org.mixingloom.utils.ByteArrayUtils;
	
	/**
	 * Gave up on the bytecode tilli learn how to add an anoyouse function ....
	 * 
	 * */
	public class MigrateFunctionsPatcher4_TryToReloadExistingClass extends AbstractPatcher {
		
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
		
		public function MigrateFunctionsPatcher4_TryToReloadExistingClass(className:String, propertyOrMethodName:String)
		{
			this.className = className;
			this.classNameDot = className.replace( new RegExp(':','gi'), '.' ) ; 
			this.propertyOrMethodName = propertyOrMethodName;
		}
		
		override public function apply( invocationType:InvocationType, swfContext:SwfContext ):void {
			
			//var clazz:Class = ApplicationDomain.currentDomain.getDefinition("blah.Foo") as Class;
			//trace(clazz);
			//abcDeserializer.deserializeClassInfos(
			/*abcDeserializer
			var parser : ByteParser = new ByteParser(); 
			
			var swfContext : SwfContext = new SwfContext()
			swfContext.originalUncompressedSwfBytes = parser.uncompressSwf( PatchManager.Swf );;
			
			swfContext.originalUncompressedSwfBytes.position = 0; 
			var abcDeserializer:AbcDeserializer = new AbcDeserializer(swfContext.originalUncompressedSwfBytes);
			//swfTag.tagBody.position = startOfConstPoolPosition;
			var t : DoABCTag = new DoABCTag()
			t.abcFile; 
			var cp:IConstantPool = new ConstantPool();
			var abcFile:AbcFile = abcDeserializer.deserialize(32)
			trace('abclength', abcFile.methodBodies.length ) 
			*/
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
				if (this.touched ) 
					continue; 
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
					//var abcFile:AbcFile = abcDeserializer.deserialize(abcStartLocation)
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
					//this.openClass2(swfTag)
					this.makeClass(swfTag)
					return;
					//get all properties 
					//add all native flex/flash types //check against those defined in another namespace?
					//i don't think xml is in the strings? 
					var props : Array = this.getProps( cp ) ; 
					//this.listNamePool(cp.multinamePool) 
					//this.listNamePool(cp.) 
					//return; /never invokes callback 
					/*this.openClass(swfTag)
					//return;
					this.touched = true 
					return;
					continue; */
					//clean up private names
					props = this.cleanUpPropertyNames( props ) 
					//wiht each property store in static some we can reginerate
					dictClass[this.classNameDot] = props
					this.makeClass()
					
					//	return;
					//all private properties need to be made public
					//replace strings in string lookup table 
					this.replaceProps2( props, swfTag, cp ) 
					
					this.dropName( props, swfTag, cp ) 
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
							/*this.openClass(swfTag,0)
							continue; */
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
							
							
							//ByteArrayUtils.
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
		
		private function openClass2(swfTag: SwfTag, start : int=0):void
		{
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
			var abcFile:AbcFile = abcDeserializer.deserialize(abcStartLocation)
			for each ( var x : MethodInfo in abcFile.methodInfo )
			{
				x.methodName+='vvv'
			}
			
			var ser : AbcSerializer = new AbcSerializer()
			//swfTag.tagBody = ser.serializeAbcFile( abcFile ) 
			//ByteArrayUtils.findAndReplaceFirstOccurrence(swfTag.tagBody, searchByteArray, replacementByteArray);	
			var reserializedStream:ByteArray = ser.serializeAbcFile( abcFile ) 
			/*_classLoader.loadClassDefinitionsFromBytecode([TestConstants.getBaseClassTemplate(), 
			TestConstants.getMethodInvocation(), reserializedStream]);*/
			//_classLoader.loadClassDefinitionsFromBytecode([reserializedStream])
			_classLoader.loadAbcFile(abcFile ,ApplicationDomain.currentDomain ); 
			_classLoader.addEventListener(Event.COMPLETE, function(event:Event):void {
				//assertTrue(true);
				trace('ok load class'); 
				var o : Object = ApplicationDomain.currentDomain.getDefinition('blah.Foo')
				var n3 : Object = new o
				try
				{
					n3.pubMeth(); 
				} 
				catch(error:Error) 
				{
					trace('err1')					
				}
				try
				{
					n3['pubMethvvv'](); 
				} 
				catch(error:Error) 
				{
					trace('err2')
				}				
				//var o2 : Object = ApplicationDomain.currentDomain.getDefinition('blah:Foo')
				invokeCallBack(); 
			} );
			_classLoader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
				trace("loader error: " + event.text);
			});
			_classLoader.addEventListener(IOErrorEvent.VERIFY_ERROR, function(event:IOErrorEvent):void {
				trace("loader error: " + event.text);
			});
			return;
		}
		
		private function makeClass(swfTag: SwfTag):void
		{
			var migrate : MigrateUtils = new MigrateUtils()
			migrate.makeClass( swfTag ) 
			return;
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
			var abcFile:AbcFile = abcDeserializer.deserialize(abcStartLocation)
			var info : ClassInfo = abcFile.classInfo[0] as ClassInfo; 
			info.classMultiname.name = 'Foo2' 
			abcFile.methodInfo[8].methodName += '2'
			var  inst : InstanceInfo = abcFile.instanceInfo[0] as  InstanceInfo
			var slot : SlotOrConstantTrait = new SlotOrConstantTrait()
			slot.typeMultiname = new QualifiedName('Function', LNamespace.PUBLIC,MultinameKind.QNAME  ) ; 
			//slot.typeMultiname['fullName'] = 'Function' 
			//x.typeMultiname['nameSpace'] = NamespaceKind.
			//slot['name'] = 'testtFx'
			slot.traitMultiname =  new QualifiedName('ggg', LNamespace.PUBLIC,MultinameKind.QNAME  ) ; 
			slot.traitKind =  TraitKind.SLOT
			//	new QualifiedName(newName, LNamespace.PUBLIC,MultinameKind.QNAME  ) ; 
			//	inst.slotOrConstantTraits.push( slot )
			var trait : TraitInfo = new TraitInfo()
			trait.traitMultiname =   new QualifiedName('ggg', LNamespace.PUBLIC,MultinameKind.QNAME  ) ; 
			//	trait.
			trait.traitKind = TraitKind.SLOT
			inst.addTrait( slot ); 
			var dbg : Array = [inst.slotOrConstantTraits]
			inst.slotOrConstantTraits.length
			
			var cloneFx : MethodInfo = abcFile.methodInfo[4]; 
			
			var m : MethodInfo = new MethodInfo()
			m.methodName = ''
			m.methodBody = cloneFx.methodBody.clone() as MethodBody;
			m.methodBody = new MethodBody();
			m.methodBody.opcodes = [] ; 
			m.returnType = cloneFx.returnType; 
			m.methodBody.opcodes.splice(2,2 )
			//m.methodBody.opcodes =null; 
			m.methodBody.opcodes.push( new Op(Opcode.returnvoid) )
			//cloneFx.methodBody.opcodes.splice(2,2 )
			m.as3commonsByteCodeAssignedMethodTrait == null
			//m.methodBody.opcodes = abcFile.methodInfo[2].methodBody.opcodes
			//m.methodBody.opcodes = [];
			//cloneFx.methodBody.opcodes = [];
			//cloneFx.methodBody.opcodes = abcFile.methodInfo[2].methodBody.opcodes
			//info.methodInfo.push( m ); 
			//info.addTrait( m ); 
			abcFile.addMethodInfo(  m ) 
			//abcFile.addMethodInfo(  m ) 
			m.methodBody.methodSignature = m; //they use method body to go through here
			abcFile.addMethodBody( m.methodBody ); 
			//abcFile.addMethodInfos(
			//info.
			var m2 : MethodBuilder = new MethodBuilder()
			var bb : QualifiedName = new QualifiedName('ggg', LNamespace.PUBLIC,MultinameKind.QNAME  ) ; 
			m2.addOpcode( Opcode.getlocal_0 )
				.addOpcode( Opcode.newfunction,[2] )  /*-1 does nto work ? 2 ,3 is good*/
				.addOpcode( Opcode.pop ) 
				.addOpcode( Opcode.setproperty, [bb] ) 
			//.addOpcode( Opcode.getproperty, [bb] ) 
			
			var constructor : MethodInfo = abcFile.methodInfo[1] as MethodInfo; 
			constructor.methodBody.opcodes.splice( constructor.methodBody.opcodes.length -2, 
				0, m2.opcodes[0], m2.opcodes[1] ,m2.opcodes[3]  ) 
			
			//abcFile.instanceInfo[0].slotOrConstantTraits.push(slot)
			//var slot : info.slotOrConstantTraits[0]
			// TODO Auto Generated method stub
			
			//var packageBuilder:IPackageBuilder = abcBuilder.definePackage("blah");
			//var classBuilder:IClassBuilder = packageBuilder.defineClass("Foo");
			var abcBuilder:IAbcBuilder = new AbcBuilder();
			
			abcBuilder.addEventListener(Event.COMPLETE, loadedHandler);
			abcBuilder.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			abcBuilder.addEventListener(IOErrorEvent.VERIFY_ERROR, errorHandler);
			
			
			abcBuilder['reload']( abcFile ); 
			return;
			abcBuilder.buildAndLoad();
			//abcBuilder.buildAndExport()
			//var x2 : AbcFile = abcBuilder.build(null); 
			return; 
		}
		
		private function makeClass_OldTryToREcreate(swfTag: SwfTag):void
		{
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
			var abcFile:AbcFile = abcDeserializer.deserialize(abcStartLocation)
			
			// TODO Auto Generated method stub
			var abcBuilder:IAbcBuilder = new AbcBuilder();
			
			var packageBuilder:IPackageBuilder = abcBuilder.definePackage("blah");
			var classBuilder:IClassBuilder = packageBuilder.defineClass("Foo");
			classBuilder.isDynamic = true; 
			//classBuilder.
			var propertyBuilder:IPropertyBuilder ;//= classBuilder.defineProperty("name","String");
			
			//var accessorBuilder:IAccessorBuilder = classBuilder.defineAccessor("count","int",100);
			
			var methodBuilder:IMethodBuilder = classBuilder.defineMethod("multiplyByHundred");
			var argument:MethodArgument = methodBuilder.defineArgument("int");
			methodBuilder.returnType = "int";
			methodBuilder.addOpcode(Opcode.getlocal_0)
				.addOpcode(Opcode.pushscope)
				.addOpcode(Opcode.getlocal_1)
				.addOpcode(Opcode.pushint, [100])
				.addOpcode(Opcode.multiply)
				.addOpcode(Opcode.setlocal_1)
				.addOpcode(Opcode.getlocal_1)
				.addOpcode(Opcode.returnvalue);
			var propCount : int = 0; //fxCount+=1;
			for each ( var cc : SlotOrConstantTrait in abcFile.instanceInfo[0].slotOrConstantTraits )
			{
				propCount+=1
				propertyBuilder= classBuilder.defineProperty(cc.traitMultiname.fullName, cc.typeMultiname['fullName'], cc.defaultValue);
				propertyBuilder.isOverride = cc.isOverride; 
				propertyBuilder.visibility = MemberVisibility.PUBLIC; 
				
				//set privtevars accordingly 
				if ( cc.traitMultiname.nameSpace.name != '' ) 
				{
					if ( propertyBuilder.name.indexOf( cc.traitMultiname.nameSpace.name ) == 0 )
					{
						propertyBuilder.name = propertyBuilder.name.replace( cc.traitMultiname.nameSpace.name+'.', '' )
						//propertyBuilder.visibility = MemberVisibility.PRIVATE; 
					}
				}
				//propertyBuilder.isConstant = cc.isConstant; 
				propertyBuilder.isStatic = cc.isStatic; 
				//propertyBuilder.
				
			}
			var anonMeths : Array = []
			//var 
			//classBuilder.
			var fxCount : int = 0 ; //they dont'let us know how many methods we have added .... 
			for each ( var x : MethodInfo in abcFile.methodInfo )
			{
				if ( x.methodName == '' ) 
				{
					anonMeths.push( x )
					//continue;
				}
				fxCount+= 1; 
				//blah:Foo/Foo init fx
				//classBuilder.
				if ( x.methodName.indexOf('/'+classBuilder.name) != -1 ) 
				{
					//continue;
					//methodBuilder = classBuilder.defineConstructor();//('inject_'+x.methodName );
					var ctorBuilder:ICtorBuilder = classBuilder.defineConstructor();
					for each ( param in x.formalParameters )
					{
						//arg= methodBuilder.defineArgument(param.type['fullName'], param.isOptional, param.defaultValue )
						//arg.name = param.name; 
						//methodBuilder.arguments.push( param ) ; 
					}
					var codes : Array = x.methodBody.opcodes.concat()
					//codes.splice( 5, 3 )
					//this.realignOpCodes( codes ) ;
					codes.splice( 5, 3 )
					codes.splice( 5, codes.length )
					ctorBuilder.opcodes = [] ; 
					ctorBuilder.addOpcodes(codes ) ; 
					ctorBuilder.addOpcode( Opcode.returnvoid )
					continue; 
				}
				this.addMethod(classBuilder.packageName+'.'+classBuilder.name, x.methodName)
				
				methodBuilder = classBuilder.defineMethod(''+x.methodName );
				methodBuilder.returnType = x.returnType['fullName']
				if ( x.paramCount > 0 ) 
				{
					
				}
				for each ( var param : Argument in x.formalParameters )
				{
					var arg:MethodArgument = methodBuilder.defineArgument(param.type['fullName'], param.isOptional, param.defaultValue )
					arg.name = param.name; 
					//methodBuilder.arguments.push( param ) ; 
				}
				/* for each ( var op : Op in x.methodBody.opcodes )
				{
				methodBuilder.ad
				}*/
				methodBuilder.addOpcodes( x.methodBody.opcodes ) ; 
				/* argument = methodBuilder.defineArgument("int");
				
				methodBuilder.addOpcode(Opcode.getlocal_0)
				.addOpcode(Opcode.pushscope)
				.addOpcode(Opcode.getlocal_1)
				.addOpcode(Opcode.pushint, [100])
				.addOpcode(Opcode.multiply)
				.addOpcode(Opcode.setlocal_1)
				.addOpcode(Opcode.getlocal_1)
				.addOpcode(Opcode.returnvalue);
				x.methodName+='vvv'*/
			}
			
			//Try to add methods as functions ...
			//classBuilder.
			for each ( x in abcFile.methodInfo )
			{
				//continue
				//continue
				//continue; 
				if ( x.methodName == '' ) 
				{
					continue;
				}
				//blah:Foo/Foo init fx
				if ( x.methodName.indexOf('/'+classBuilder.name) != -1 ) 
				{
					continue; 
				}
				
				if ( this.addedMethodAsFunction1 ) 
					continue;
				this.addedMethodAsFunction1 = true
				/*
				//can i add anything?
				var methodBuilder:IMethodBuilder = classBuilder.defineMethod("xxxtarget_"+x.methodName);
				var argument:MethodArgument = methodBuilder.defineArgument("int");
				methodBuilder.returnType = "int";
				methodBuilder.addOpcode(Opcode.getlocal_0)
				.addOpcode(Opcode.pushscope)
				.addOpcode(Opcode.getlocal_1)
				.addOpcode(Opcode.pushint, [100])
				.addOpcode(Opcode.multiply)
				.addOpcode(Opcode.setlocal_1)
				.addOpcode(Opcode.getlocal_1)
				.addOpcode(Opcode.returnvalue);
				var xx : Object = methodBuilder.opcodes; 
				continue; 
				*/
				fxCount+=1;
				var newName : String = 'fx'+x.methodName 
				//ctorBuilder.opcodes = [] 
				var ee : Op	 
				var m2 : MethodBuilder = new MethodBuilder()
				
				
				
				propertyBuilder= classBuilder.defineProperty(newName,'Function', null);
				propCount += 1;
				//methodBuilder = classBuilder.defineMethod('xxxtarget_'+x.methodName );
				methodBuilder = classBuilder.defineMethod( '5'+newName );
				//methodBuilder.isStatic = true
				methodBuilder.returnType = x.returnType['fullName']
				if ( x.paramCount > 0 ) 
				{
					
				}
				for each ( param in x.formalParameters )
				{
					arg = methodBuilder.defineArgument(param.type['fullName'], param.isOptional, param.defaultValue )
					arg.name = param.name; 
					methodBuilder.arguments.push( param ) ; 
				}
				/* for each ( var op : Op in x.methodBody.opcodes )
				{
				methodBuilder.ad
				}*/
				//methodBuilder.addOpcodes( x.methodBody.opcodes ) ; 
				//clear ooff scope setter from function
				var anonCodes : Array = x.methodBody.opcodes.concat()
				//add it natural
				/*methodBuilder.addOpcodes( anonCodes ) ;
				continue;*/
				//anonCodes.splice( 2, 2 )
				//anonCodes.splice( 3,1 )
				methodBuilder.needActivation;// = true; 
				
				//this.realignOpCodes( anonCodes ) 
				//methodBuilder.addOpcode(Opcode.newactivation)
				//	.addOpcode(Opcode.dup)
				methodBuilder.addOpcodes( anonCodes ) ; 
				//methodBuilder.opcodes  = [] ; 
				/*
				methodBuilder.addOpcode(Opcode.newactivation)
				.addOpcode(Opcode.dup)
				.addOpcode(Opcode.getlocal_0)
				.addOpcode(Opcode.pushscope)
				.addOpcode(Opcode.getlocal_1)
				.addOpcode(Opcode.pushint, [100])
				.addOpcode(Opcode.multiply)
				.addOpcode(Opcode.setlocal_1)
				.addOpcode(Opcode.getlocal_1)
				.addOpcode(Opcode.returnvalue);
				//methodBuilder.returnType = 'void'
				//methodBuilder.
				//continue; 
				*/
				//	var bb : BaseMultiname = new BaseMultiname( MultinameKind.RTQNAME_LA )
				//bb.
				//bb.poolIndex = propCount
				//copy from closts above
				//trainName
				var bb : QualifiedName = new QualifiedName(newName, LNamespace.PUBLIC,MultinameKind.QNAME  ) ; 
				bb.poolIndex
				//var bb : Multiname = new Multiname(newName,NamespaceSet.PUBLIC_NSSET,MultinameKind.MULTINAME_A  ) ; 
				m2.addOpcode( Opcode.getlocal_0 )
					//.addOpcode( Opcode.newfunction, [fxCount-0] )
					.addOpcode( Opcode.newfunction,[0] ) //fxCount+2 is perfect offset
					.addOpcode( Opcode.pop ) 
					.addOpcode( Opcode.setproperty, [bb] ) 
					.addOpcode( Opcode.getproperty, [bb] ) 
				/*	, 
				new Opcode( Opcode.newfunction, 'new xf', fxCount+1), 
				new Opcode( Opcode.initproperty, 'set val', newName)*/
				//continue;
				codes = 	ctorBuilder.opcodes;
				//codes.splice(4, 0, m2.opcodes[0] )//,  m2.opcodes[1] )//, m2.opcodes[2]  )			
				//codes.splice(4, 0, m2.opcodes[0]  ,  m2.opcodes[1] )//, m2.opcodes[2]  )			
				//codes.splice(4, 0, m2.opcodes[0]  ,  m2.opcodes[1] , m2.opcodes[2]  )	
				//codes.splice(10, 0, m2.opcodes[0]  ,  m2.opcodes[1] , m2.opcodes[2]  )
				//codes.splice(codes.length-1, 0, m2.opcodes[0],  m2.opcodes[1] , m2.opcodes[2]  )
				//codes.splice(codes.length-2, 0, m2.opcodes[0] ,  m2.opcodes[1],  m2.opcodes[3], m2.opcodes[1]/*, m2.opcodes[2]*/)// , m2.opcodes[2]  )
				//continue; 
				//codes.splice(codes.length-2, 0,   m2.opcodes[0], m2.opcodes[4],  m2.opcodes[4],m2.opcodes[3]   )//, m2.opcodes[1]/*, m2.opcodes[2]*/)// , m2.opcodes[2]  )
				//codes.splice(codes.length-2, 0,     m2.opcodes[2] , m2.opcodes[1],  m2.opcodes[4],m2.opcodes[3]   )
				codes.splice(codes.length-1, 0,  m2.opcodes[0], m2.opcodes[1] ,m2.opcodes[3]   )
				
				
				//replacement
				
				ctorBuilder.opcodes = []
				ctorBuilder.addOpcodes( codes ) 
			}
			
			
			/*
			for each ( var x : MethodInfo in abcFile.classInfo )
			{
			
			}
			*/
			abcBuilder.addEventListener(Event.COMPLETE, loadedHandler);
			abcBuilder.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			abcBuilder.addEventListener(IOErrorEvent.VERIFY_ERROR, errorHandler);
			
			abcBuilder.buildAndLoad();
			//abcBuilder.buildAndExport()
			//var x2 : AbcFile = abcBuilder.build(null); 
			return; 
		}
		
		private function realignOpCodes(opCodes:Array):void
		{
			// TODO Auto Generated method stub
			var index : int = 0;
			for each ( var op : Op in opCodes )
			{
				var len : int = op.endLocation-op.baseLocation
				op.baseLocation = index; 
				index += len
				op.endLocation =index; 
				//	index += 1
			}
		}
		
		private function addMethod( packageName:String, methodName:String):void
		{
			// TODO Auto Generated method stub
			var meths : Array = dictClass[packageName] 
			if ( meths == null ) 
			{
				meths = []
			}
			meths.push( methodName ) 
			dictClass[packageName] = meths
		}
		private function makeClassTest():void
		{
			// TODO Auto Generated method stub
			var abcBuilder:IAbcBuilder = new AbcBuilder();
			var packageBuilder:IPackageBuilder = abcBuilder.definePackage("blah");
			var classBuilder:IClassBuilder = packageBuilder.defineClass("Foo");
			classBuilder.isDynamic = true; 
			//classBuilder.
			var propertyBuilder:IPropertyBuilder = classBuilder.defineProperty("name","String");
			
			//var accessorBuilder:IAccessorBuilder = classBuilder.defineAccessor("count","int",100);
			
			var methodBuilder:IMethodBuilder = classBuilder.defineMethod("multiplyByHundred");
			var argument:MethodArgument = methodBuilder.defineArgument("int");
			methodBuilder.returnType = "int";
			methodBuilder.addOpcode(Opcode.getlocal_0)
				.addOpcode(Opcode.pushscope)
				.addOpcode(Opcode.getlocal_1)
				.addOpcode(Opcode.pushint, [100])
				.addOpcode(Opcode.multiply)
				.addOpcode(Opcode.setlocal_1)
				.addOpcode(Opcode.getlocal_1)
				.addOpcode(Opcode.returnvalue);
			
			abcBuilder.addEventListener(Event.COMPLETE, loadedHandler);
			abcBuilder.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			abcBuilder.addEventListener(IOErrorEvent.VERIFY_ERROR, errorHandler);
			
			abcBuilder.buildAndLoad();
		}
		public function errorHandler(event:Event):void {
			trace('errorHandler')
		}
		
		public function loadedHandler(event:Event):void {
			var clazz:Class = ApplicationDomain.currentDomain.getDefinition("blah.Foo2") as Class;
			var instance:Object = new clazz();
			var o : Object = new Object(); 
			Object.prototype.jjk = instance.ggg; 
			Object.prototype.jjk2 = instance.fx; 
			trace(Object.prototype.jjk); 
			instance.fx()
			o.jjk2()
			instance.ggg()
			o.jjk()
			var i:int = instance.multiplyByHundred(10);
			this.invokeCallBack(); 
			// i == 1000
		}
		
		public var _classLoader : AbcClassLoader = new AbcClassLoader();
		private var touched:Boolean;
		private var addedMethodAsFunction1:Boolean=false;
		private function replaceProps2(props:Array, swfTag:SwfTag, cp:IConstantPool):void
		{			
			var output : Array = [] ; 
			for each ( var prop : String in props ) 
			{
				//var fxPosition:int = cp.getStringPosition(qn.nameSpace.name+'/'+qn.nameSpace.kind.description+':'+propertyOrMethodName);
				var fxPosition2:int = cp.getStringPosition(prop);
				//var sppos:int = cp.getStringPosition(qn.name);
				var position_IfPrivate:int = cp.getStringPosition(this.className+'/'+'private:'+prop);
				var position_IfPublic:int = cp.getStringPosition(this.className+'/'+prop);
				if ( position_IfPrivate == -1 && position_IfPublic == -1 ) 
				{
					trace('var', prop ) 
					var r : Array = dictClass[this.classNameDot] as Array
					r.splice( r.indexOf( prop ), 1 ) 
					continue; 
				}
				var originalString:String = ''+prop
				var replacementString:String = 'inject_'+prop
				
				var searchByteArray:ByteArray = new ByteArray();
				AbcSpec.writeStringInfo(originalString, searchByteArray);
				
				var replacementByteArray:ByteArray = new ByteArray();
				AbcSpec.writeStringInfo(replacementString, replacementByteArray);
				
				swfTag.tagBody = ByteArrayUtils.findAndReplaceFirstOccurrence(swfTag.tagBody, searchByteArray, replacementByteArray);
				swfTag.tagBody = ByteArrayUtils.findAndReplaceFirstOccurrence(swfTag.tagBody, searchByteArray, replacementByteArray);								
			}	
		}
		
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
		
		private function dropName(props:Array, swfTag:SwfTag, cp:IConstantPool):void
		{			
			var output : Array = [] ; 
			for each ( var prop : String in cp.stringPool ) 
			{
				if ( prop.indexOf( this.className ) == -1 ) 
					continue; 
				//var fxPosition:int = cp.getStringPosition(qn.nameSpace.name+'/'+qn.nameSpace.kind.description+':'+propertyOrMethodName);
				var fxPosition2:int = cp.getStringPosition(prop);
				//var sppos:int = cp.getStringPosition(qn.name);
				var position_IfPrivate:int = cp.getStringPosition(this.className+'/'+'private:'+prop);
				var position_IfPublic:int = cp.getStringPosition(this.className+'/'+prop);
				/*if ( position_IfPrivate == -1 && position_IfPublic == -1 ) 
				{
				trace('var', prop ) 
				var r : Array = dictClass[this.classNameDot] as Array
				r.splice( r.indexOf( prop ), 1 ) 
				continue; 
				}*/
				var originalString:String = ''+prop
				var replacementString:String =prop.replace(this.className, this.className+'666' ); 
				
				var searchByteArray:ByteArray = new ByteArray();
				AbcSpec.writeStringInfo(originalString, searchByteArray);
				
				var replacementByteArray:ByteArray = new ByteArray();
				AbcSpec.writeStringInfo(replacementString, replacementByteArray);
				
				swfTag.tagBody = ByteArrayUtils.findAndReplaceFirstOccurrence(swfTag.tagBody, searchByteArray, replacementByteArray);
				swfTag.tagBody = ByteArrayUtils.findAndReplaceFirstOccurrence(swfTag.tagBody, searchByteArray, replacementByteArray);								
			}	
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
						reservedWordFound= true
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