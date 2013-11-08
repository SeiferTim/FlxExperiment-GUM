package net.tileisle 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.DRMCustomProperties;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxCollision;
	import org.flixel.plugin.photonstorm.FlxColor;
	import org.flixel.plugin.photonstorm.FlxGradient;
	import flash.geom.Rectangle;
	public class World 
	{
		
		// the WORLD will contain just about everything - the mountain, the weather, the sky, the entities, etc.
		
		
		public const CORIENT_D:uint = 0;
		public const CORIENT_U:uint = 1;
		public const CORIENT_R:uint = 2;
		public const CORIENT_L:uint = 3;
		public const CORIENT_P:uint = 4;
		
		private var _ground:Ground;
		private var _m:Magma;
		
		private var _guys:Vector.<Guy>;
		private var _dwarfs:Vector.<Dwarf>;
		private var _trees:Vector.<Tree>;
		private var _houses:Vector.<House>;
		private var _dHouses:Vector.<DwarfHome>;
		
		
		private var _sky:FlxSprite;
		private var _lyrTrees:FlxGroup;
		private var _lyrHouses:FlxGroup;
		private var _lyrDHouses:FlxGroup;
		private var _caves:FlxSprite;
		private var _lyrFX:FlxGroup;
		private var _lyrGuys:FlxSprite;
		private var _lyrDwarfs:FlxSprite;
		private var _lyrMagma:FlxSprite;
		private var _dRooms:FlxSprite;
		
		
		private var COLOR_CMID:Array;// = new Array(0x990F0E0C, 0x99241E0E, 0x994F3710, 0x99362914);
		private var COLOR_DIRT:Array;// = new Array(0xFFA89467, 0xFF8A723E, 0xFF8C7F46, 0xFF8C7543);
		
		
		private var _humanWood:int;
		private var _humanFood:int;
		private var _humanPop:int;
		
		private var _dwarfOre:int;
		private var _dwarfFood:int;
		private var _dwarfPop:int;
		
		private var _gs:GameState;
		
		
		
		public function World(GS:GameState) 
		{
			_gs = GS;
			COLOR_CMID = FlxGradient.createGradientArray(20, 20, [0x990F0E0C, 0x99241E0E], 1, 90);
			COLOR_DIRT = FlxGradient.createGradientArray(20, 20, [0xFF4F3710, 0xFF362914], 1, 90);
			
			_humanWood = 0;
			_humanFood = 2000;
			_lyrFX = new FlxGroup();
			_lyrHouses = new FlxGroup();
			_lyrDHouses = new FlxGroup();
			_lyrTrees = new FlxGroup();
			_lyrGuys = new FlxSprite();
			_lyrDwarfs = new FlxSprite();
			_sky = new FlxSprite();
			_dRooms = new FlxSprite();
			_m = new Magma(this);
			_lyrMagma = _m.mSpr;
			_dwarfFood = 1000;
			_dwarfOre  = 0;
			
		}
		
		
		public function get dRooms():FlxSprite
		{
			return _dRooms;
		}
		
		public function get lyrDHouses():FlxGroup
		{
			return _lyrDHouses;
		}
		
		public function get lyrMagma():FlxSprite
		{
			return _lyrMagma;
		}
		
		public function get lyrDwarfs():FlxSprite 
		{
			return _lyrDwarfs;
		}
		
		public function get lyrGuys():FlxSprite
		{
			return _lyrGuys;
		}
		
		public function MakeSky():void
		{
			_sky = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xff415587, 0xff7784b1]);
			
		}
		
		public function get sky():FlxSprite
		{
			return _sky;
		}
		
		public function updateDwarfs():void
		{
			_dwarfPop = 0;
			_lyrDwarfs.pixels = new BitmapData(FlxG.width, FlxG.height, true, 0x00000000);
			for each (var _d:Dwarf in _dwarfs)
			{
				if (_d.life > 0)
				{
					_dwarfPop++;
					_d.update();
					_lyrDwarfs.pixels.setPixel32(_d.pos.x, _d.pos.y, _d.COLOR_DWARF);
				}
			}
			_lyrDwarfs.dirty = true;
		}
		
		public function updateGuys():void
		{
			_humanPop = 0;
			_lyrGuys.pixels = new BitmapData(FlxG.width, FlxG.height, true, 0x00000000);
			for each (var _g:Guy in guys)
			{
				if (_g.life > 0 )
				{
					_humanPop++;
					_g.update();
					if (!_g.atHome)
					{
						if (!_g.underground)
						{
							_lyrGuys.pixels.setPixel32(_g.pos.x, ground.points[_g.pos.x] - 1, _g.COLOR_HUMAN);
						}
						else
						{
							_lyrGuys.pixels.setPixel32(_g.pos.x, _g.pos.y, _g.COLOR_HUMAN);
						}
					}
				}
			}
			_lyrGuys.dirty = true;
		}
		
		public function update():void
		{
			
			updateDwarfs();
			updateGuys();
			_m.update();
		}
		
		public function MakeGround():void
		{
			
			_ground = new Ground(_gs);
			
			_ground.GenerateGround();
			
			
		}
		
		public function isSolid(X:int, Y:int):Boolean
		{
			return FlxColor.getAlpha(_caves.pixels.getPixel32(X, Y)) < 50 || FlxColor.getAlpha(_caves.pixels.getPixel32(X, Y)) > 200;
		}
		
		
		public function populateCaves():void
		{
			_caves = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x00000000,true);
			_caves.pixels = new BitmapData(FlxG.width, FlxG.height, true, 0x00000000);
			//_caves.dirty;
			
			/// make some random caves...
			
			for (var cCnt:int = 0; cCnt < SeedRnd.integer(10, 100); cCnt++)
			{
				var cX:int = SeedRnd.integer(0, FlxG.width);
				var cY:int = SeedRnd.integer(_ground.points[cX] + 10, FlxG.height - 10);
				
				var rX:int = cX;
				var rY:int = cY;
				
				var hasM:Boolean = SeedRnd.boolean((rY/2)/FlxG.height);
				
				
				// starting point for our random cave...
				for (var cT:int = 0; cT < SeedRnd.integer(200, 800); cT++)
				{
					MakeCave(rX, rY, CORIENT_P);
					if(hasM)
					{
						//if (SeedRnd.boolean(0.9999999999999)) 
						//{
							_m.spawnMagma(rX, rY);
						//}
					}
					var checks:int = 0;
					while (!isSolid(rX,rY) && checks < 1200)
					{
						checks++;
						if (SeedRnd.boolean(0.1))
						{
							rX = cX;
							rY = cY;
						}
						if (SeedRnd.boolean())
							rX += SeedRnd.sign();
						else
							rY += SeedRnd.sign();
						
					} 
				}
				
			}
			_m.update();
			
			
		}
		
		public function populateDwarfs():void
		{
			_dRooms = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x00000000,true);
			_dwarfs = new Vector.<Dwarf>;
			_lyrDwarfs = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x00000000,true);
			var dX:int = SeedRnd.integer(5, FlxG.width-30);
			
			var dY:int = SeedRnd.integer(_ground.points[dX] + 20, FlxG.height - 10);
			
			for (var d:int = dX; d < dX; d++)
			{
				if (ground.points[d] + 20 > dY)
					dY = ground.points[d];
			}
			
			dY += 10 - (dY % 10);
			
			//dY = ;
			var dH:int = SeedRnd.integer(2, 4 * 5);
			var dW:int = SeedRnd.integer(1, 4) * 5;
			for (var X:int = dX; X < dX + dW; X++)
			{
				for (var Y:int = dY; Y < dY + dH; Y++)
				{
					MakeCave(X, Y, CORIENT_P);
					if (SeedRnd.boolean(0.05))
						dwarfOre += SeedRnd.integer(1, 4);
					
				}
			}
			
			_dRooms.pixels.fillRect(new Rectangle(dX, dY, dW, dH), 0xffff000000);
			_dRooms.dirty = true;
			//_dRooms.visible = false;
			
			for (var dC:int = 0; dC < 4; dC++)
			{
				//_dwarfs.push(new Dwarf(this).spawn(dX + (dW / 2), dY +dH - 1));
				SpawnDwarf(dX + (dW / 2), dY +dH - 1)
				
			}
			
			
		}
		
		public function giveDOre():void
		{
			if (SeedRnd.boolean(0.2))
			{
				_dwarfOre += SeedRnd.integer(1, 4);
			}
		}
		
		public function populateHouses():void
		{
			
			_houses = new Vector.<House>;
			_dHouses = new Vector.<DwarfHome>;
		}
		
		public function populateHumans():void
		{
			_lyrGuys = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x00000000);
			_guys = new Vector.<Guy>;
			var pos:int = SeedRnd.integer(20, FlxG.width - 20);
			for (var i:int = 0; i < SeedRnd.integer(4,8); i++)
				SpawnGuy(pos);
		}
		
		public function SpawnDwarf(X:Number,Y:Number):void
		{
			_dwarfs.push(new Dwarf(this).spawn(X, Y));
		}
		
		public function SpawnGuy(X:Number):void
		{
			_guys.push(new Guy(this).spawn(X, _ground.points[FlxG.width / 2] - 1));
		}
		
		public function populateTrees():void
		{
			_trees = new Vector.<Tree>;
			
			var treeNo:int = SeedRnd.integer(0.2 * FlxG.width, 0.5 * FlxG.width);
			var t:Tree;
			var tX:int;
			for (var j:int = 0; j < treeNo; j++)
			{
				
				tX = SeedRnd.integer(0, FlxG.width);
				if (SeedRnd.boolean(((_ground.points[tX]-_ground.highest-10)/(_ground.lowest-_ground.highest+10))))
				{				
					t = new Tree(this);
					t.x = tX - (t.width / 2);
					t.y = _ground.points[tX] - (t.height) +2;
					_trees.push(t);
					_lyrTrees.add(t);
				}
				
			}
		}
		
		public function MakeCave(X:Number, Y:Number, Orient:uint = 0):void
		{
			
			// what is a cave? it needs to be small sprites that have things drawn on them that the people can walk on
			// not sure yet...
			var tmp:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x00000000);
			tmp = _caves.pixels;
			switch(Orient)
			{
				case CORIENT_D:
					X -= 2;
					Y += 1;
					
					if (isSolid(X, Y) && _ground.points[X + 0] < Y + 0)
						tmp.setPixel32(X + 0, Y + 0, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (_ground.points[X+1]< Y+0)
						tmp.setPixel32(X + 1, Y + 0, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (_ground.points[X+2]< Y+0)
						tmp.setPixel32(X + 2, Y + 0, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (_ground.points[X + 3] > Y + 0)
						tmp.setPixel32(X + 3, Y + 0, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (isSolid(X + 4, Y) && _ground.points[X + 4] < Y + 0)
						tmp.setPixel32(X + 4, Y + 0, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X, Y + 1) && _ground.points[X + 0] < Y + 1)
						tmp.setPixel32(X + 0, Y + 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 1, Y + 1) && _ground.points[X + 1] < Y + 1)
						tmp.setPixel32(X + 1, Y + 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 2, Y + 1) && _ground.points[X + 2] < Y + 1)
						tmp.setPixel32(X + 2, Y + 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 3, Y + 1) && _ground.points[X + 3] < Y + 1)
						tmp.setPixel32(X + 3, Y + 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 4, Y + 1) && _ground.points[X + 4] < Y + 1)
						tmp.setPixel32(X + 4, Y + 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					break;
				case CORIENT_U:
					X -= 2;
					Y -= 1;
					if (isSolid(X + 0, Y + 0) && _ground.points[X+0]< Y+0)
						tmp.setPixel32(X + 0, Y + 0, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (_ground.points[X+1]< Y+0)
						tmp.setPixel32(X + 1, Y + 0, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (_ground.points[X+2]< Y+0)
						tmp.setPixel32(X + 2, Y + 0, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (_ground.points[X+3]< Y+0)
						tmp.setPixel32(X + 3, Y + 0, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (isSolid(X + 4, Y + 0) && _ground.points[X+4]< Y+0)
						tmp.setPixel32(X + 4, Y + 0, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 0, Y - 1) && _ground.points[X+0]< Y-1)
						tmp.setPixel32(X + 0, Y - 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 1, Y - 1) && _ground.points[X+2]< Y-1)
						tmp.setPixel32(X + 1, Y - 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 2, Y - 1) && _ground.points[X+3]< Y-1)
						tmp.setPixel32(X + 2, Y - 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 3, Y - 1) && _ground.points[X+4]< Y-1)
						tmp.setPixel32(X + 3, Y - 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 4, Y - 1) && _ground.points[X+5]< Y-1)
						tmp.setPixel32(X + 4, Y - 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					break;
				case CORIENT_R:
					Y -= 2;
					X += 1;
					if (isSolid(X + 0, Y + 0) && _ground.points[X+0]< Y+0)
						tmp.setPixel32(X + 0, Y + 0, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (_ground.points[X+0]< Y+1)
						tmp.setPixel32(X + 0, Y + 1, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (_ground.points[X+0]< Y+2)
						tmp.setPixel32(X + 0, Y + 2, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (_ground.points[X+0]< Y+3)
						tmp.setPixel32(X + 0, Y + 3, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (isSolid(X + 0, Y + 4) && _ground.points[X+0]< Y+4)
						tmp.setPixel32(X + 0, Y + 4, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 1, Y + 0) && _ground.points[X+1]< Y+0)
						tmp.setPixel32(X + 1, Y + 0, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 1, Y + 1) && _ground.points[X+1]< Y+1)
						tmp.setPixel32(X + 1, Y + 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 1, Y + 2) && _ground.points[X+1]< Y+2)
						tmp.setPixel32(X + 1, Y + 2, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 1, Y + 3) && _ground.points[X+1]< Y+3)
						tmp.setPixel32(X + 1, Y + 3, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 1, Y + 4) && _ground.points[X+1]< Y+4)
						tmp.setPixel32(X + 1, Y + 4, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					break;
				case CORIENT_L:
					Y -= 2;
					X -= 1;
					if (isSolid(X + 0, Y + 0) && _ground.points[X+0]< Y+0)
						tmp.setPixel32(X + 0, Y + 0, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (_ground.points[X+0]< Y+1)
						tmp.setPixel32(X + 0, Y + 1, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (_ground.points[X+0]< Y+2)
						tmp.setPixel32(X + 0, Y + 2, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (_ground.points[X+0]< Y+3)
						tmp.setPixel32(X + 0, Y + 3, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (isSolid(X + 0, Y + 4) && _ground.points[X+0]< Y+4)
						tmp.setPixel32(X + 0, Y + 4, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X - 1, Y + 0) && _ground.points[X+0]< Y+0)
						tmp.setPixel32(X - 1, Y + 0, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X - 1, Y + 1)&& _ground.points[X-1]< Y+1)
						tmp.setPixel32(X - 1, Y + 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X - 1, Y + 2)&& _ground.points[X-1]< Y+2)
						tmp.setPixel32(X - 1, Y + 2, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X - 1, Y + 3)&& _ground.points[X-1]< Y+3)
						tmp.setPixel32(X - 1, Y + 3, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X - 1, Y + 4)&& _ground.points[X-1]< Y+4)
						tmp.setPixel32(X - 1, Y + 4, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					break;
				case CORIENT_P:
					// A cave in a specific point, for random caves mostly
					if (_ground.points[X + 0] < Y + 0)
						tmp.setPixel32(X + 0, Y + 0, COLOR_CMID[SeedRnd.integer(0, COLOR_CMID.length)]);
					if (isSolid(X - 1, Y - 1) && _ground.points[X - 1] < Y - 1)
						tmp.setPixel32(X - 1, Y - 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 0, Y - 1) && _ground.points[X +0] < Y - 1)
						tmp.setPixel32(X + 0, Y - 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 1, Y - 1) && _ground.points[X + 1] < Y - 1)
						tmp.setPixel32(X + 1, Y - 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X - 1, Y + 0) && _ground.points[X - 1] < Y + 0)
						tmp.setPixel32(X - 1, Y + 0, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 1, Y + 0) && _ground.points[X + 1] < Y + 0)
						tmp.setPixel32(X + 1, Y + 0, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X - 1, Y + 1) && _ground.points[X - 1] < Y + 1)
						tmp.setPixel32(X - 1, Y + 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 0, Y + 1) && _ground.points[X + 0] < Y + 1)
						tmp.setPixel32(X + 0, Y + 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					if (isSolid(X + 1, Y + 1) && _ground.points[X + 1] < Y + 1)
						tmp.setPixel32(X + 1, Y + 1, COLOR_DIRT[SeedRnd.integer(0, COLOR_DIRT.length)]);
					break;
			}
			_caves.pixels = tmp;
			_caves.dirty = true;
		}
		
		public function get caves():FlxSprite
		{
			return _caves;
		}
		
		public function get lyrFX():FlxGroup
		{
			return _lyrFX;
		}
		
		public function get lyrHouses():FlxGroup
		{
			return _lyrHouses;
		}
		
		public function get dHouses():Vector.<DwarfHome>
		{
			return _dHouses;
		}
		
		public function get houses():Vector.<House>
		{
			return _houses;
		}
		
		public function get lyrTrees():FlxGroup
		{
			return _lyrTrees;
		}
		
		public function get trees():Vector.<Tree>
		{
			return _trees;
		}
		
		public function get ground():Ground
		{
			return _ground;
		}
		
		public function get guys():Vector.<Guy>
		{
			return _guys;
		}
		
		public function get humanWood():int
		{
			return _humanWood;
		}
		
		public function set humanWood(Value:int):void
		{
			//if (Value > _humanWood) Value = _humanWood;
			_humanWood = Value;
		}
		
		public function get humanFood():int
		{
			return _humanFood;
		}
		
		public function set humanFood(Value:int):void
		{
			//if (Value > _humanFood) Value = _humanFood;
			_humanFood = Value;
		}
		
		public function get humanPop():int
		{
			return _humanPop;
		}
		
		public function get dwarfOre():int
		{
			return _dwarfOre;
		}
		
		public function set dwarfOre(Value:int):void
		{
			_dwarfOre = Value;
		}
		
		public function get dwarfPop():int
		{
			return _dwarfPop;
		}
		
		public function get dwarfFood():int
		{
			return _dwarfFood;
		}
		
		public function set dwarfFood(Value:int):void
		{
			_dwarfFood = Value;
		}
		
	}

}