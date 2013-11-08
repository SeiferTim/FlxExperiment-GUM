package  
{
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import net.tileisle.Guy;
	import net.tileisle.Tree;
	import net.tileisle.World;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxGradient;
	import org.flixel.plugin.photonstorm.FlxCollision;
	/**
	 * ...
	 * @author Tim
	 */
	public class GameState extends FlxState
	{
		private var _world:World;
		
		private var created:int = 0;
		
		private var _tick:Number;
		
		
		
		private var _lyrHUD:FlxGroup;
		
		private var _hudHPop:FlxText;
		private var _hudHWood:FlxText;
		private var _hudHFood:FlxText;
		private var _hudDPop:FlxText;
		private var _hudDFood:FlxText;
		private var _hudDOre:FlxText;
		
		
		private var _lyrStatus:FlxGroup;
		private var msgs:Vector.<FlxText>;
		
		override public function create():void
		{
			_tick = 0;
			_world = new World(this);
			
			msgs = new Vector.<FlxText>;
			_lyrStatus = new FlxGroup();
			add(_lyrStatus);
			
			msgs.push(_lyrStatus.add(new FlxText(8, 8, FlxG.width - 10, "Initializing...")) as FlxText);
			created = 1;
			
			_lyrHUD = new FlxGroup();
		}
		
		
		
		
		override public function update():void
		{
			
			if (created == 1)
			{
				msgs.push(_lyrStatus.add(new FlxText(8, 16, FlxG.width - 10, "Starting Ground Generation...")) as FlxText);
				created = 2;
			}
			else if (created == 2)
			{
				_world.MakeGround();
				created = 3;
			}
			else if (created == 3)
			{
				msgs.push(_lyrStatus.add(new FlxText(8, 24, FlxG.width - 10, "Starting Tree Generation...")) as FlxText);
				created = 4;
			}
			else if (created == 4)
			{
				_world.populateTrees();
				created =5;
			}
			else if (created == 5)
			{
				msgs.push(_lyrStatus.add(new FlxText(8, 32, FlxG.width - 10, "Starting Human Generation...")) as FlxText);
				created = 6;
			}
			else if (created == 6)
			{
				_world.populateHumans();
				created = 7;
			}
			else if (created == 7)
			{
				msgs.push(_lyrStatus.add(new FlxText(8, 40, FlxG.width - 10, "Generating Caves...")) as FlxText);
				created = 8;
			}
			else if (created ==8)
			{
				_world.populateCaves();
				created = 9;
			}
			else if (created==9)
			{
				msgs.push(_lyrStatus.add(new FlxText(8, 48, FlxG.width - 10, "Populating Dwarfs...")) as FlxText);
				created = 10;
			}
			else if (created == 10)
			{
				_world.populateDwarfs();
				created = 11;
			}
			else if (created == 11)
			{
				
				_world.populateHouses();
				
				
				msgs.push(_lyrStatus.add(new FlxText(8, 56, FlxG.width - 10, "Finished!")) as FlxText);
				
				
				_lyrStatus.kill();
				
				_world.MakeSky();
				add(_world.dRooms);
				add(_world.sky);
				add(_world.ground.GroundMap);
				add(_world.lyrTrees);
				add(_world.caves);
				add(_world.lyrMagma);
				add(_world.lyrFX);
				add(_world.lyrHouses);
				add(_world.lyrDHouses);
				add(_world.lyrGuys);
				add(_world.lyrDwarfs);
				
				
				//
				//var t:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x00000000, true);
				//t.pixels = FlxCollision.debug;
				//add(t);
				
				add(_lyrHUD);
				
				_lyrHUD.add(new FlxSprite(10, 10).makeGraphic(140, 62, 0x99000000));
				_lyrHUD.add(new FlxText(14, 14, 132, "Humans").setFormat(null,8,0xffffff,"center"));
				_lyrHUD.add(new FlxText(14, 26, 70, "Population:"));
				_lyrHUD.add(new FlxText(14, 38, 70, "Food:"));
				_lyrHUD.add(new FlxText(14, 50, 70, "Wood:"));
				_hudHPop = _lyrHUD.add(new FlxText(84, 26, 60, "0").setFormat(null, 8, 0xffffff, "right")) as FlxText;
				_hudHFood = _lyrHUD.add(new FlxText(84, 38, 60, "0").setFormat(null, 8, 0xffffff, "right")) as FlxText;
				_hudHWood = _lyrHUD.add(new FlxText(84, 50, 60, "0").setFormat(null, 8, 0xffffff, "right")) as FlxText;
				
				_lyrHUD.add(new FlxSprite(10, 82).makeGraphic(140, 62, 0x99000000));
				_lyrHUD.add(new FlxText(14, 86, 132, "Dwarfs").setFormat(null,8,0xffffff,"center"));
				_lyrHUD.add(new FlxText(14, 98, 70, "Population:"));
				_lyrHUD.add(new FlxText(14, 110, 70, "Food:"));
				_lyrHUD.add(new FlxText(14, 122, 70, "Ore:"));
				_hudDPop = _lyrHUD.add(new FlxText(84, 98, 60, "0").setFormat(null, 8, 0xffffff, "right")) as FlxText;
				_hudDFood = _lyrHUD.add(new FlxText(84, 110, 60, "0").setFormat(null, 8, 0xffffff, "right")) as FlxText;
				_hudDOre = _lyrHUD.add(new FlxText(84, 122, 60, "0").setFormat(null, 8, 0xffffff, "right")) as FlxText;
				
				
				
				created = 100;
				
			}
			else
			{
				if (_tick <= 0)
				{
					_world.update();	
					_tick = 2;
				}
				else
					_tick -= FlxG.elapsed * 80;
				_hudHPop.text = String(_world.humanPop);
				_hudHFood.text = String(_world.humanFood);
				_hudHWood.text = String(_world.humanWood);
				_hudDPop.text = String(_world.dwarfPop);
				_hudDFood.text = String(_world.dwarfFood);
				_hudDOre.text = String(_world.dwarfOre);
			}
			
			super.update();
			
		}
		
		public function GameState() 
		{
			super();
		}
		
	}

}