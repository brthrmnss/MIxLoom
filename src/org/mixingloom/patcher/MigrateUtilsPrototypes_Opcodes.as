package org.mixingloom.patcher
{
	import Reloaders.ReloadableGen;
	import Reloaders.ReloadableView2;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.messaging.channels.StreamingAMFChannel;
	
	import org.as3commons.bytecode.abc.AbcFile;
	import org.as3commons.bytecode.abc.BaseMultiname;
	import org.as3commons.bytecode.abc.ClassInfo;
	import org.as3commons.bytecode.abc.ConstantPool;
	import org.as3commons.bytecode.abc.InstanceInfo;
	import org.as3commons.bytecode.abc.LNamespace;
	import org.as3commons.bytecode.abc.MethodBody;
	import org.as3commons.bytecode.abc.MethodInfo;
	import org.as3commons.bytecode.abc.MethodTrait;
	import org.as3commons.bytecode.abc.Multiname;
	import org.as3commons.bytecode.abc.MultinameL;
	import org.as3commons.bytecode.abc.NamespaceSet;
	import org.as3commons.bytecode.abc.Op;
	import org.as3commons.bytecode.abc.QualifiedName;
	import org.as3commons.bytecode.abc.enum.MultinameKind;
	import org.as3commons.bytecode.abc.enum.NamespaceKind;
	import org.as3commons.bytecode.abc.enum.Opcode;
	import org.as3commons.bytecode.emit.IAbcBuilder;
	import org.as3commons.bytecode.emit.impl.AbcBuilder;
	import org.as3commons.bytecode.emit.impl.MethodBuilder;
	import org.as3commons.bytecode.io.AbcDeserializer;
	import org.as3commons.bytecode.swf.SWFWeaverFileIO;
	import org.as3commons.bytecode.tags.DoABCTag;
	import org.as3commons.bytecode.tags.serialization.DoABCSerializer;
	import org.as3commons.bytecode.typeinfo.Argument;
	import org.mixingloom.SwfTag;
	
	
	/**
	 * Gave up on the bytecode tilli learn how to add an anoyouse function ....
	 * 
	 * */
	public class MigrateUtilsPrototypes_Opcodes  
	{
		
		public var method:MethodBody;
		private var genericBasename:BaseMultiname =new BaseMultiname(MultinameKind.GENERIC)
		public var abcFile:AbcFile;
		public function  length():int
		{
			
			return this.method.opcodes.length
		}
		public function layBase() : void
		{
			var m2 : MethodBuilder = new MethodBuilder()
			m2.addOpcode( Opcode.getlocal_0  )
				.addOpcode( Opcode.pushscope )
			
			this.addBaseCodes( m2.opcodes ) 
			
			
		}
		
		/**
		 * Adds codes at end or index
		 * */
		private function addBaseCodes(opcodes:Array, index : int = -1 ):void
		{
			var count : int = 0 ; 
			if ( index == -1 ) 
				index = this.method.opcodes.length
			for each ( var op : Op in  opcodes )
			{
				this.method.opcodes.splice( index+ count, 0, op )
				count++
			}
		}
		
		public function addTrace(  index:int, msg : String):void
		{
			var m2 : MethodBuilder = new MethodBuilder()
			var fxTrace : QualifiedName = new QualifiedName('trace', LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
			m2.addOpcode( Opcode.findpropstrict, [fxTrace] )
				.addOpcode( Opcode.pushstring, [msg] )
				.addOpcode( Opcode.callproperty, [fxTrace, 1] )		
				.addOpcode( Opcode.pop )
			var count : int = 0 ; 
			for each ( var op : Op in m2.opcodes )
			{
				this.method.opcodes.splice( index+count, 0, op )
				count++
			}
		}
		
		
		public function close():void
		{
			var m2 : MethodBuilder = new MethodBuilder()
			m2.addOpcode( Opcode.returnvoid  )
			addBaseCodes(m2.opcodes) ; 
		}
		
		public function print(str:String='', clearAfter : Boolean = true):void
		{
			if ( clearAfter ) 
				trace();
			if ( str != '' ) 
				trace(str);
			var count : int = 0 ; 
			for each ( var op : Op in this.method.opcodes )
			{
				count++
					trace( count+':', op.opcode, op.parameters.join() );
			}
			if ( clearAfter ) 
				trace();			
		}
		public function addCall (cloneFx:MethodInfo, methodName:String):void
		{
			//	 methodName = 'startup2'
			var qqProp : MultinameL = new MultinameL(  NamespaceSet.PUBLIC_NSSET, MultinameKind.MULTINAME_L ) ; 
			var qnameFx2 : QName = new QName(  LNamespace.PUBLIC, 'Function' ) ; 
			var qnameFx :  BaseMultiname = new BaseMultiname(MultinameKind.QNAME);// new QName(  LNamespace.PUBLIC, 'Function' ) ; 
			//		.PUBLIC_NSSET, MultinameKind.MULTINAME_L ) ; 
			//return;
			var m2 : MethodBuilder = new MethodBuilder()
			m2.addOpcode( Opcode.getlocal_0  )
				.addOpcode( Opcode.pushstring, [methodName] )
				.addOpcode( Opcode.getproperty, [qqProp]   )		
				.addOpcode( Opcode.coerce_a ) //, [qnameFx] )//, qnameFx2]   )		
				.addOpcode( Opcode.setlocal_1   )	
				.addOpcode( Opcode.getlocal_1   )					
				.addOpcode( Opcode.getlocal_0   )	
			
			for   ( var i : int = 0 ; i < cloneFx.methodBody.methodSignature.paramCount; i++  )
			{
				m2.addOpcode( Opcode.getlocal, [i+1]  )
			}
			var fxCall : QualifiedName = new QualifiedName('call', LNamespace.BUILTIN,MultinameKind.QNAME ) ; 
			//var fxCall : QName = new QName(  LNamespace.BUILTIN.name, 'call' ) ; 
			m2.addOpcode( Opcode.callproperty, [fxCall, i+1] )
			m2.addOpcode( Opcode.pop   )						
			this.addBaseCodes( m2.opcodes ) 
			
			
		}
		public function addCall_coerce (cloneFx:MethodInfo, methodName:String):void
		{
			//methodName = 'startup2'
			var qqProp : MultinameL = new MultinameL(  NamespaceSet.PUBLIC_NSSET, MultinameKind.MULTINAME_L ) ; 
			var qnameFx2 : QName = new QName(  LNamespace.PUBLIC, 'Function' ) ; 
			var qnameFx :  BaseMultiname = new BaseMultiname(MultinameKind.QNAME);// new QName(  LNamespace.PUBLIC, 'Function' ) ; 
			//		.PUBLIC_NSSET, MultinameKind.MULTINAME_L ) ; 
			//return;
			var m2 : MethodBuilder = new MethodBuilder()
			m2.addOpcode( Opcode.getlocal_0  )
				.addOpcode( Opcode.pushstring, [methodName] )
				.addOpcode( Opcode.getproperty, [qqProp]   )		
				.addOpcode( Opcode.coerce, [qnameFx] )//, qnameFx2]   )		
				.addOpcode( Opcode.setlocal_1   )	
				.addOpcode( Opcode.getlocal_1   )					
				.addOpcode( Opcode.getlocal_0   )	
			
			for   ( var i : int = 0 ; i < cloneFx.methodBody.methodSignature.paramCount; i++  )
			{
				m2.addOpcode( Opcode.getlocal, [i+1]  )
			}
			var fxCall : QName = new QName(  LNamespace.BUILTIN, 'call' ) ; 
			m2.addOpcode( Opcode.callproperty, [fxCall, i] )
			m2.addOpcode( Opcode.pop   )						
			this.addBaseCodes( m2.opcodes ) 
			
			
		}
		
		public function addCall2(cloneFx:MethodInfo, methodName:String):void
		{
			//methodName = 'startup2'
			var qqProp : MultinameL = new MultinameL(  NamespaceSet.PUBLIC_NSSET, MultinameKind.MULTINAME_L ) ; 
			//return;
			var m2 : MethodBuilder = new MethodBuilder()
			m2.addOpcode( Opcode.getlocal_0  )
				.addOpcode( Opcode.pushstring, [methodName] )
				.addOpcode( Opcode.getproperty, [qqProp]   )				
				.addOpcode( Opcode.getlocal_0   )	
			
			for   ( var i : int = 0 ; i < cloneFx.methodBody.methodSignature.paramCount; i++  )
			{
				m2.addOpcode( Opcode.getlocal, [i+1]  )
			}
			
			//var fxCall : QualifiedName = new QualifiedName('call', LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
			var fxCall : Multiname = new Multiname('call',  this.allNamespaces() ,MultinameKind.MULTINAME ) ; 
			m2.addOpcode( Opcode.callproperty, [fxCall, i] )
			m2.addOpcode( Opcode.pop   )						
			this.addBaseCodes( m2.opcodes ) 
			
			
		}
		
		private function allNamespaces():org.as3commons.bytecode.abc.NamespaceSet
		{
			var publicNamespace:LNamespace = new LNamespace(NamespaceKind.NAMESPACE, "publicNamespace");
			var packageNamespace:LNamespace = new LNamespace(NamespaceKind.PACKAGE_NAMESPACE, "packageNamespace");
			var packageInternalNamespace:LNamespace = new LNamespace(NamespaceKind.PACKAGE_INTERNAL_NAMESPACE, "packageInternalNamespace");
			var protectedNamespace:LNamespace = new LNamespace(NamespaceKind.PROTECTED_NAMESPACE, "protectedNamespace");
			
			var explicitNamespace:LNamespace =new LNamespace(NamespaceKind.EXPLICIT_NAMESPACE, "explicitNamespace") 
			var staticProtectedNamespace:LNamespace =new LNamespace(NamespaceKind.STATIC_PROTECTED_NAMESPACE, "staticProtectedNamespace") 
			var privateNamespace:LNamespace =new LNamespace(NamespaceKind.PRIVATE_NAMESPACE, "privateNamespace")
			
			var firstNamespaceSet:NamespaceSet = new NamespaceSet([publicNamespace, 
				packageNamespace, 
				packageInternalNamespace, protectedNamespace,
				explicitNamespace, staticProtectedNamespace,privateNamespace ]);
			firstNamespaceSet = new NamespaceSet([
				LNamespace.PUBLIC, 
				//LNamespace.ASTERISK, 
				//	LNamespace.FLASH_UTILS, 
				LNamespace.BUILTIN
			])
			return firstNamespaceSet;
		}
		
		/**
		 *
		 _as3_findpropstrict fedres.dashboard.controller::TestCommand1TriggerEvent
		 _as3_getproperty fedres.dashboard.controller::TestCommand1TriggerEvent
		 _as3_getproperty LOAD_FILE2
		 * 
		 * 			_as3_findpropstrict fedres.dashboard.controller::TestCommand1TriggerEvent
		 _as3_getproperty fedres.dashboard.controller::TestCommand1TriggerEvent
		 _as3_pushstring "LOAD_FILE"
		 _as3_getproperty {}
		 *  
		 * */
		public function convertGrabProp():void
		{
			var combo : Array = [
				Opcode.findpropstrict, 
				Opcode.getproperty, 
				Opcode.getproperty				
			]
			var methodBodyForAccess : MethodBuilder = new MethodBuilder()
			
			methodBodyForAccess.addOpcode( Opcode.findpropstrict, [this.genericBasename] )
				.addOpcode( Opcode.getproperty, [genericBasename]   )		
				.addOpcode( Opcode.getproperty, [genericBasename]   )		
			//combo = methodBodyForAccess.opcodes 
			this.print('before convert')
			var i : int = this.getIndexOfCombo(combo , i   )
			while ( i != -1 )
			{
				var op : Op = this.method.opcodes[i+2] as Op
				var prop : String = op.parameters[0].fullName; 
				var qqProp : MultinameL = new MultinameL(  NamespaceSet.PUBLIC_NSSET, MultinameKind.MULTINAME_L ) ; 
				//var qqProp : Multiname = new Multiname( prop,  NamespaceSet.PUBLIC_NSSET, MultinameKind.MULTINAME ) ; 
				var m2 : MethodBuilder = new MethodBuilder()
				/*
				m2.addOpcode( Opcode.pushstring, [prop] )
				.addOpcode( Opcode.getproperty, [qqProp]   )	*/	 
				var strPoolIndex : int = this.getStringIndex(prop);
				m2.addOpcode( Opcode.pushstring, [prop] )
					.addOpcode( Opcode.getproperty, [qqProp]   )	
				/*
				m2.addOp( this.method.opcodes[i+1] as Op )
				m2..addOpcode( Opcode.getproperty, [qqProp]   )*/
				//m2..addOpcode( Opcode.getproperty, [qqProp]   )							
				this.insert( m2.opcodes, i+2, 1 ) 
				i  = this.getIndexOfCombo( combo, i +1)
				this.method.maxStack++;
			}
			
			this.print('after convert')
		}
		
		private function getStringIndex(prop:String):int
		{
			// TODO Auto Generated method stub
			return this.abcFile.constantPool.addString( prop );  
		}
		
		private function insert(opcodes:Array, index:int, removeItems:int):void
		{
			var count : int = 0 ; 
			if ( index == -1 ) 
				index = this.method.opcodes.length
			var o : Object = this.method.opcodes[index]
			for ( var i : int = 0 ; i < removeItems ; i++ ) 
			{
				this.method.opcodes.splice( index , 1 )
			}					
			var o2 : Object = this.method.opcodes[index]
			for each ( var op : Op in  opcodes )
			{
				this.method.opcodes.splice( index+ count, 0, op )
				count++
			}
		}
		
		private function getIndexOfCombo(combo:Array, startIndex : int = 0 ):int
		{
			var opcodes : Array = this.method.opcodes;
			for ( var i : int = startIndex ; i < this.method.opcodes.length ; i++ )// in opcodes ) 
			{
				var op : Op = this.method.opcodes[i] as Op; 
				if ( op.opcode.opcodeName==(combo[0] as Opcode).opcodeName )
				{
					//track if we are still matching
					var same : Boolean = true
					for ( var inner : int = 0 ; inner < combo.length; inner++ )
					{
						if ( same == false ) continue; 
						op = opcodes[i+inner] as Op; 
						var compare : Opcode = combo[inner]
						if ( op.opcode.opcodeName!=compare.opcodeName )	
						{
							same = false
							continue; 
						}
					}
					if ( same == true ) 
						return i; 
				}
			}
			return -1
		}
	}
}