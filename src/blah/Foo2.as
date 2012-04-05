/**
 * Created by IntelliJ IDEA.
 * User: James Ward <james@jamesward.org>
 * Date: 3/23/11
 * Time: 1:47 PM
 */
package blah
{
	dynamic public class Foo2
	{
		private function getPrivateBar():String
		{
			var s  : String = 'getPrivateBar' 
			trace('what is string', s ) ; 
			return "privadte bar";
		}
		private function getPrivateBar2(input:String):void
		{
			var s  : String = 'getPrivateBar' 
			trace('what is string', s,  input ) ; 
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
		public var xF : Function = function (d:XML): void
		{
			trace('ddd');
		}
	}
}