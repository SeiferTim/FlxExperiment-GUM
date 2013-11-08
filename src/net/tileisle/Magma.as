package net.tileisle 
{
	import flash.display.BitmapData;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import org.flixel.plugin.photonstorm.FlxGradient;
	import org.flixel.plugin.photonstorm.FlxCollision;
	import org.flixel.plugin.photonstorm.FlxColor;
	/**
	 * ...
	 * @author ...
	 */
	public class Magma 
	{
		private var COLORS_MAGMA:Array;
		
		private var _w:World;
		private var _mSpr:FlxSprite;
		
		private var _m:Vector.<MagmaParticle>
		
		public function Magma(W:World) 
		{
			_w = W;
			_m = new Vector.<MagmaParticle>;
			_mSpr = new FlxSprite(0, 0);
			_mSpr.makeGraphic(FlxG.width, FlxG.height, 0x00000000,true);
			COLORS_MAGMA = new Array();
			COLORS_MAGMA = FlxGradient.createGradientArray(20, 20, [0xffFF6600, 0xffFFD52B, 0xffFFF700]);
		}
		
		public function CheckMPos(X:Number, Y:Number):Boolean
		{
			if (FlxColor.getAlpha(_mSpr.pixels.getPixel32(X, Y)) >= 255) return true;
			return false;
		}
		
		private function ParticleSort(mA:MagmaParticle, mB:MagmaParticle):Number
		{
			if (mA.y > mB.y)
				return -1;
			else if (mA.y < mB.y)
				return 1;
			else
				return 0;
		}
		
		public function update():void
		{
			// sort the magma vector...
			_m.sort(ParticleSort);
			var mP1:FlxPoint;
			for each (var mP:MagmaParticle in _m)
			{
				mP1 = new FlxPoint(mP.x, mP.y);
				if (!CheckMPos(mP.x + 0, mP.y + 1) && !_w.isSolid(mP.x + 0, mP.y + 1))
				{
					mP.y++;
				}
				else  
				{
					var dirChoice:Array = new Array();
					if (CheckMPos(mP.x, mP.y - 1) || (CheckMPos(mP.x - 1 , mP.y - 1) && CheckMPos(mP.x - 1, mP.y)) || (CheckMPos(mP.x + 1 , mP.y - 1) && CheckMPos(mP.x + 1, mP.y)))
					{
						
						if (!CheckMPos(mP.x - 1, mP.y) && !_w.isSolid(mP.x - 1, mP.y))
							dirChoice.push( -1);
						
						if (!CheckMPos(mP.x + 1, mP.y) && !_w.isSolid(mP.x + 1, mP.y))
							dirChoice.push(1);
							
						if (dirChoice.length > 0)
						{
							mP.x += dirChoice[SeedRnd.integer(0, dirChoice.length)];
						}
					}
					else
					{
						if (!CheckMPos(mP.x - 1, mP.y +1 ) && !_w.isSolid(mP.x - 1, mP.y +1))
							dirChoice.push( -1);
						
						if (!CheckMPos(mP.x + 1, mP.y+1) && !_w.isSolid(mP.x + 1, mP.y+1))
							dirChoice.push(1);
							
						if (dirChoice.length > 0)
						{
							mP.y++;
							mP.x += dirChoice[SeedRnd.integer(0, dirChoice.length)];
						}
					}
				}
				_mSpr.pixels.setPixel32(mP1.x, mP1.y, 0x00000000);
				_mSpr.pixels.setPixel32(mP.x, mP.y, COLORS_MAGMA[SeedRnd.integer(0, COLORS_MAGMA.length)]);
			}
			
			_mSpr.dirty = true;
		}
		
		public function get mSpr():FlxSprite
		{
			return _mSpr;
		}
		
		
		public function spawnMagma(X:Number, Y:Number):void
		{
			_m.push(new MagmaParticle(X, Y));
		}
		
	}

}