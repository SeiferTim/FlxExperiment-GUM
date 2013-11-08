package net.tileisle 
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author ...
	 */
	public class Smoke extends FlxSprite
	{
		private const COLOR_SMOKE:Array = new Array(0xff333333, 0xff666666, 0xff969696);
		
		public function Smoke() 
		{
			super(0, 0);
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			alpha = 1;
			var size:int = SeedRnd.integer(1, 3);
			makeGraphic(size, size, COLOR_SMOKE[SeedRnd.integer(0, COLOR_SMOKE.length)]);
			velocity.y = -3;
			velocity.x = 6 * ( -1 * SeedRnd.float(0.8, 1.2));
			
		}
		
		override public function update():void
		{
			if (alpha > 0)
			{
				alpha -= FlxG.elapsed * 0.3;
				velocity.x *= ( -1 * SeedRnd.float(0.8, 1.2));
			}
			else
				kill();
			super.update();
			
		}
		
		
	}

}