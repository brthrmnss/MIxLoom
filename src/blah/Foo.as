/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/23/11
 * Time: 1:47 PM
 */
package blah
{
	//import preloader.StringModifierPatcherPreloader;
	
	dynamic public class Foo
	{
		public function Foo() 
		{
			//this.fxClone = this.fx; 
			/*this.fxClone = function() : void
			{
			trace('boom'); 
			}*/
			/*if ( prototype.inited == true ) 
			{
			return; 
			}
			prototype.inited = true
			prototype.fxxxx = function () : void
			{
			trace('test3', this )
			} 
			trace('reinit');*/
			var x : Object = new Object()
		/*	function z2():void
			{*/
				x.x = function z3():String
				{
					var s  : String = 'dd e'  
					trace('what is sdtdring....????.', s, this ) ; 
					return s;
				}
			/*}*/
					x.x()
						x['x']()
		}
		
		public function setupPrototype() : void
		{
			prototype.getPrivateBarEx = function ():String
			{
				var s  : String = '111' 
				trace('what is sdtdring....????.', s, this ) ; 
				return s;
			}
		}
		
		//public var str : StringModifierPatcherPreloader;
		public function getPrivateBar():String
		{
			var s  : String = 'stuffz'  
			trace('what is sdtdring....????.', s, this ) ; 
			return s;
		}
		private function getPrivateBar2(input:String):void
		{
			var s  : String = 'getPrivateBar' 
			trace('what is string', s,  input, 'old definition' ) ; 
			//return "privadte bar";
		}
		public function getBar():String
		{
			return "a bar";
		}
		public function getBar2():String
		{
			return "a bar";
		}
		/*override flash_proxy function getProperty(name:*):* {
		return this[name];
		}*/
		private var xF :  int = 5  ;//
		public var ZZ : String = '';
		/*= function (d:XML): void
		{
		trace('ddd');
		}*/
		
		public function pubMeth () : void{
			
		} 
		
		public var fx :Function/* =  function () : void
		{
		trace('test3', this )      
		}*/
		
		public var fxClone :Function  /* =function () : void
		{
		trace('test4', this )
		}*/
		
		public  function fxFunc () : void
		{
			trace('test3', this )
		}
		
		public function testCall( a : Array, b : Array, c : Array, d : Array, e :  Array ) : void
		{
			//this.testCall.call( this, a, b );    
			this['testCall'].call( this, a, b, c, d, e ); 
		}
		
	}
}