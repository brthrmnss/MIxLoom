package org.mixingloom.patcher
{
	import Reloaders.ReloadableGen;
	import Reloaders.ReloadableView;
	import Reloaders.ReloadableView2;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.as3commons.bytecode.abc.AbcFile;
	import org.as3commons.bytecode.abc.ClassInfo;
	import org.as3commons.bytecode.abc.ConstantPool;
	import org.as3commons.bytecode.abc.FunctionTrait;
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
	import org.as3commons.bytecode.abc.SlotOrConstantTrait;
	import org.as3commons.bytecode.abc.TraitInfo;
	import org.as3commons.bytecode.abc.enum.MultinameKind;
	import org.as3commons.bytecode.abc.enum.NamespaceKind;
	import org.as3commons.bytecode.abc.enum.Opcode;
	import org.as3commons.bytecode.abc.enum.TraitKind;
	import org.as3commons.bytecode.emit.IAbcBuilder;
	import org.as3commons.bytecode.emit.impl.AbcBuilder;
	import org.as3commons.bytecode.emit.impl.MethodBuilder;
	import org.as3commons.bytecode.io.AbcDeserializer;
	import org.as3commons.bytecode.io.AbcSerializer;
	import org.as3commons.bytecode.swf.SWFWeaverFileIO;
	import org.as3commons.bytecode.tags.DoABCTag;
	import org.as3commons.bytecode.tags.serialization.DoABCSerializer;
	import org.as3commons.bytecode.typeinfo.Argument;
	import org.as3commons.reflect.Type;
	import org.as3commons.reflect.Variable;
	import org.mixingloom.SwfTag;
	
	
	/**
	 * Gave up on the bytecode tilli learn how to add an anoyouse function ....
	 * 
	 * */
	public class MigrateUtilsPrototypes extends AbstractPatcher {
		
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
		/**
		 * views.TestView
		 * */
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
		
		public function MigrateUtilsPrototypes()
		{
		}
		
		/**
		 * Takes swf tag and remove it for collisions 
		 * */
		public function makeClass(swfTag: SwfTag, fx : Function , swfTags:Vector.<SwfTag>):void
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
			var inst : InstanceInfo = abcFile.instanceInfo[0] as InstanceInfo;
			//get name and package 
			var name : String = info.classMultiname.name
			nameOriginal   = name; 
			var origMultName : String =  info.classMultiname.fullName ;
			var package_ : String = info.classMultiname.fullName.replace( '.'+info.classMultiname.name, '' ) 
			this.className = package_+'.'+name; 
			this.classNameNoPackage = name; 
			var reg : RegExp = /\./gi
			this.classAsNamespaceName = name.replace( reg, ':' )+'::'
			//get version 
			var version : int = dictClassVersions[this.className];
			version++;
			dictClassVersions[this.className] = version
			this.version = version; 
			if ( version ==1 )
			{
				trace(this.debugName, 'Seen class before'); 
			}
			else
			{
				trace(this.debugName, 'Have not seen class before'); 
				
				this.originalClassName = this.className; 
				this.originalClassPackage = info.classMultiname.nameSpace.name
				//rename
				name+='VVV'+version.toString()
				this.classNameOnly = name; 
				info.classMultiname.name =name
				
				//this.className =  name; 
				this.className = package_+'.'+name; 
				swfTag.name =  name;//  this.className; 
				swfTag.name = ''
				if ( package_ != '' ) 
					swfTag.name = package_.replace( reg, '/')
				if ( swfTag.name != ''  ) 
					swfTag.name += '/'
				swfTag.name += name		
				//	fedres/dashboard/EconomyDashboardContext
				this.newConstructoMethodName = className.replace( reg, ':' ) + '/'+ name//views:TestView/TestView
				newConstructoMethodName_orig  = this.originalClassName.replace( reg, ':' )+'/'+nameOriginal
				//remove from package
				var blankNs : LNamespace = new LNamespace(NamespaceKind.PACKAGE_NAMESPACE, "sdfsdf");
				var classQn : QualifiedName = new QualifiedName(name,blankNs, MultinameKind.QNAME ) ; 
				//	info.classMultiname = classQn
				//	inst.classMultiname =classQn
				//info.classMultiname.nameSpace.name=""
				info.classMultiname.name =name
				//inst.classMultiname.nameSpace.name=""
				inst.classMultiname.name =name
				inst.isProtected = false; 
				//this.abcFile.constantPool = new ConstantPool(); 
				origMultName = origMultName.replace(reg, ':'); 
				this.className_Colon = this.className.replace(reg, ':'); 
				
				for each ( var ln : LNamespace in this.abcFile.constantPool.namespacePool ) 
				{
					if ( ln.name ==  origMultName ) 
					{
						ln.name = this.className_Colon//should have ':'
					}
					/*if ( ln.name == this.originalClassPackage ) 
					{
					ln.name = ""
					}*/
				}
				for   ( var i : int; i <  this.abcFile.constantPool.stringPool.length;i++ ) 
				{
					var str : String = this.abcFile.constantPool.stringPool[i];
					
					if ( str ==  origMultName ) 
					{
						this.abcFile.constantPool.stringPool[i] = this.className//should have ':'
						this.abcFile.constantPool.stringPool[i] = className_Colon //y was thi snto set b4?
					}
					/*if ( str == this.originalClassPackage ) 
					{
					this.abcFile.constantPool.stringPool[i] = ""
					}*/
					if ( str ==  nameOriginal ) 
					{
						this.abcFile.constantPool.stringPool[i] = name; 
					}					
				}		
				
				//update stringpool 
				/*var cp : ConstantPool = this.abcFile.constantPool as ConstantPool; 
				//cp.stringLookup;
				var stringLookupValue : int = cp.stringLookup.get( this.originalClassName )
				cp.stringLookup.remove( this.originalClassName ); 
				/*				SimpleClass	26 [0x1a]	
				views	27 [0x1b]	
				views:SimpleClass	28 [0x1c]	
				views:SimpleClass/SimpleClass	31 [0x1f]	 
				cp.stringLookup.set( this.className, stringLookupValue ) 
				*/
				/*
				cpStringLookupReplace( originalClassName, this.className ) ; 
				cpStringLookupReplace( newConstructoMethodName_orig, this.newConstructoMethodName ) ; 
				cpStringLookupReplace( originalNameOnly, name ) ; 
				*/
				//change package to base ....2.8.312...think that might be unnecesary 
				
				/*
				*
				
				this.originalClassName = this.className; 
				this.originalClassPackage = info.classMultiname.nameSpace.name
				//rename
				name+='VVV'+version.toString()
				info.classMultiname.name =name
				
				this.className =  name; 
				swfTag.name =  name;//  this.className; 
				
				this.newConstructoMethodName = className.replace( reg, ':' ) + '/'+ name//views:TestView/TestView
				//remove from package
				var blankNs : LNamespace = new LNamespace(NamespaceKind.PACKAGE_NAMESPACE, "sdfsdf");
				var classQn : QualifiedName = new QualifiedName(name,blankNs, MultinameKind.QNAME ) ; 
				//	info.classMultiname = classQn
				//	inst.classMultiname =classQn
				info.classMultiname.nameSpace.name=""
				info.classMultiname.name =name
				inst.classMultiname.nameSpace.name=""
				inst.classMultiname.name =name
				inst.isProtected = false; 
				//this.abcFile.constantPool = new ConstantPool(); 
				origMultName = origMultName.replace(reg, ':'); 
				for each ( var ln : LNamespace in this.abcFile.constantPool.namespacePool ) 
				{
				if ( ln.name ==  origMultName ) 
				{
				ln.name = this.className//should have ':'
				}
				if ( ln.name == this.originalClassPackage ) 
				{
				ln.name = ""
				}
				}
				for   ( var i : int; i <  this.abcFile.constantPool.stringPool.length;i++ ) 
				{
				var str : String = this.abcFile.constantPool.stringPool[i];
				
				if ( str ==  origMultName ) 
				{
				this.abcFile.constantPool.stringPool[i] = this.className//should have ':'
				}
				if ( str == this.originalClassPackage ) 
				{
				this.abcFile.constantPool.stringPool[i] = ""
				}
				if ( str ==  originalNameOnly ) 
				{
				this.abcFile.constantPool.stringPool[i] = name; 
				}					
				}		
				
				* 
				* */
				
				
				
				
				/*	this.abcFile.constantPool.stringPool[1] = classQn.fullName; 
				this.replaceString( 'views', blankNs.name )
				*/	
				/*this.newConstructoMethodName  = ''
				
				this.originalClassName = this.className; 
				//rename
				name+='VVV'+version.toString()
				info.classMultiname.name =name
				this.className = package_+'.'+name; 
				swfTag.name =  package_+'/'+name;//  this.className; 
				this.newConstructoMethodName = className.replace( reg, ':' ) + '/'+ name//views:TestView/TestView
				*/
				
			}
			
			//get all functions 
			this.funcs = this.getAllFunctions(); 
			if ( this.funcs.length == 0 || this.mode_skipConversion ) //3/8/12: getting constant pool errors or simpel classes
			{
				if ( this.extendsClass( 'flash.events.Event' )  )
				{
					
				}
				else
				{
					this.skippedConversion = true; 
					if ( this.fxCallback != null ) 
						this.fxCallback()
					
					return;
				}
			}
			
			tracex('converting', this.className );// 'Seen class before'); 
			this.convertFuncsToVars( funcs ) 
			//reload 
			var abcBuilder:IAbcBuilder = new AbcBuilder();
			
			abcBuilder.addEventListener(Event.COMPLETE, loadedHandler);
			abcBuilder.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			abcBuilder.addEventListener(IOErrorEvent.VERIFY_ERROR, errorHandler);
			
			//var appDomain : ApplicationDomain;
			this.appDomain ;//= ApplicationDomain.currentDomain; 
			//this.appDomain = ApplicationDomain.currentDomain; 
			if ( version > 1) 
			{
				//this.appDomain = new ApplicationDomain();
			}
			if ( this.mode_ReloadInstant ) 
			{
				abcBuilder['reload']( abcFile, appDomain );
			}
			else
			{
				if ( this.originalClassName == 'views.SimpleClass' ) 
				{
					trace('...have class')
				}
				abcBuilder.build(null )
				var doabcTag : DoABCTag = new DoABCTag()
				var swfTag2 : SwfTag = new SwfTag()
				swfTag2
				doabcTag.flags = 0
				doabcTag.abcFile = this.abcFile; 
				
				var swfw : SWFWeaverFileIO = new SWFWeaverFileIO()
				var doI : DoABCSerializer = DoABCSerializer( swfw.createTagSerializer( DoABCTag.TAG_ID ) ); 
				var output : ByteArray = new ByteArray()
				//abcFile.constantPool = new ConstantPool(); 
				//abcFile.constantPool.n
				if ( this.version > 1 ) 
				{
					var dbg : Array = [ this.constantPool.stringLookup.contains('Object' ),
						this.constantPool.stringLookup.contains('' ), this.constantPool.stringLookup.contains(null ),
						this.constantPool.stringLookup] ; 
					//this.originalClassName == 'views.SimpleClass' 
					if ( this.constantPool.stringLookup.contains('Object' )  ||
						this.constantPool.stringLookup.contains('' )   ) 
					{
						
						if ( this.getMethodByName( newConstructoMethodName_orig ) != null ) 
							this.getMethodByName( newConstructoMethodName_orig ).methodName = newConstructoMethodName; 
						tracex('fault on class', this.className ) ; 
						this.updateStringCpool();
					}
					this.tryToFixConstantPool(); 
				}
				
				//doI.write( output, doabcTag )
				
				try 
				{
					doI.write( output, doabcTag )
				}
				catch ( e : Error ) 
				{
					/*for   ( var j : Object in this.constantPool.stringLookup.internalLookup )
					{
					trace( 'g', j, j.toString(), j == '') ; 
					} */
					this.tryToFixConstantPool(); 
					output = new ByteArray(); 
					doI.write( output, doabcTag )
				}
				
				swfTag.tagBody = output; 
				
				swfTag.tagBody.position = 0; 
				
				abcStartLocation = 4;
				while (swfTag.tagBody.readByte() != 0)
				{
					abcStartLocation++;
				}
				abcStartLocation++; // skip the string byte terminator
				
				
				swfTag.tagBody.position = 0;
				
				abcDeserializer = new AbcDeserializer(swfTag.tagBody);
				this.abcFile = abcDeserializer.deserialize(abcStartLocation)
				if ( this.fxCallback != null ) 
					this.fxCallback() //hopefully ican load modified classes all at once ...
				
			}
			import org.as3commons.bytecode.abc.ConstantPool;
			
			return;
		}
		
		private function tryToFixConstantPool():void
		{
			if ( this.version > 1 ) 
			{
				var dbg : Array = [ this.constantPool.stringLookup.contains('Object' ),
					this.constantPool.stringLookup.contains('' ), this.constantPool.stringLookup.contains(null ),
					this.constantPool.stringLookup] ; 
				//this.originalClassName == 'views.SimpleClass' 
				if ( this.constantPool.stringLookup.contains('Object' )  ||
					this.constantPool.stringLookup.contains('' )   ) 
				{
					
					if ( this.getMethodByName( newConstructoMethodName_orig ) != null ) 
						this.getMethodByName( newConstructoMethodName_orig ).methodName = newConstructoMethodName; 
					tracex('fault on class', this.className ) ; 
					this.updateStringCpool();
				}
			}
		}
		
		/**
		 * Adjusts string lookup pool to prevent Constantpool is locked errors
		 * */
		private function updateStringCpool():void
		{
			//var reg : RegExp = /\./gi  .replace( reg, ':' )
			var reg : RegExp = /\./gi 
			cpStringLookupReplace( originalClassName.replace( reg, ':' ), this.className.replace( reg, ':' ) ) ; 
			cpStringLookupReplace( newConstructoMethodName_orig, this.newConstructoMethodName ) ; 
			cpStringLookupReplace( nameOriginal, this.classNameOnly ) ; 
		}
		
		/**
		 * Replaces items in string pool
		 * */
		private function cpStringLookupReplace(a:String, b:String):void
		{
			
			var cp : ConstantPool = this.abcFile.constantPool as ConstantPool; 
			if ( cp.stringLookup.contains( a ) == false ) 
				return; 
			var stringLookupValue : int = cp.stringLookup.get( a )
			var dbg : Array = [cp.stringLookup] 
			cp.stringLookup.remove( a ); 
			/*				SimpleClass	26 [0x1a]	
			views	27 [0x1b]	
			views:SimpleClass	28 [0x1c]	
			views:SimpleClass/SimpleClass	31 [0x1f]	*/
			cp.stringLookup.set( b, stringLookupValue ) 
		}
		private function get constantPool () : ConstantPool
		{
			var cp : ConstantPool = this.abcFile.constantPool as ConstantPool; 
			return cp;
		}
		private function replaceString(param0:String, name:String):void
		{
			// TODO Auto Generated method stub
			var i : int = this.abcFile.constantPool.stringPool.indexOf( param0 )
			if ( i != -1  ) 	
				this.abcFile.constantPool.stringPool[i] = name; 
			else
			{
				tracex( 'add to pool', i, name ) ; 
			}
		}
		
		/**
		 * make var 
		 * make function 
		 * clear local scope 
		 * set var to function in constructor
		 * */
		private function convertFuncsToVars(funcs:Array):void
		{
			//return; 
			this.initBlocking()
			var inst : InstanceInfo = abcFile.instanceInfo[0] as InstanceInfo
			inst.isSealed = false //is this how u make non dynamic?
			var traits : Array = inst.traits.concat()
			var traits2 : Array = [] 
			//go through all traits to remove them (issue for ui components )
			for each ( var trait : TraitInfo in inst.traits ) 
			{
				//continue;
				if ( trait.traitKind.description == TraitKind.METHOD.description ) 
				{
					var mT : MethodTrait = trait as MethodTrait
					if ( mT.isStatic || mT.isGetter || mT.isSetter ) 
					{
						//traits2.push( trait ) 
						continue; 
					}
					var index : int = traits.indexOf( trait )
					//traits.splice( index, 1 ) 
					if ( trait.isOverride && trait.traitMultiname.name == 'initialize' ) 
					{
						trace('skip');
						continue; 
					}
					if ( trait.isOverride && trait.traitMultiname.name == 'startup' ) 
					{
						tracex('startup fx found');
					}
					
					cloneFx = this.getMethodByName( trait.traitMultiname.name)
					
					if ( trait.isOverride ) 
					{
						this.methods_Override.push( cloneFx )  
						//trait.isOverride = false
						continue; 
						//have to do special thing ....
						//continue; 
						
					}
					//we make a defautl event listners on teh button that is forward to method of class 
					//do nto move th default event listner location
					if ( this.fxIsDefaultEventListener( cloneFx ) )
					{
						trace('preserved method', trait.traitMultiname.name );
						//funcs.splice( funcs.indexOf( fxName ), 1 ) ; 
						this.removeOpCodeNamespace( cloneFx.methodBody.opcodes, this.classAsNamespaceName ) 
						this.addTrace( cloneFx.methodBody.opcodes, 4, '~~~~In class version::'+ this.className ); 
						cloneFx.methodBody.maxStack++
						continue; //Erro #2007 Parameter must be non-null ... leave it attached to class till we understand
					}
					
					trait.traitMultiname.name = this.convertFxNameToRenamed( trait.traitMultiname.name/*+'x'*/ );
					trait.traitMultiname.nameSpace = LNamespace.PUBLIC; 
					if ( tryToRemoveFxOnly ) 
						inst.removeTrait( trait )
					
					//inst.removeTrait( trait )
					//traits.splice( traits.indexOf( trait ), 1 ) //do not set while in progress
					//remove it,adn ti is not a function 
					//convert to function? 
					/*trait.traitKind = TraitKind.FUNCTION
					var fnTrait : FunctionTrait = new FunctionTrait(); 
					fnTrait.traitKind = TraitKind.FUNCTION*/
					//trait.traitKind = TraitKind.FUNCTION
					/*var fnTrait : SlotOrConstantTrait = new SlotOrConstantTrait(); 
					fnTrait.traitKind = TraitKind.SLOT
					traits.splice( traits.indexOf( trait ), 1, fnTrait )*/
					//don't do the adove ... use the other traits i made
				}
				else
				{
					trace(trait.traitMultiname.fullName , trait.traitKind.description ) ; 
					//traits2.push( trait ) 
				}
			}
			inst.traits = traits; 
			trace('covop5')
			var count : int = 0; 
			for each ( var fxName : String in funcs.concat() ) 
			{
				trace('debug',fxName, inst.methodInfo.length, inst.methodTraits.length, abcFile.methodBodies.length, abcFile.methodInfo.length ) 
				count++;
				/*continue;
				if ( count < 2 ) 
				continue; */
				/*if ( count > 2 )
				continue;*/ 
				
				
				cloneFx = this.getMethodByName( fxName)
				
				//we make a defautl event listners on teh button that is forward to method of class 
				//do nto move th default event listner location
				if ( this.fxIsDefaultEventListener( cloneFx ) )
				{
					//funcs.splice( funcs.indexOf( fxName ), 1 ) ; 
					this.removeOpCodeNamespace( cloneFx.methodBody.opcodes, this.classAsNamespaceName ) 
					if ( this.version > 1 ) 
					{
						if ( this.opAdjust_CallMethAsFunc2( cloneFx.methodBody.opcodes ) ) 
						{
							cloneFx.methodBody.maxStack++ 
							//eillegal binding access
						} 
					}
					//this.removeOpCode( cloneFx.methodBody.opcodes, Opcode.getlocal_1 , 3 ) 
					this.addTrace( cloneFx.methodBody.opcodes, 4, '~~~~In class version::'+ this.className ); 
					//enable this and it will never complain ...
					/*if ( this.version < 2 ) 
					continue;*/
				}
				if ( this.fxIsUICompCreator( cloneFx ) )
				{
					//funcs.splice( funcs.indexOf( fxName ), 1 ) ; 
					//this.opAdjust_CallPrivateAsString( cloneFx.methodBody.opcodes ) 
					
					this.addTrace( cloneFx.methodBody.opcodes, 4, 'xComped:::~~~~In class version::'+ this.className ); 
					//continue;
				}
				
				
				var fxNameOriginal : String = fxName; 
				if ( fxName == this.constructorName ) 
				{
					//don[t understand this ...
					fxName = 'fauxConstructor'
				}
				
				
				
				var fxVarName : String = this.convertFxNameToProp( fxName ) ; 
				
				//create new variable (Function) to hold function for retrieval
				//isn't this redundant ... what does the above slotting loop do?
				var slot : SlotOrConstantTrait = new SlotOrConstantTrait()
				slot.typeMultiname = new QualifiedName('Function', LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
				slot.traitMultiname = new QualifiedName(fxVarName, LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
				slot.traitKind = TraitKind.SLOT
				//2-5-12: on prototype ... trait will block 
				//2-5-12: correction: slot is ok, it ads the fxSlot on the instances .... still probably not needed
				//didn't you rename the fx slot? 
				//inst.addTrait( slot ); //make on prototype only...
				//no, some reasons it needs to b ereferecned
				
				var dbg : Array = [inst.slotOrConstantTraits]
				inst.slotOrConstantTraits.length
				
				//clone target method 
				var cloneFx : MethodInfo = this.getMethodByName(fxNameOriginal)
				
				var m : MethodInfo   = this.cloneFunction( cloneFx ) ; 
				
				
				/*
				make new function 
				copy existing function 
				add to methodbodies
				take original, remove everything except call to other proprety 
				*/
				/*if ( this.methods_Override.indexOf( cloneFx ) != -1 )
				{
				
				var fxOverrideReciever  : MethodInfo = cloneFunction(cloneFx)
				tracex('overridden method'); 
				}*/
				if ( this.methods_Override.indexOf( cloneFx ) != -1 && mode_skipOverrideMethods )
				{
					continue; 
				}
				if ( this.methods_Override.indexOf( cloneFx ) != -1 && 5 == 6 )
				{
					//var skipRenaming:Boolean = true; 
					var fxOverrideReciever  : MethodInfo = cloneFunction(cloneFx)
					var fxOverride_Replacer  : MethodInfo = cloneFunction(cloneFx)
					tracex('overridden method'); 
					abcFile.addMethodBody( m.methodBody ); 
					fxOverride_Replacer.methodBody.opcodes = []
					trace('existing...')
					var x77 : MigrateUtilsPrototypes_Opcodes = new MigrateUtilsPrototypes_Opcodes()
					x77.method = cloneFx.methodBody; 
					x77.print(); 
					trace('existing...', '<')
					var x7 : MigrateUtilsPrototypes_Opcodes = new MigrateUtilsPrototypes_Opcodes()
					x7.method = fxOverride_Replacer.methodBody; 
					x7.layBase(); 
					x7.addTrace(x7.length(), 'what......445454')
					
					fxName  = this.convertFxNameToRenamed(cloneFx.methodName); 
					
					x7.addCall(cloneFx,  fxName    ) 
					x7.addTrace(x7.length(), 'what......445454xc')
					x7.close(); 
					x7.print(); 
					cloneFx.methodBody.maxStack++;
					cloneFx.methodBody.opcodes = fxOverride_Replacer.methodBody.opcodes;
					//cloneFx.methodBody.opcodes = [] ; 
					
					cloneFx = fxOverrideReciever; 
					
				}	
				//cloneFx.methodBody.opcodes.splice(2,2 )
				m.as3commonsByteCodeAssignedMethodTrait == null
				
				if ( cloneFx.as3commonsBytecodeName != 'constructor' ) 
				{
					//rename old method 
					//if ( skipRenaming  == false ) 
					cloneFx.methodName = this.convertFxNameToRenamed(cloneFx.methodName); 
					cloneFx.methodBody.traits[0]
					var mod_Fx : MigrateUtilsPrototypes_Opcodes = new MigrateUtilsPrototypes_Opcodes()
					mod_Fx.method = cloneFx.methodBody; 
					mod_Fx.abcFile = this.abcFile; 
					mod_Fx.convertGrabProp(); 
					this.removeOpCodeNamespace( m.methodBody.opcodes, this.classAsNamespaceName ) 
					this.addTrace( m.methodBody.opcodes, 4, 'In class version::'+ this.className ); 
					m.methodBody.maxStack++
				}	 
				else
				{
					//rename to prevent 'Could not find constructoer on global' error 
					//only occurs when two ui compos in same folder  
					//ReferenceError: Error #1056: Cannot create property views::TestViewVVV2 on global.
					//at global$init()
					if (   this.version > 1  ) 
					{
						replaceString( cloneFx.methodName , this.newConstructoMethodName )
						cloneFx.methodName = this.newConstructoMethodName
					}					
					m.methodName = 	 this.convertFxNameToRenamed( 'fauxConstructor.' )//? usee the period here
					m.methodBody.opcodes
					//this.removeOpCode( m.methodBody.opcodes, Opcode.constructsuper ) 
					//m.methodBody.opcodes.splice( 5, 11 )
					//m.methodBody.opcodes.splice( 4, 12 )
					this.removeOpCodeNamespace( m.methodBody.opcodes, this.classAsNamespaceName ) 
					this.addTrace( m.methodBody.opcodes, 4, 'In class version::'+ this.className ); 
					m.methodBody.maxStack++
				}
				//
				/*	
				//put in public namespace //2/5/11...not necessary
				cloneFx.as3commonsBytecodeName = new QualifiedName(cloneFx.methodName, LNamespace.PUBLIC,MultinameKind.QNAME ) 
				if ( cloneFx.as3commonsByteCodeAssignedMethodTrait != null ) 
				{
				mT = cloneFx.as3commonsByteCodeAssignedMethodTrait as MethodTrait; 
				mT.traitMultiname = new QualifiedName(cloneFx.methodName, LNamespace.PUBLIC,MultinameKind.QNAME ) 
				}	
				*/
				//clear all actions
				//cloneFx.methodBody.opcodes = []
				//cloneFx.methodBody.opcodes.push( new Op(Opcode.returnvoid) )
				
				//they use method body to go through here
				//continue;
				m.methodBody.methodSignature = m; 
				if ( tryToRemoveFxOnly == false || fxName=='fauxConstructor' ) 
				{
					abcFile.addMethodBody( m.methodBody ); 
					abcFile.addMethodInfo( m ); //must add info (which is where count comes from)
				}
				//add to constructor
				var constructor : MethodInfo = this.getConstructor( )
				//continue; 
				/*
				var m2 : MethodBuilder = new MethodBuilder()
				var bb : QualifiedName = new QualifiedName(fxVarName, LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
				m2.addOpcode( Opcode.getlocal_0 )
				.addOpcode( Opcode.newfunction,[abcFile.methodBodies.length-1] ) //-1 does nto work ? 2 ,3 is good
				.addOpcode( Opcode.pop ) 
				.addOpcode( Opcode.setproperty, [bb] ) 
				
				constructor.methodBody.opcodes.splice( constructor.methodBody.opcodes.length -2, 
				0, m2.opcodes[0], m2.opcodes[1] ,m2.opcodes[3] ) 
				*/
				//continue
				var m2 : MethodBuilder = new MethodBuilder()
				var fxOnPrototypeName : QualifiedName = new QualifiedName(fxVarName, LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
				fxOnPrototypeName = new QualifiedName(fxName, LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
				var ooo : Object = this.abcFile.constantPool.namespacePool 
				var ns : LNamespace = this.abcFile.constantPool.namespacePool[2]; 
				ns = new LNamespace(NamespaceKind.PACKAGE_NAMESPACE, ""); 
				//	var qnPrototype : QualifiedName = new QualifiedName('prototypeXd', x,MultinameKind.QNAME ) ; 
				//var x : Multiname = new Multiname( 'prototype', m, MultinameKind.MULTINAME )
				//var ii : int = this.abcFile.constantPool.getMultinamePosition(x)
				var qnPrototype : QualifiedName = new QualifiedName('prototype', LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
				var ii : int = this.abcFile.constantPool.getMultinamePositionByName( 'prototype' ) 
				//qnPrototype = this.abcFile.constantPool.multinamePool[ii]
				//	if ( qnPrototype == null ) 
				var fxIndex : int = abcFile.methodBodies.length-1
				if ( tryToRemoveFxOnly ) 
				{
					fxIndex = abcFile.methodInfo.indexOf( cloneFx ) 
					if (fxName=='fauxConstructor' ) 
					{
						fxIndex = abcFile.methodInfo.indexOf( m ) 
					}
				}
				
				qnPrototype = new QualifiedName('prototype', LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
				m2.addOpcode( Opcode.getlocal_0 )
					.addOpcode( Opcode.findpropstrict, [qnPrototype] )
					.addOpcode( Opcode.getproperty, [qnPrototype] )
					.addOpcode( Opcode.newfunction,[fxIndex] ) //-1 does nto work ? 2 ,3 is good
					.addOpcode( Opcode.pop ) 
					.addOpcode( Opcode.setproperty, [fxOnPrototypeName] ) 
				
				constructor.methodBody.opcodes.splice( constructor.methodBody.opcodes.length -2, 
					0, m2.opcodes[1], m2.opcodes[2], m2.opcodes[3] ,
					/*m2.opcodes[1], m2.opcodes[2],*/ m2.opcodes[5] )				
				
				
			}
			
			trace('constructior'); 
			var printConstructor : MigrateUtilsPrototypes_Opcodes = new MigrateUtilsPrototypes_Opcodes()
			if ( printConstructor != null && cloneFx != null ) 
			{
				printConstructor.method = cloneFx.methodBody; 
				printConstructor.print();
			}
			
		}
		
		/**
		 * Better cloning than clone method 
		 * returns function with same traints adn parameters
		 * */
		private function cloneFunction(cloneFx:MethodInfo):MethodInfo
		{
			var m : MethodInfo = new MethodInfo();// cloneFx.clone(); 
			
			m.flags = cloneFx.flags; 
			//m.methodName = 'methAdd'+count.toString()
			m.methodName = ''; 
			m.methodName = 'methAdded--'+cloneFx.methodName; 
			m.methodBody = cloneFx.methodBody.clone() as MethodBody;
			m.methodBody.maxScopeDepth = cloneFx.methodBody.maxScopeDepth
			m.methodBody.maxStack = cloneFx.methodBody.maxStack
			m.methodBody.localCount = cloneFx.methodBody.localCount
			m.methodBody.initScopeDepth = cloneFx.methodBody.initScopeDepth
			m.methodBody.traits = [] ; 
			
			m.methodBody.backPatches = cloneFx.methodBody.backPatches ; 
			m.methodBody.exceptionInfos = cloneFx.methodBody.exceptionInfos; 
			cloneFx.methodBody.opcodeBaseLocations = null
			m.as3commonsBytecodeName = new QualifiedName('', LNamespace.PUBLIC,MultinameKind.QNAME ) 
			//m.methodBody = new MethodBody();
			//m.methodBody.opcodes = [] ; 
			
			for each ( var arg : Argument in cloneFx.formalParameters )
			{
				m.addArgument( arg ) ; 
			}
			for each ( arg in cloneFx.optionalParameters )
			{
				m.addArgument( arg ) ; 
			}
			
			
			//cloneFx.paramCount
			m.scopeName = cloneFx.scopeName; 
			m.returnType = cloneFx.returnType;
			
			m.methodBody.opcodes = cloneFx.methodBody.opcodes.concat()
			//clear method/ function
			//m.methodBody.opcodes = []
			//m.methodBody.opcodes.push( new Op(Opcode.returnvoid) )
			
			m.methodBody.methodSignature = m; 
			return m;
		}
		private function fxIsDefaultEventListener(cloneFx:MethodInfo):Boolean
		{
			if ( cloneFx.formalParameters.length == 1 )
			{
				var firstArg : Argument = cloneFx.formalParameters[0] as Argument
				var arg1Qn : QualifiedName = firstArg.type as QualifiedName 
				var autoGenedClass:Boolean
				if ( cloneFx.methodName.indexOf( '___'+this.classNameNoPackage +'_' ) != -1 )
				{
					trace('autogen class', cloneFx.methodName); 
					autoGenedClass = true
				}
				var firstEventMouse : Boolean = false 
				if (arg1Qn.nameSpace.name.indexOf('event') != -1 && arg1Qn.name.indexOf('Mouse') != -1 )
				{
					firstEventMouse = true
				}
				if (  autoGenedClass ) 
				{
					if ( this.searchForOpCodeCombo( cloneFx.methodBody.opcodes, [Opcode.getlocal_0, Opcode.getlocal_1] ) )
					{
						//funcs.splice( funcs.indexOf( fxName ), 1 ) ; 
						/*this.removeOpCodeNamespace( cloneFx.methodBody.opcodes, this.classAsNamespaceName ) 
						this.addTrace( cloneFx.methodBody.opcodes, 4, '~~~~In class version::'+ this.className ); */
						//continue;
						return true; 
					}
				}
				
			}
			return false;
		}
		
		/**
		 * Returns true if function is autogenerate to add to mxmlcontent
		 * */
		private function fxIsUICompCreator(cloneFx:MethodInfo):Boolean
		{
			//private function _TestView_Button2_c() : Button
			//{
			//	_as3_getlocal <0> 
			if ( cloneFx.returnType['name'] != 'void' && cloneFx.methodName.indexOf('_') == 0 ) 
			{
				if ( this.searchForOpCodeCombo( cloneFx.methodBody.opcodes, [Opcode.getproperty, Opcode.callproperty] ) )
				{
					return true; 
				}
			}
			return false;
		}
		
		private function searchForOpCodeCombo(opcodes:Array, combo:Array):Boolean
		{
			for ( var i : int = 0 ; i < opcodes.length ; i++ )// in opcodes ) 
			{
				var op : Op = opcodes[i] as Op; 
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
						return true; 
				}
			}
			return false;
		}
		private function searchForOpCodeCombo_Index(opcodes:Array, combo:Array):int
		{
			for ( var i : int = 0 ; i < opcodes.length ; i++ )// in opcodes ) 
			{
				var op : Op = opcodes[i] as Op; 
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
						return i; ; 
				}
			}
			return -1;
		}
		private function removeOpCodeNamespace(opcodes:Array, classAsNamespaceName:String):void
		{
			//could limit this to functions only 
			// TODO Auto Generated method stub
			for each ( var op : Op in opcodes ) 
			{
				if ( op.opcode.opcodeName == Opcode.callproperty.opcodeName) 
				{
					var qn : QualifiedName = op.parameters[0] as QualifiedName
					//qnqn.fullName.replace( classAsNamespaceName, '' ) 
					/*		if ( qn.name.indexOf('click') != -1 ) 
					continue;*/ //...?
					if ( qn != null && qn.name.indexOf( this.propRenameFx_Preamble ) == 0 )
					{
						var qn2 : QualifiedName = new QualifiedName( qn.name.replace( propRenameFx_Preamble, '' ), 
							LNamespace.PUBLIC, MultinameKind.QNAME ) 
						var params : Array = [qn2]	
						for ( var i : int = 1; i < op.parameters.length; i++ )
						{
							params.push( op.parameters[i] )
						}
						var opCode2 : Op = new Op(Opcode.callproperty,params)
						opcodes.splice( opcodes.indexOf( op ), 1, opCode2 ); 
					}
					/*if ( qn.nameSpace.kind.byteValue != 5 )
					continue; 
					qn.nameSpace = LNamespace.PUBLIC*/
					continue; 
					//opcodes.splice( opcodes.indexOf( op ) , 1 ) ; 
				}
				if ( op.opcode.opcodeName == Opcode.getproperty.opcodeName) 
				{
					
					qn = op.parameters[0] as QualifiedName
					/*if ( qn is QualifiedName ) {} 
					else
					{
					continue; 
					}*/
					if ( qn == null ) continue; 
					if ( qn.name.indexOf( this.propRenameFx_Preamble ) == 0 )
					{
						qn2 = new QualifiedName( qn.name.replace( propRenameFx_Preamble, '' ), 
							LNamespace.PUBLIC, MultinameKind.QNAME ) 
						params = [qn2]	
						for ( i = 1; i < op.parameters.length; i++ )
						{
							params.push( op.parameters[i] )
						}
						opCode2 = new Op(Opcode.callproperty,params)							
						opCode2 = new Op(Opcode.getproperty,params)
						opcodes.splice( opcodes.indexOf( op ), 1, opCode2 ); 
					}
					continue; 
					//opcodes.splice( opcodes.indexOf( op ) , 1 ) ; 
				}
				
			}
			return; 
		}
		
		
		private function opAdjust_CallMethAsFunc(opcodes:Array ): Boolean
		{
			//find all properties getproperty that refers to something in private namespaces
			//use string instead
			//pushstring name
			//pushstring
			/**
			 * check for seuqence
			 * getperoperty 
			 * callproprety, get id
			 * 
			 * 
			 * */
			var changed:Boolean;
			//var i : int = searchForOpCodeCombo_Index(opcodes, [Opcode.getproperty, Opcode.callproperty] ) ; 
			var fx : MethodInfo =getMethodByName( 'fxInject__recieveEvents' ) ; 
			var index : int = this.abcFile.methodInfo.indexOf( fx ) ; 
			for each ( var op : Op in opcodes.concat() ) 
			{
				if ( op.opcode.opcodeName == Opcode.callproperty.opcodeName) 
				{
					var qn : QualifiedName = op.parameters[0] as QualifiedName
					//this.funcs.indexOf( qn.name.indexOf( this.propRenameFx_Preamble ) == 0 
					if ( this.funcs.indexOf( qn.name ) != -1 )
					{
						var qn2 : QualifiedName = new QualifiedName( qn.name.replace( propRenameFx_Preamble, '' ), 
							LNamespace.PUBLIC, MultinameKind.QNAME ) 
						var params : Array = [qn2]	
						for ( var i : int = 1; i < op.parameters.length; i++ )
						{
							params.push( op.parameters[i] )
						}
						
						
						
						var m2 : MethodBuilder = new MethodBuilder()
						m2.addOpcode( Opcode.pushstring, [qn.name] )
							.addOpcode( Opcode.callmethod, [index,2] );
						opcodes.splice( opcodes.indexOf( op ), 1, m2.opcodes[0], m2.opcodes[1] ); 
					}
					/*if ( qn.nameSpace.kind.byteValue != 5 )
					continue; 
					qn.nameSpace = LNamespace.PUBLIC*/
					changed = true
					continue; 
					//opcodes.splice( opcodes.indexOf( op ) , 1 ) ; 
				}
			}
			
			return changed
		}
		/**
		 * Same as above except it will try to use the parentdocument
		 * */
		private function opAdjust_CallMethAsFunc2(opcodes:Array ): Boolean
		{
			//find all properties getproperty that refers to something in private namespaces
			//use string instead
			//pushstring name
			//pushstring
			/**
			 * check for seuqence
			 * getperoperty 
			 * callproprety, get id
			 * 
			 * 
			 * */
			var changed:Boolean;
			//var i : int = searchForOpCodeCombo_Index(opcodes, [Opcode.getproperty, Opcode.callproperty] ) ; 
			var fx : MethodInfo =getMethodByName( 'fxInject__recieveEvents' ) ; 
			var index : int = this.abcFile.methodInfo.indexOf( fx ) ; 
			for each ( var op : Op in opcodes.concat() ) 
			{
				if ( op.opcode.opcodeName == Opcode.callproperty.opcodeName) 
				{
					var qn : QualifiedName = op.parameters[0] as QualifiedName
					//this.funcs.indexOf( qn.name.indexOf( this.propRenameFx_Preamble ) == 0 
					if ( this.funcs.indexOf( qn.name ) != -1 )
					{
						var qn2 : QualifiedName = new QualifiedName( qn.name.replace( propRenameFx_Preamble, '' ), 
							LNamespace.PUBLIC, MultinameKind.QNAME ) 
						var params : Array = [qn2]	
						for ( var i : int = 1; i < op.parameters.length; i++ )
						{
							params.push( op.parameters[i] )
						}
						
						
						
						var m2 : MethodBuilder = new MethodBuilder()
						m2.addOpcode( Opcode.getproperty, [new QualifiedName('currentTarget', LNamespace.PUBLIC,MultinameKind.QNAME) ] )
							.addOpcode( Opcode.getproperty, [new QualifiedName('parentDocument', LNamespace.PUBLIC,MultinameKind.QNAME) ] )
							.addOpcode( Opcode.getlocal_1 )
						opcodes.splice( opcodes.indexOf( op )-2, 1,m2.opcodes[2] , m2.opcodes[0], m2.opcodes[1]); 
					}
					/*if ( qn.nameSpace.kind.byteValue != 5 )
					continue; 
					qn.nameSpace = LNamespace.PUBLIC*/
					changed = true
					continue; 
					//opcodes.splice( opcodes.indexOf( op ) , 1 ) ; 
				}
			}
			
			return changed
		}
		private function opAdjust_CallPrivateAsString(opcodes:Array ):void
		{
			//find all properties getproperty that refers to something in private namespaces
			//use string instead
			//pushstring name
			//pushstring
			/**
			 * check for seuqence
			 * getperoperty 
			 * callproprety, get id
			 * 
			 * 
			 * */
			
			var i : int = searchForOpCodeCombo_Index(opcodes, [Opcode.getproperty, Opcode.callproperty] ) ; 
			
			
			if ( i > 0 ) 
			{
				var op : Op = opcodes[i] as Op
				var prop : String = op.parameters[0].fullName; 
				var ml : MultinameL = new MultinameL(NamespaceSet.PUBLIC_NSSET, MultinameKind.MULTINAME_L ) ; 
				
				var m2 : MethodBuilder = new MethodBuilder()
				m2.addOpcode( Opcode.pushstring, [prop] )
					.addOpcode( Opcode.getproperty, [ml] )
					.addOpcode( Opcode.getlocal_1 )
					.addOpcode( Opcode.call, [1] );
				opcodes.splice( i, 2 ); 
				this.opCodesAddAtIndex( opcodes, m2.opcodes, i ) ;
			}
			return; 
		}
		
		private function removeOpCode(opcodes:Array, removeCode:Opcode, fromIndex : int =0):void
		{
			// TODO Auto Generated method stub
			for each ( var op : Op in opcodes ) 
			{
				if ( op.opcode.opcodeName == removeCode.opcodeName ) 
				{
					opcodes.splice( opcodes.indexOf( op, fromIndex ) , 1 ) ; 
				}
			}
			return; 
		}
		private function opCodesAddAtIndex(opcodes:Array, addOpCodes : Array, index : int =0):void
		{
			var count : int = 0
			for each ( var op : Op in addOpCodes ) 
			{
				opcodes.splice( index+count , 0, op ) ; 
				count++
			}
			return; 
		}
		private function addTrace(opcodes:Array, index:int, msg : String):void
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
				opcodes.splice( index+count, 0, op )
				count++
			}
		}
		private function initBlocking():void
		{
			//return;
			var constructor : MethodInfo = this.getConstructor( )
			constructor.methodBody.maxStack++ //3/8/12 fix for overload
			var m2 : MethodBuilder = new MethodBuilder()
			var ooo : Object = this.abcFile.constantPool.namespacePool 
			var ns : LNamespace = this.abcFile.constantPool.namespacePool[2]; 
			ns = new LNamespace(NamespaceKind.PACKAGE_NAMESPACE, ""); 
			//	var qnPrototype : QualifiedName = new QualifiedName('prototypeXd', x,MultinameKind.QNAME ) ; 
			//var x : Multiname = new Multiname( 'prototype', m, MultinameKind.MULTINAME )
			//var ii : int = this.abcFile.constantPool.getMultinamePosition(x)
			var qnPrototype : QualifiedName = new QualifiedName('prototype', LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
			var initedProp : QualifiedName = new QualifiedName('inited', LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
			var ii : int = this.abcFile.constantPool.getMultinamePositionByName( 'prototype' ) 
			qnPrototype = this.abcFile.constantPool.multinamePool[ii]
			//	if ( qnPrototype == null ) 
			qnPrototype = new QualifiedName('prototype', LNamespace.PUBLIC,MultinameKind.QNAME ) ; 
			m2.addOpcode( Opcode.findpropstrict, [qnPrototype] )
				.addOpcode( Opcode.getproperty, [qnPrototype] )
				.addOpcode( Opcode.getproperty, [initedProp] )			
				.addOpcode( Opcode.pushtrue )		
				.addOpcode( Opcode.ifne, [1] )	
				.addOpcode( Opcode.returnvoid )		
				.addOpcode( Opcode.findpropstrict, [qnPrototype] )
				.addOpcode( Opcode.getproperty, [qnPrototype] )
				.addOpcode( Opcode.pushtrue )		
				.addOpcode( Opcode.setproperty, [initedProp] ) 
			var count : int = 0 ; 
			for each ( var op : Op in m2.opcodes )
			{
				/*constructor.methodBody.opcodes.splice( 
				constructor.methodBody.opcodes.length -2, 0, op )
				*/	
				//constructor.methodBody.opcodes.splice( count , 0, op )
				constructor.methodBody.opcodes.splice( 
					constructor.methodBody.opcodes.length -2, 0, op )
				count++
			}
			/*
			constructor.methodBody.opcodes.splice( constructor.methodBody.opcodes.length -2, 
			0, m2.opcodes[1], m2.opcodes[2], m2.opcodes[3] ,m2.opcodes[5] )	
			*/
		}
		
		private function getAllFunctions():Array
		{
			var output : Array = [] ; 
			for each ( var o : MethodInfo in this.abcFile.methodInfo ) 
			{
				if ( o.as3commonsBytecodeName == 'constructor' )
				{ if ( this.extendsSparks() == false )
				{
					continue;
				}
				else
				{
					//output.push( 'constructor' )
					//continue
					constructorName = o.methodName;
				}
				}
				if ( o.methodName == '' ) 
					continue; 				
				//if ( debugFunctionNames ) 
				//	trace( o.methodName ) ;
				/*if ( o.methodBody.traits.length > 0 )
				{
				for each ( var t : SlotOrConstantTrait in o.methodBody.traits ) 
				{
				if ( t.isStatic ) 
				continue; 
				trace();
				}
				}*/
				mTrait = null; 
				if ( o.as3commonsByteCodeAssignedMethodTrait != null ) 
				{
					var mTrait : MethodTrait = o.as3commonsByteCodeAssignedMethodTrait as MethodTrait; 
					if (mTrait.isSetter || mTrait.isGetter || mTrait.isStatic )
						continue; 
				}
				if ( mTrait != null ) 
				{
					//((this.abcFile.instanceInfo[0] as InstanceInfo).superclassMultiname as QualifiedName).fullName.indexOf('spark')
					if (mTrait.isOverride && o.methodName == 'initialize' )
						continue; 
				}
				if ( debugFunctionNames ) 
					trace( o.methodName ) ;
				output.push( o.methodName ); 
			}
			return output;
		}
		
		
		
		public function errorHandler(event:Event):void 
		{
			trace('errorHandler')
		}
		
		public function loadedHandler(event:Event):void 
		{
			if ( this.skippedConversion ) 
				return; 
			//var className : String = 'blah.Foo2'
			//var clazz:Class = ApplicationDomain.currentDomain.getDefinition(className) as Class;
			if ( this.appDomain != null ) 
				var clazz:Class = this.appDomain.getDefinition(className) as Class;
			else
				clazz = ApplicationDomain.currentDomain.getDefinition(className) as Class;
			
			this.tryToCaptureClass()
			
			if ( this.version == 1 ) 
			{
				this.tracex('version 1', this.className ) ; 
				this.copyFunctions( clazz ); 
			}
			else
			{
				//should send in the old prototype ... 
				var existingClazz:Class = ApplicationDomain.currentDomain.getDefinition(this.originalClassName) as Class;
				var curentD : ApplicationDomain = ApplicationDomain.currentDomain; 
				this.copyFunctions2( existingClazz, clazz ); 
			}
			
			if ( this.fxCallback != null ) 
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
		
		private function tracex(... rest ):void
		{
			// TODO Auto Generated method stub
			rest.unshift( this.debugName ) ;
			trace.apply( this, rest ) 	
		}		
		
		private function copyFunctions(clazz : Object):void
		{
			trace('copyfunctions'); 
			trace(';;;;;'); 
			try {
				var instance:Object = new clazz(); //make default paramets nullable ... to avoid problems
			}
			catch ( e : Error ) 
			{
				tracex('need to update so we call statct property, not reinit classes', this.className ) 
				return; 
			}
			if ( this.className == 'blah.Foo' ) 
			{
				try
				{
					instance.fxStore__getPrivateBar();
				} 
				catch(error:Error) 
				{
					trace('no') 
				}
				try
				{
					instance.getPrivateBar()
				} 
				catch(error:Error) 
				{
					trace('no') 
				}
				
			}
			for each ( var func : String in this.funcs ) 
			{
				//do i have to make fxs here? i don't think so ... 
				var fxName : String = this.convertFxNameToProp(func);
				if ( this.fxOnPrototypes == false ) 
					clazz.prototype[func] = clazz.prototype[fxName];
				/*
				clazz.prototype[func+'1'] = clazz.prototype[fxName];
				clazz.prototype[func] = function (...args):Object
				{
				trace('test');
				var fx : Function = this[func+'1']
				//fx.apply(
				return this[func+'1'].apply(this, args)
				} 
				*/
				//clazz.prototype[func] = instance[fxName]
				//delete clazz.prototype[fxName]
			}
			if ( this.className == 'blah.Foo' ) 
			{
				try
				{
					instance.fxStore__getPrivateBar();
				} 
				catch(error:Error) 
				{
					trace('no') 
				}
				try
				{
					instance.getPrivateBar()
				} 
				catch(error:Error) 
				{
					trace('no') 
				}
				
			}
			return;
		}
		private function copyFunctions2(existingClazz:Class, clazz:Class):void
		{
			try {
			var instance:Object = new clazz(); //make default paramets nullable ... to avoid problems
			}
			catch ( e : Error )
			{ var arg : ArgumentError;
				trace(e) ; 
			}
			var type:Type = Type.forClass(clazz); 
			
			for each ( var staticProp : Variable in type.staticVariables )
			{
				existingClazz[staticProp.name] = clazz[staticProp.name]
			}
			/*if ( this.isTestClass ) 
			trace( 'test' ,instance.getPrivateBar() )*/
			for each ( var func : String in this.funcs ) 
			{
				//do i have to make fxs here? i don't think so ... 
				/*var fxName : String = this.convertFxNameToProp(func)
				existingClazz.prototype[func] = instance[fxName]
				*/
				//existingClazz.prototype[func]		= null
				//	delete existingClazz.prototype[func]		
				//var fxName : String = this.convertFxNameToProp(func);
				if ( func == this.constructorName ) 
					func = 'fauxConstructor' 
				existingClazz.prototype[func] = clazz.prototype[func];
				
				var fxName : String = this.convertFxNameToRenamed(func);
				//existingClazz.prototype[fxName] = clazz.prototype[func];
				/*var privateName : String = this.convertFxNameToRenamed(func);
				existingClazz.prototype[privateName] = clazz.prototype[fxName];				
				//clazz.prototype[func] = instance[fxName]
				existingClazz.prototype[func+1] = clazz.prototype[fxName];
				existingClazz.prototype[func] = function (...args):Object
				{
				trace('test');
				return null;
				//return this[func+'1'].apply(this, args)
				}*/
				//clazz.prototype[func] = clazz.prototype[fxName];
			}
			
			//this.reloadInstances()

			if ( this.isTestClass )
			{
				/*privateName = convertFxNameToProp('getPrivateBar')
				var fx : Function = clazz.prototype[privateName];
				existingClazz.prototype['boo1'] = clazz.prototype[privateName];
				existingClazz.prototype['boo1'] = function () : String
				{
				trace(this)
				trace('boo 1');
				return 'boo1 ok'
				}*/
				try {
					trace( 'test' ,instance.getPrivateBar() )
					var instance2:Object = new existingClazz()
					trace( 'test' ,instance2.getPrivateBar() )
					//existingClazz.prototype[func] = clazz.prototype[fxName]; 
					trace( 'test again' ,instance2.getPrivateBar() )
				}
				catch ( e : Error ) 
				{
					
				}
				//trace( 'test boo1' ,instance2['boo1']() )
				//fx();
				return;
			} 
		}
		
		/**
		 * For classes that need htier instances reloaded, handle this 
		 * after all classes have been processed. 
		 * */
		public function reloadInstances(delayed: Boolean = false):void
		{
			/*if ( delayed == false ) 
			{
				setTimeout( this.reloadInstances,
			}*/
			if ( this.extendsSparks() ) 
			{
				try {
					/*var o : Object = instance._TestView_Button2_c(); 
					instance.button2_clickHandler(null);
					trace(o.label ); */
				}
				catch ( e : Error ) 
				{
					/*trace('wat'); */
				}
				ReloadableView2.check(this.originalClassName)
			}
			ReloadableGen.check(this.originalClassName)
		}
		
		private function extendsSparks():Boolean
		{
			var inst : InstanceInfo = this.abcFile.instanceInfo[0] as InstanceInfo
			if ( inst.superclassMultiname != null ) 
			{
				var superClassQN : QualifiedName = inst.superclassMultiname as QualifiedName; 
				if ( superClassQN.fullName.indexOf('spark.comp') == 0 ) 
				{
					return true
				}
			}
			return false;
		}
		
		private function extendsClass(str : String):Boolean
		{
			var inst : InstanceInfo = this.abcFile.instanceInfo[0] as InstanceInfo
			if ( inst.superclassMultiname != null ) 
			{
				var superClassQN : QualifiedName = inst.superclassMultiname as QualifiedName; 
				if ( superClassQN.fullName.indexOf(str) == 0 ) 
				{
					return true
				}
			}
			return false;
		}
		
		public var propStoreFx_Preamble : String = 'fxStore__'
		public var propRenameFx_Preamble : String =   'fxInject__' 
		private var version:int;
		private var appDomain:ApplicationDomain;
		private var fxCallback:Function;
		private var debugFunctionNames:Boolean=true;
		private var mode_ReloadInstant:Boolean;
		private var constructorName:String;
		private var fxOnPrototypes:Boolean=true;
		private var tryToRemoveFxOnly:Boolean=false;
		/**
		 * TestView::
		 * */
		private var classAsNamespaceName:String;
		/**
		 * TestView
		 * */
		private var classNameNoPackage:String;
		private var newConstructoMethodName:String;
		private var originalClassPackage:String;
		private var debugName:String = 'MigrateUtilsProtoype';
		/**
		 * Flag is true when item is changed
		 * */
		private var skippedConversion:Boolean;
		private var nameOriginal:String;
		private var classNameOnly:String;
		private var newConstructoMethodName_orig:String;
		private var className_Colon:String;
		/**
		 * Stores functions that are overriden here
		 * */
		private var methods_Override:Array = [] ;
		/**
		 * if set, will abandon override methods 
		 * 
		 * */
		private var mode_skipOverrideMethods:Boolean = true;
		/**
		 * if true will not migrate any classes to prototypes
		 * */
		private var mode_skipConversion:Boolean= false; 
		public function convertFxNameToProp(s : String ) : String
		{
			return propStoreFx_Preamble+s
		}
		
		private function convertFxNameToRenamed(methodName:String):String
		{
			return propRenameFx_Preamble+methodName;
		}
		private function get isTestClass( ):Boolean
		{
			if ( this.className == 'blah.Foo' || this.originalClassName == 'blah.Foo' ) 
				return true
			return false; 
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
		
		private function getMethodByName(fxName:String):MethodInfo
		{
			for each ( var o : MethodInfo in this.abcFile.methodInfo ) 
			{
				if ( o.methodName == fxName ) 
					return o; 
			}
			return null;
		}		
		
		
		/**
		 * Iseless ... try to capture class when we were having issues, looks like it was a string pool issue ... 
		 * if u rename something, make sure to update the constant string pool ... 
		 * */
		private function tryToCaptureClass():void
		{
			var clazz2:Class
			var clazz3:Class
			var clazz4:Class
			if ( this.appDomain != null ) 
				var clazz:Class = this.appDomain.getDefinition(className) as Class;
			else
				clazz = ApplicationDomain.currentDomain.getDefinition(className) as Class;
			try
			{
				clazz4 = ApplicationDomain.currentDomain.getDefinition(className) as Class;
			} 
			catch(error:Error) 
			{
				trace('class failed 1'); 
			}
			try
			{
				clazz2 = ApplicationDomain.currentDomain.getDefinition(className) as Class;
			} 
			catch(error:Error) 
			{
				trace('class failed 2'); 
			}			
			try
			{
				clazz3 = this.appDomain.getDefinition(this.originalClassName) as Class; 
			} 
			catch(error:Error) 
			{
				trace('class failed 3'); 
			}
			return; 
		}
		
	}
}