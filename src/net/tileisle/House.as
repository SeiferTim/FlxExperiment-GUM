package net.tileisle 
{
	import flash.display.BitmapData;
	import org.flixel.FlxSprite;
	import flash.geom.Rectangle;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author ...
	 */
	public class House extends FlxSprite 
	{
		
		private const COLOR_TRUNK:Array = new Array(0xff5C4425, 0xff736149, 0xff8A847D, 0xff573A14);
		
		private const COLOR_PAINT:Array = new Array(0xffF2F2F2, 0xff821D1D, 0xffFCFFB0, 0xff8A1D2F);
		
		
		
		private var _w:World;
		private var _paint:uint;
		private var _owned:Boolean;
		private var _birthing:Boolean;
		
		private var _delay:Number;
		
		
		public function House(w:World,X:Number,Y:Number) 
		{
			super(X, Y - 4);
			health = 0;
			_w = w;
			makeGraphic(5, 5, 0x00000000);
			pixels = new BitmapData(5, 5, true, 0x00000000);
			dirty = true;
			width = 5;
			height = 5;
			x = X;
			y = Y - 5;
			_owned = false;
			_birthing = false;
			_delay = 0;
			for (var i:int = x - 1; i < x + 7; i++)
			{
				if (_w.ground.points[i] > Y)
				{
					_w.ground.fillGround(i, _w.ground.points[i] - Y);
				}
				else if (_w.ground.points[i] < Y)
				{
					_w.ground.cutGround(i, Y -_w.ground.points[i]);
				}
			}
			_w.ground.GroundMap.dirty = true;
			_paint = COLOR_PAINT[SeedRnd.integer(0, COLOR_TRUNK.length)];
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
			
			if (Value == 0 || health == 51) return;
			var color:uint;
			
			for (var i:int = health; i < health + Value; i++)
			{
				if (i <= 25)
				{
					color = COLOR_TRUNK[SeedRnd.integer(0, COLOR_TRUNK.length)];
					var pY:int = i / 5;
					var pX:int = i % 5;
					if (pX == 2 && pY < 2)
						pixels.setPixel32(pX, 4 - pY, 0xff333333);
					else
						pixels.setPixel32(pX, 4 - pY, color);
				}
				else if (i <= 50)
				{
					var jY:int = (i-26) / 5;
					var jX:int = (i-26) % 5;
					if (!(jX == 2 && jY < 2))
						pixels.setPixel32(jX, 4 - jY, _paint);
				}
			}
			
			dirty = true;
			
			health += Value;
			if (health > 50) health = 51;
		}
		
		override public function update():void
		{
			if (_birthing)
			{
				if (_delay > 2)
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
				
				
			}
			super.update();
			
		}
		
	}

}