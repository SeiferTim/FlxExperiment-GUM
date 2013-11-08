package net.tileisle 
{
	import flash.display.BitmapData;
	import flash.display.NativeMenu;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxGradient;

	/**
	 * ...
	 * @author Tim
	 */
	public class Ground 
	{
		
		//The GROUND is in charge of where above and below ground exist
		
		private var COLOR_SNOW:Array;// = new Array(0xFFe4e0f7, 0xffebe9e6, 0xffeeedea, 0xfff2f6f6);
		private var COLOR_STONE:Array;// = new Array( 0xFFB5B5B5, 0xff5c5f52, 0xFF13152e);
		private var COLOR_DIRT:Array;// = new Array(0xFFA89467, 0xFF8A723E, 0xFF8C7F46, 0xFF8C7543);
		private var COLOR_MID:Array;// = new Array(0xFF4F3710, 0xFF362914);
		private var COLOR_DARK:Array;// = new Array(0xFF0F0E0C, 0xFF241E0E);
		
		private var COLOR_GRASS:Array;
		
		private var _groundMap:FlxSprite;
		private var _points:Array;
		
		private var _gs:GameState;
		private var _highest:int;
		private var _lowest:int;
		
		public function get lowest():int
		{
			return _lowest;
		}
		
		public function get highest():int
		{
			return _highest;
		}
		
		public function get GroundMap():FlxSprite
		{
			return _groundMap;
		}
		
		public function get points():Array
		{
			return _points;
		}
		
		public function Ground(GS:GameState) 
		{
			_gs = GS;
			COLOR_SNOW = FlxGradient.createGradientArray(10, 10, [0xFFe4e0f7, 0xffebe9e6, 0xffeeedea, 0xfff2f6f6], 1, 90);
			COLOR_DIRT = FlxGradient.createGradientArray(20, 10, [0xFFA89467, 0xFF8A723E, 0xFF8C7F46, 0xFF8C7543], 1, 90);
			COLOR_MID = FlxGradient.createGradientArray(20, 20, [0xFF4F3710, 0xFF362914], 1, 90);
			COLOR_DARK = FlxGradient.createGradientArray(20, 20, [0xFF0F0E0C, 0xFF241E0E], 1, 90);
			COLOR_GRASS = FlxGradient.createGradientArray(20, 20, [0xff004217, 0xff5BDB42], 1, 90);
		}
		
		public function cutGround(X:Number, Amt:Number):void
		{
			if (Amt < 0) return;
			for (var i:int = points[X]; i < points[X]+Amt; i++)
				GroundMap.pixels.setPixel32(X, i, 0x00000000);
			points[X] += Amt;
			GroundMap.dirty = true;
		}
		
		public function fillGround(X:Number, Amt:Number):void
		{
			if (Amt < 0) return;
			for (var i:int = points[X]-Amt; i < points[X]; i++)
				GroundMap.pixels.setPixel32(X, i, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
			points[X] -= Amt;
			GroundMap.dirty = true;
		}
		
		public function GenerateGround(Seed:Number = 0):void
		{
			
			if (Seed == 0)
				FlxG.globalSeed = SeedRnd.random(false);
			else
				FlxG.globalSeed = Seed;
			// start about 3/8 up the screen and start drawing a line of pixels moving gradually up until we get about half-way, and then go down instead
			var canvas:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x00000000);
			var y:int = (FlxG.height / 20) * 12;
			var stY:int = y;
			var colorsArr:Array = new Array();
			
			_points = new Array();
			
			var nY:int;
			nY = y;
			var mid:int = (FlxG.width / 2) + SeedRnd.integer(-FlxG.width*0.1,FlxG.width*0.1);
			var slope:Number;
			var hiPt:int = SeedRnd.integer(20, 60);//FlxG.height;
			var loPt:int = 0;
			var aX:int = SeedRnd.integer(2, mid * 0.25);
			var bX:int = SeedRnd.integer(mid * 1.75, FlxG.width - 2);
			
			
			
			for (var x:int = 0; x <= FlxG.width; x++)
			{
				
				if (x > aX && x < bX)
				{
					if (x < mid)
					{
						slope = ((x - aX) / (mid - aX)); 
						
					}
					else
					{
						slope = ((bX - x) / (bX - mid));
					}
				}
				else
					slope = 0;
				slope = (hiPt - stY) * slope;
				
				nY = stY + slope;// Math.pow((slope * 70), 1.33);
				_points.push(nY);
				if (nY > loPt)
					loPt = nY;
				
					
				
			}
			
			var xE:int;
			var xS:int;
			
			var h:int;
			var l:int;
			
			//var av:int;
			
			// make another pass and 'shift' stuff around
			for (var i2:int = 0; i2 < 500; i2++)
			{
				if (SeedRnd.boolean(0.8))
				{
					xE = SeedRnd.integer(10, 60);
					xS = SeedRnd.integer(0, FlxG.width - xE);
					
					h = FlxG.height;
					l = 0;
					
					//av = SeedRnd.integer(1,3) * SeedRnd.sign(0.33);
				
				
				
					// this is sort of like erosion...
					for (var x2:int = xS; x2 < xS + xE; x2++)
					{
						if (points[x2] > l) l = points[x2];
						if (points[x2] < h) h = points[x2];
					}
					
					for (var x3:int = xS; x3 < xS+xE; x3++)
					{
						if (points[x3] < l - 16)
						{
							points[x3] += 3;
						}	
						else if (points[x3] < l - 8)
						{
							points[x3] += 2;
						}	
						else if (points[x3] < l - 4)
						{
							points[x3] += 1;
						}
						
						
					}
				}
				else
				{
					xE = SeedRnd.integer(3, 6);
					xS = SeedRnd.integer(0, FlxG.width);
					var yA:int = SeedRnd.integer(4, 8);
					// do some random chasms...
					h = FlxG.height;
					l = 0;
					for (var x5:int = xS; x5 < xS + xE; x5++)
					{
						if (points[x5] > l) l = points[x5];
						if (points[x5] < h) h = points[x5];
					}
					
					for (var x4:int = xS - (xE / 2); x4 < xS + (xE / 2); x4++)
					{
						points[x4] = l  - yA + SeedRnd.integer( -2, 2);
					}
				}
				
			}
			
			hiPt = FlxG.height;
			loPt = 0;
			for (var i3:int = 0; i3 < FlxG.width; i3++)
			{
				
				if (points[i3] < hiPt)	hiPt = points[i3];
				if (points[i3] > loPt) loPt = points[i3];
			}
			
			_highest = hiPt;
			_lowest = loPt;
			// loPt should be dirt... hiPt should be snow
			
			
			for (var sx:int = 0; sx < FlxG.width; sx++)
			{
				//var j:Number = uint((hiPt-20+SeedRnd.integer(-2,2)) / 30);
				//var j:Number =  ((points[sx] - hiPt)  * 0.03) + SeedRnd.float(-3,3);
				var j:Number;
				// hiPt ALWAYS = 0;
				
				//j = (points[sx]-hiPt);//  * 20; 
				//if (j < 0) j = 0;
				//FlxG.log(j);
				for (var i:int = points[sx]; i <= FlxG.height; i++)
				{
					j = ((i - hiPt) / 7) + ((i-points[sx]) * 0.33);
					colorsArr = new Array();
					
					if (i < points[sx] + 4 && j > 20)
					{
						colorsArr = colorsArr.concat(COLOR_GRASS);
					
					}
					else
					{
					
						if (j < 12)
							colorsArr = colorsArr.concat(COLOR_SNOW);
						if (j < 13)
							colorsArr = colorsArr.concat(COLOR_SNOW);
						if (j < 14)
							colorsArr = colorsArr.concat(COLOR_SNOW);
						if (j < 15)
							colorsArr = colorsArr.concat(COLOR_SNOW);
						if (j < 16)
							colorsArr = colorsArr.concat(COLOR_SNOW);
						if (j < 16)
							colorsArr = colorsArr.concat(COLOR_SNOW);
						if (j < 17)
							colorsArr = colorsArr.concat(COLOR_SNOW);
						if (j < 19)
							colorsArr = colorsArr.concat(COLOR_SNOW);
						if (j < 20)
							colorsArr = colorsArr.concat(COLOR_SNOW);
						
						//if (j > 14 && j < 18)
						//	colorsArr = colorsArr.concat(COLOR_STONE);
						
						if (j > 14 && j < 38)
							colorsArr = colorsArr.concat(COLOR_DIRT);
						if (j > 15 && j < 39)
							colorsArr = colorsArr.concat(COLOR_DIRT);
						if (j > 16 && j < 40)
							colorsArr = colorsArr.concat(COLOR_DIRT);
						if (j > 17 && j < 41)
							colorsArr = colorsArr.concat(COLOR_DIRT);
						if (j > 18 && j < 42)
							colorsArr = colorsArr.concat(COLOR_DIRT);
						if (j > 19 && j < 43)
							colorsArr = colorsArr.concat(COLOR_DIRT);
						if (j > 20 && j < 44)
							colorsArr = colorsArr.concat(COLOR_DIRT);
						if (j > 21 && j < 45)
							colorsArr = colorsArr.concat(COLOR_DIRT);
						if (j > 22 && j < 46)
							colorsArr = colorsArr.concat(COLOR_DIRT);
						if (j > 23 && j < 47)
							colorsArr = colorsArr.concat(COLOR_DIRT);
						if (j > 24 && j < 48)
							colorsArr = colorsArr.concat(COLOR_DIRT);
						if (j > 25 && j < 49)
							colorsArr = colorsArr.concat(COLOR_DIRT);
						
						
						
						if (j > 32 && j < 52)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 33 && j < 53)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 34 && j < 54)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 35 && j < 55)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 36 && j < 56)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 36 && j < 57)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 36 && j < 58)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 36 && j < 59)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 36 && j < 60)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 36 && j < 61)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 36 && j < 62)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 36 && j < 63)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 36 && j < 64)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 36 && j < 65)
							colorsArr = colorsArr.concat(COLOR_MID);
						if (j > 36 && j < 66)
							colorsArr = colorsArr.concat(COLOR_MID);
						
						
						if (j > 63)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 64)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 65)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 66)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 67)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 68)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 69)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 70)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 71)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 72)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 73)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 74)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 75)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 76)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 77)
							colorsArr = colorsArr.concat(COLOR_DARK);
						if (j > 78)
							colorsArr = colorsArr.concat(COLOR_DARK);
					}
					
					
					if (SeedRnd.boolean(0.66))
						j+=0.66;
					canvas.setPixel32(sx, i, colorsArr[SeedRnd.integer(0, colorsArr.length - 1)]);
				}
			}
			
			
			_groundMap = new FlxSprite(0, 0);
			_groundMap.makeGraphic(FlxG.width, FlxG.height, 0x00000000,true);
			_groundMap.pixels = canvas;
			_groundMap.dirty = true;
		}
		
	}

}