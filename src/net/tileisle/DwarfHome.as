package net.tileisle 
{
	import org.flixel.FlxSprite;
	import org.flixel.plugin.photonstorm.FlxGradient;
	import flash.display.BitmapData;
	
	public class DwarfHome extends FlxSprite
	{
		private var COLOR_WALL:Array;
				
		private var _w:World;
		private var _paint:uint;
		private var _owned:Boolean;
		private var _birthing:Boolean;
		
		private var _delay:Number;
		
		public function DwarfHome(w:World,X:Number, Y:Number) 
		{
			super(X, Y);
			health = 0;
			_w = w;
			makeGraphic(5, 5, 0x00000000);
			pixels = new BitmapData(5, 5, true, 0x00000000);
			dirty = true;
			width = 5;
			height = 5;
			x = X - 3;
			y = Y - 3;
			_owned = false;
			_birthing = false;
			_delay = 0;
			COLOR_WALL = FlxGradient.createGradientArray(10, 10, [0xFFBA8C00,0xFFF5E16E]);
			_paint = COLOR_WALL[SeedRnd.integer(0, COLOR_WALL.length)];
			for (var i:int = x - 1; i < x + width + 1; i++)
			{
				for (var j:int = y - 1; j < y + height + 1; j++)
				{
					_w.MakeCave(i, j, _w.CORIENT_P);
				}
			}
			
		}
		
		public function set owned(Value:Boolean):void
		{
			_owned = Value;
		}
		
		public function get owned():Boolean
		{
			return _owned;
		}
		
		public function set birthing(Value:Boolean):void
		{
			_birthing = Value;
		}
		
		public function get birthing():Boolean
		{
			return _birthing;
		}
		
		public function build(Value:int):void
		{
			
			if (Value == 0 || health == 26) return;
			var color:uint;
			
			for (var i:int = health; i < health + Value; i++)
			{
				if (i <= 25)
				{
					color = COLOR_WALL[SeedRnd.integer(0, COLOR_WALL.length)];
					var pY:int = i / 5;
					var pX:int = i % 5;
					if (pX >= 1 && pX <= 3 && pY < 2)
						pixels.setPixel32(pX, 4 - pY, 0xff333333);
					else
						pixels.setPixel32(pX, 4 - pY, color);
				}
			}
			
			dirty = true;
			
			health += Value;
			if (health > 25) health = 26;
		}
		
		override public function update():void
		{
			if (_birthing)
			{
				/*if (_delay > 2)
				{
					// spawn some smoke
					_delay = 0;
					var s:Smoke = _w.lyrFX.recycle(Smoke) as Smoke;
					s.reset(x + width - 1, y - 3);
				}
				else
				{
					_delay += FlxG.elapsed * 4;
				}
				*/
				
			}
			super.update();
			
		}
		
		
	}

}