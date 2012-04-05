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
	import org.as3commons.bytecode.abc.enum.MethodFlag;
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
	public class MigrateUtils extends AbstractPatcher {
		
		static public var dictClass : Dictionary = new Dictionary(true); 
		/**
		 * will store last loaded class here the version 
		 * */
		static public var dictClassVersions : Dictionary = new Dictionary(true)
		/**
		 * need to know name of loaded swfs or something 
		 * */
		static public var Count : int = 0 ;
		/**
		 * version of class name with dots
		 * */
		private var classNameDot:String;
		
		public var className:String;
		/**
		 * when loading a 2nd dary version
		 * store original name here
		 * ...unnecsary are you are loading to a diff context ....
		 * */
		public var originalClassName: String = ''
		public var propertyOrMethodName:String;
		private var abcFile:AbcFile;
		private var funcs:Array;
		
		public function MigrateUtils()
		{
		}
		
		/**
		 * Takes swf tag and remove it for collisions 
		 * */
		public function makeClass(swfTag: SwfTag, fx : Function ):void
		{
			this.fxCallback = fx; 
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
			this.abcFile = abcDeserializer.deserialize(abcStartLocation)
			
			var info : ClassInfo = abcFile.classInfo[0] as ClassInfo;
			
			//get name and package 
			var name : String = info.classMultiname.name
			var package_ : String = info.classMultiname.fullName.replace( '.'+info.classMultiname.name, '' ) 
			this.className = package_+'.'+name; 
			//get version 
			var version : int = dictClassVersions[this.className];
			version++;
			dictClassVersions[this.className] = version
			this.version = version; 
			if ( version ==1 )
			{
				
			}
			else
			{
				this.originalClassName = this.className; 
				//rename
				/*name+='V'+version.toString()
				info.classMultiname.name =name
				this.className = package_+'.'+name; */
			}
			
			//get all functions 
			this.funcs   = this.getAllFunctions(); 
			this.convertFuncsToVars( funcs ) 
			
			/*	
			//abcFile.methodInfo[8].methodName += '2'
			var inst : InstanceInfo = abcFile.instanceInfo[0] as InstanceInfo
			
			//create new variable (Function) to hold function for retrieval
			var slot : SlotOrConstantTrait = new SlotOrConstantTrait()
			slot.typeMultiname = new QualifiedName('Function', LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
			slot.traitMultiname = new QualifiedName('ggg', LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
			slot.traitKind = TraitKind.SLOT
			inst.addTrait( slot ); 
			
			var dbg : Array = [inst.slotOrConstantTraits]
			inst.slotOrConstantTraits.length
			
			
			//clone target method 
			//TODO: how to know which one? 
			var cloneFx : MethodInfo = abcFile.methodInfo[4]; 
			
			var m : MethodInfo = new MethodInfo()
			m.methodName = ''
			m.methodBody = cloneFx.methodBody.clone() as MethodBody;
			m.methodBody = new MethodBody();
			m.methodBody.opcodes = [] ; 
			m.returnType = cloneFx.returnType;
			//slice scope variables TODO:make this more free form
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
			abcFile.addMethodInfo( m ) 
			//they use method body to go through here
			m.methodBody.methodSignature = m; 
			abcFile.addMethodBody( m.methodBody ); 
			
			//add to constructor
			var constructor : MethodInfo = this.getConstructor( )
			
			var m2 : MethodBuilder = new MethodBuilder()
			var bb : QualifiedName = new QualifiedName('ggg', LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
			m2.addOpcode( Opcode.getlocal_0 )
			.addOpcode( Opcode.newfunction,[2] ) 
			.addOpcode( Opcode.pop ) 
			.addOpcode( Opcode.setproperty, [bb] ) 
			//for new func, make sure count is right 
			constructor.methodBody.opcodes.splice( constructor.methodBody.opcodes.length -2, 
			0, m2.opcodes[0], m2.opcodes[1] ,m2.opcodes[3] ) 
			*/
			//reload 
			var abcBuilder:IAbcBuilder = new AbcBuilder();
			
			abcBuilder.addEventListener(Event.COMPLETE, loadedHandler);
			abcBuilder.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			abcBuilder.addEventListener(IOErrorEvent.VERIFY_ERROR, errorHandler);
			
			//var appDomain : ApplicationDomain;
			this.appDomain = ApplicationDomain.currentDomain; 
			if ( version >  1) 
			{
				this.appDomain = new ApplicationDomain();
			}
			abcBuilder['reload']( abcFile, appDomain ); 
			return;
			abcBuilder.buildAndLoad();
			//abcBuilder.buildAndExport()
			//var x2 : AbcFile = abcBuilder.build(null); 
			return; 
		}
		
		/**
		 * make var 
		 * make function 
		 * clear local scope 
		 * set var to function in constructor
		 * */
		private function convertFuncsToVars(funcs:Array):void
		{
			for each ( var fxName : String in funcs ) 
			{
				var inst : InstanceInfo = abcFile.instanceInfo[0] as InstanceInfo
				var fxVarName : String = this.convertFxNameToProp( fxName ) ; 
				//create new variable (Function) to hold function for retrieval
				var slot : SlotOrConstantTrait = new SlotOrConstantTrait()
				slot.typeMultiname = new QualifiedName('Function', LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
				slot.traitMultiname = new QualifiedName(fxVarName, LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
				slot.traitKind = TraitKind.SLOT
				inst.addTrait( slot ); 
				
				var dbg : Array = [inst.slotOrConstantTraits]
				inst.slotOrConstantTraits.length
				
				//clone target method 
				var cloneFx : MethodInfo = this.getMethodByName(fxName)
				
				var m : MethodInfo = new MethodInfo()
				m.methodName = ''
				m.methodBody = cloneFx.methodBody.clone() as MethodBody;
				m.methodBody = new MethodBody();
				m.methodBody.opcodes = [] ; 
				m.flags = MethodFlag.addFlag(m.flags, MethodFlag.NEED_ACTIVATION);
				for each ( var arg : Argument in cloneFx.formalParameters )
				{
					m.addArgument( arg ) ; 
				}
				for each ( arg in cloneFx.optionalParameters )
				{
					m.addArgument( arg ) ; 
				}
				
				m.returnType = cloneFx.returnType;
				m.methodBody.opcodes = cloneFx.methodBody.opcodes.concat()
				//slice scope variables TODO:make this more free form
				//m.methodBody.opcodes.splice(2,2 )
				//m.methodBody.opcodes.splice(3,2 )
				//m.methodBody.opcodes =null; 
				//m.methodBody.opcodes.splice(0,0,new Op( Opcode.newactivation ), new Op( Opcode.dup )  )
				m.methodBody.opcodes.splice(0,0,new Op( Opcode.newactivation )  )
				new Op( Opcode.newactivation ); 
				new Op( Opcode.newactivation ); 
				new Op( Opcode.newactivation ); 
				new Op( Opcode.newactivation ); 
				//m.methodBody.opcodes.splice(3,1 )
				/*for ( var i : int = 0 ; i < m.methodBody.opcodes.length; i++ ) 
				{
					var op : Op = m.methodBody.opcodes[i];
					if ( op.opcode ==  Opcode.setlocal_1  )
						m.methodBody.opcodes.splice( i, 1, new Op( Opcode.setlocal_0 )  ) 
				}*/
				m.methodBody.opcodes.push( new Op(Opcode.returnvoid) )
					
				//cloneFx.methodBody.opcodes.splice(2,2 )
				m.as3commonsByteCodeAssignedMethodTrait == null
				//rename old method 
				cloneFx.methodName = this.convertFxNameToRenamed(cloneFx.methodName); 
				
				//they use method body to go through here
				m.methodBody.methodSignature = m; 
				abcFile.addMethodBody( m.methodBody ); 
				abcFile.addMethodInfo( m ); //must add info (which is where count comes from)
				//add to constructor
				var constructor : MethodInfo = this.getConstructor( )
				
				var m2 : MethodBuilder = new MethodBuilder()
				var bb : QualifiedName = new QualifiedName(fxVarName, LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
				m2.addOpcode( Opcode.getlocal_0 )
					.addOpcode( Opcode.newfunction,[abcFile.methodBodies.length-1] ) /*-1 does nto work ? 2 ,3 is good*/
					.addOpcode( Opcode.pop ) 
					.addOpcode( Opcode.setproperty, [bb] ) 
				
				constructor.methodBody.opcodes.splice( constructor.methodBody.opcodes.length -2, 
					0, m2.opcodes[0], m2.opcodes[1] ,m2.opcodes[3] ) 
			}
			
		}
		
		private function getMethodByName(fxName:String):MethodInfo
		{
			for each ( var o : MethodInfo in this.abcFile.methodInfo ) 
			{
				if ( o.methodName == fxName ) 
					return o; 
			}
			return null;
		}		
		
		private function getAllFunctions():Array
		{
			var output : Array = [] ; 
			for each ( var o : MethodInfo in this.abcFile.methodInfo ) 
			{
				if ( o.as3commonsBytecodeName == 'constructor' ) 
					continue; 
				if ( o.methodName == '' ) 
					continue; 				 
				output.push( o.methodName ); 
			}
			return output;
		}
		
		private function getConstructor( ):MethodInfo
		{
			for each ( var o : MethodInfo in this.abcFile.methodInfo ) 
			{
				if ( o.as3commonsBytecodeName == 'constructor' ) 
					return o; 
			}
			return null;
		}		
		
		public function errorHandler(event:Event):void 
		{
			trace('errorHandler')
		}
		
		public function loadedHandler(event:Event):void 
		{
			//var className : String = 'blah.Foo2'
			//var clazz:Class = ApplicationDomain.currentDomain.getDefinition(className) as Class;
			var clazz:Class = this.appDomain.getDefinition(className) as Class;
			
			if ( this.version == 1 ) 
			{
				this.copyFunctions( clazz ); 
			}
			else
			{
				//should send in the old prototype ... 
				var existingClazz:Class = ApplicationDomain.currentDomain.getDefinition(this.originalClassName) as Class;
				var curentD : ApplicationDomain = ApplicationDomain.currentDomain; 
				this.copyFunctions2( existingClazz, clazz ); 
			}
			
			this.fxCallback(); 
			return;//if ur loading more than 2 file do not attempt to do this twice
			if ( this.className != 'blah.Foo' ) 
				return; 
			
			var instance:Object = new clazz();
			var o : Object = new Object(); 
			Object.prototype.jjk = instance.ggg; 
			Object.prototype.jjk2 = instance.fx; 
			
			
			var outputXML : Object = ImportClassUtils.getClassInfo( clazz ) 
			//var funcs : Array = this.dictFuncs[this.className]
			
			trace(Object.prototype.jjk); 
			
			var fooTest : Object = instance //as Foo; 
			fooTest.getBar() ;
			fooTest.getBar2();
			//test
			/*import blah.Foo
			var fooTest : Foo = instance as Foo; 
			fooTest.getBar() ;
			fooTest.getBar2(); */
			//end test
			instance.fx()
			o.jjk2()
			instance.ggg()
			o.jjk()
			//var i:int = instance.multiplyByHundred(10);
			//this.invokeCallBack(); 
			// i == 1000
		}
		
		private function copyFunctions2(existingClazz:Class, clazz:Class):void
		{
			var instance:Object = new clazz(); //make default paramets nullable ... to avoid problems 
			for each ( var func : String in this.funcs  ) 
			{
				//do i have to make fxs here? i don't think so ... 
				var fxName : String = this.convertFxNameToProp(func)
				existingClazz.prototype[func] = null; 
				delete existingClazz.prototype[func] 
					existingClazz.prototype[func] = instance[fxName]
				existingClazz.prototype[func+'1'] = instance[fxName]
			}
			if ( this.originalClassName == 'blah.Foo' ) 
			{
				var instance2:Object = new existingClazz();
				trace(	'test appedn 1', instance2['getPrivateBar'+'1']() ); 
				return;
			}
		}
		
		private function copyFunctions(clazz : Object):void
		{
			var instance:Object = new clazz(); //make default paramets nullable ... to avoid problems 
			for each ( var func : String in this.funcs  ) 
			{
				//do i have to make fxs here? i don't think so ... 
				var fxName : String = this.convertFxNameToProp(func)
				clazz.prototype[func] = instance[fxName]
			}
		}
		public var propStoreFx_Preamble : String = 'fxStore__'
		public var propRenameFx_Preamble : String = 'fxInject__' 
		private var version:int;
		private var appDomain:ApplicationDomain;
		private var fxCallback:Function;
		public function convertFxNameToProp(s :  String ) :  String
		{
			return propStoreFx_Preamble+s
		}
		
		private function convertFxNameToRenamed(methodName:String):String
		{
			return propRenameFx_Preamble+methodName;
		}
		
		
		
		
	}
}