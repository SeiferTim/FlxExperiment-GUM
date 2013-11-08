package net.tileisle 
{
	
	/**
	 * ...
	 * @author ...
	 */
	public class MagmaParticle 
	{
		
		private var _x:int;
		private var _y:int;
		
		private var _temp:Number;
		
		public function MagmaParticle(X:Number, Y:Number):void 
		{
			_x = X;
			_y = Y;
			_temp = 1;
		}
		
		
		public function set x(Value:int):void
		{
			_x = Value;
		}
		
		public function get x():int
		{
			return _x;
		}
		
		public function set y(Value:int):void
		{
			_y = Value;
		}
		
		public function get y():int
		{
			return _y;
		}
		
		public function set temp(Value:Number):void
		{
			_temp = Value;
		}
		
		public function get temp():Number
		{
			return _temp;
		}
		
	}

}