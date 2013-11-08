package net.tileisle 
{
	import flash.display.BitmapData;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author ...
	 */
	public class Tree extends FlxSprite
	{
		
		private const COLOR_TRUNK:Array = new Array(0xff5C4425,0xff736149,0xff8A847D,0xff573A14);
		private const COLOR_LEAF:Array = new Array(0xff1D401A, 0xff0E380A, 0xff30A825, 0xff42753D);
		
		public const STATUS_NORMAL:int = 0;
		public const STATUS_CUTTING:int = 1;
		public const STATUS_CUTDOWN:int = 2;
		
		//private var _health:int;
		private var _status:int;
		
		private var _w:World;
		
		public function Tree(w:World) 
		{
			super(0, 0);
			_w = w;
			buildTree();
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			
			super.reset(X, Y);
			buildTree();
		}
		
		public function buildTree():void
		{
			var tHeight:int = SeedRnd.integer(6, 40);
			var tWidth:int = SeedRnd.integer(int(tHeight / 5), int(tHeight / 2)+1);
			var lHeight:int = SeedRnd.integer(4, tHeight - 4);
			var density:Number = SeedRnd.float(0.7,0.9);
			var canvas:BitmapData = new BitmapData((tWidth * 2) + 1, tHeight + 2, true, 0x00000000);
			var tColor:uint = COLOR_TRUNK[SeedRnd.integer(0, COLOR_TRUNK.length)];
			
			health = lHeight * 20;
			_status = STATUS_NORMAL;
			
			for (var ay:int = 2; ay < tHeight; ay++)
			{
				canvas.setPixel32(tWidth +1, ay, tColor);
			}
			
			var tMid:int = tWidth + 1;
			
			
			for (var i:int = 0; i < lHeight + 2; i++)
			{
				for (var ax:int = 0; ax < canvas.width; ax++)
				{
					//FlxG.log(Math.abs(tMid - x) + " < " + Math.abs(lHeight - i * 2));
					//if (Math.abs(tMid - x) < Math.abs((lHeight/2) - (i*2)))
					//{
						if (SeedRnd.boolean(density))
						{
							canvas.setPixel32(ax, i, COLOR_LEAF[SeedRnd.integer(0, COLOR_LEAF.length)]);
						}
					//}
				}
			}
			makeGraphic(canvas.width, canvas.height, 0x00000000);
			pixels = canvas;
			dirty = true;
		}
		
		//public function get health():int
		//{
		//	return _health;
		//}
		
		public function get status():int
		{
			return _status;
		}
		
		public function set status(Value:int):void
		{
			_status = Value;
		}
		
	}

}