package net.tileisle 
{
	import flash.display.InteractiveObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.plugin.photonstorm.FlxCollision;
	import org.flixel.FlxG;
	import flash.geom.Rectangle;
	import org.flixel.FlxU;
	/**
	 * ...
	 * @author Tim
	 */
	public class Dwarf 
	{
		private var _female:Boolean;
		
		public const COLOR_DWARF:uint = 0xFFFF00FF;
		
		public const ACT_IDLE:uint = 0;
		public const ACT_WALKLEFT:uint = 1;
		public const ACT_WALKRIGHT:uint = 2;
		public const ACT_WALKUP:uint = 3;
		public const ACT_WALKDOWN:uint = 4;
		public const ACT_TREE:uint = 5;
		public const ACT_BUILD:uint = 6;
		public const ACT_BIRTH:uint = 7;
		public const ACT_MINE:uint = 8;
		
		private const DIR_DOWN:uint = 0;
		private const DIR_UP:uint = 1;
		private const DIR_RIGHT:uint = 2;
		private const DIR_LEFT:uint = 3;
		
		private const DIG_DIR_RD:uint = 0;
		private const DIG_DIR_LD:uint = 1;
		private const DIG_DIR_RU:uint = 2;
		private const DIG_DIR_LU:uint = 3;
		
		private var _life:Number; 
		private var _pos:FlxPoint;
		private var _action:int;
		
		private var _w:World;
		
		private var _home:DwarfHome;
		private var _building:DwarfHome;
		private var _athome:Boolean;	
		private var _wait:Number;
		private var _sinceBirth:Number;
		private var _underground:Boolean;
		private var _digDir:int;
		private var _curDigX:int;
		private var _curDigY:int;
		
		private var _room:Rectangle;
		private var _startedRoom:Boolean;
		
		public function get female():Boolean
		{
			return _female;
		}
		
		public function get underground():Boolean
		{
			return _underground;
		}
		
		public function get life():Number
		{
			return _life;
		}
		
		public function get pos():FlxPoint
		{
			return _pos;
		}
		
		public function Dwarf(w:World) 
		{
			_w = w;
		}
		
		public function get atHome():Boolean
		{
			return _athome;
		}
		
		public function spawn(X:Number, Y:Number):Dwarf
		{
			_life = 4;
			_female = SeedRnd.boolean();
			
			_pos = new FlxPoint(X, Y);
			_action = ACT_IDLE;
			_sinceBirth = SeedRnd.integer(120,400);
			_underground = true;
			_curDigX = -1;
			_curDigY = -1;
			_athome = false;
			_digDir = -1;
			_wait = 0;
			
			_room = null;
			_startedRoom = false;
			
			return this;
			
		}
		
		public function update():void
		{
			
			//FlxG.log("Action: " + _action );
			_pos.x = int(_pos.x);
			_pos.y = int(_pos.y);
			
			if (_action < ACT_TREE || _action == ACT_MINE)
			{
				_life-= SeedRnd.float(0.001, 0.003);
			}
			
			if (SeedRnd.boolean(0.025))
			{
				if (_w.dwarfFood > 0)
					_w.dwarfFood -= SeedRnd.integer(0,2);
				else
					_life-=SeedRnd.float(0.015, 0.045);
			}
			
			if (_life <= 0)
			{
				//if (_home != null)
				//	_home.owned = false;
				return;
			}
			
			if (_sinceBirth > 0)
				_sinceBirth--;
				
			if (_home == null)
			{
				for each (var ch:DwarfHome in _w.dHouses)
				{
					if (!ch.owned)
					{
						_home = ch;
						ch.owned = true;
					}
				}
			}
			
			
			if (_action > ACT_WALKDOWN)
			{
				switch(_action)
				{
					case ACT_BIRTH:
						BirthChild();
						break;
					case ACT_BUILD:
						BuildHouse();
						break;
					case ACT_MINE:
						MineTunnel();
						break;
				}
			}
			else
			{
				if (_underground && _pos.y < _w.ground.points[_pos.x])
				{
					_underground = false;
					_pos.y = _w.ground.points[_pos.x] - 1;
					_action  = -1;
				}
				else if (!_underground && _pos.y >= _w.ground.points[_pos.x])
				{
					_underground = true;
					_action = -1;
				}
				
				if (_action == ACT_WALKLEFT)
				{
					if (_pos.x < 10 || (_underground && _w.isSolid(_pos.x - 1, _pos.y)))
						_action = -1;
				}
				
				if (_action == ACT_WALKRIGHT)
				{
					if (_pos.x > FlxG.width - 10 || (_underground && _w.isSolid(_pos.x + 1, _pos.y)))
						_action = -1;
				}
				
				if (_action == ACT_WALKUP)
				{
					if (!_underground || pos.y -2 < _w.ground.points[_pos.x] || _w.isSolid(_pos.x, _pos.y - 1))
						_action = -1;
				}
				
				if (_action == ACT_WALKDOWN)
				{
					if (!_underground || _pos.y > FlxG.height - 10 || _w.isSolid(_pos.x, _pos.y + 1))
						_action = -1;
				}
				
				if (_action == -1 || SeedRnd.boolean(0.05))
				{
					var acts:Array = new Array();
					acts.push(ACT_IDLE);
					
					acts.push(ACT_MINE);
					
					if (_pos.x > 10)
					{
						if (!_underground || !_w.isSolid(_pos.x - 1, _pos.y))
								acts.push(ACT_WALKLEFT);
					}
					
					if (_pos.x < FlxG.width - 10)
					{
						if (!_underground || !_w.isSolid(_pos.x + 1, _pos.y))
							acts.push(ACT_WALKRIGHT);
					}
					if (_underground)
					{
						if (_pos.y -2 < _w.ground.points[_pos.x] || !_w.isSolid(_pos.x, _pos.y - 1))
							acts.push(ACT_WALKUP);
						if (_pos.y < FlxG.height - 10 && !_w.isSolid(_pos.x, _pos.y + 1))
							acts.push(ACT_WALKDOWN);
							
						if (_home == null && _w.dwarfOre > 150)
						{
							var tmpS:FlxSprite = new FlxSprite(_pos.x - 3, _pos.y - 3).makeGraphic(7, 7, 0xFF000000,true);
							if (!FlxG.overlap(_w.lyrDHouses, tmpS) && !FlxCollision.pixelPerfectCheck(tmpS, _w.lyrMagma, 200))
								acts.push(ACT_BUILD);
							tmpS.kill();
						}
						
						if (_female && _home != null && _sinceBirth <=0 && _w.dwarfFood >= 15)
						{
							acts.push(ACT_BIRTH);
						}
					}
					
					
					_action = acts[SeedRnd.integer(0, acts.length)];
					
					
					switch(_action)
					{
						case ACT_BUILD:
							var h:DwarfHome = new DwarfHome(_w, _pos.x, _pos.y);
							_w.dHouses.push(h);
							_w.lyrDHouses.add(h);
							_building = h;
							_home = h;
							h.owned = true;
							_w.dwarfOre-= 150;
							break;
						case ACT_MINE:
							if (!_underground)
							{
								_pos.y = _w.ground.points[_pos.x];
								_w.MakeCave(_pos.x, _pos.y,_w.CORIENT_D);
								_w.giveDOre();
								_underground = true;
							}
							break;
					}
					
				}
				
			}
			
			
			switch (_action)
			{
				case ACT_IDLE:
					break;
				case ACT_WALKLEFT:
					Walk(DIR_LEFT);
					break;
				case ACT_WALKRIGHT:
					Walk(DIR_RIGHT);
					break;
				case ACT_WALKUP:
					Walk(DIR_UP);
					break;
				case ACT_WALKDOWN:
					Walk(DIR_DOWN);
					break;
			}
		}
		
		
		private function BirthChild():void
		{
			if (!_athome)
			{
				if (_home.x + 2 == _pos.x && _home.y + 4 == _pos.y)
				{
					_athome = true;
					_wait = SeedRnd.integer(80, 120);
					_home.birthing = true;
					
				}
				else 
				{
					
					if (Math.abs(_pos.y - (_home.y + 4)) > Math.abs(_pos.x - (_home.x + 2)))
					{
						if (_pos.y > (_home.y + 4))
						{
							if (_w.isSolid(_pos.x, _pos.y - 1))
							{
								_w.MakeCave(_pos.x, _pos.y - 1, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_UP);
						}
						else
						{
							if (_w.isSolid(_pos.x, _pos.y + 1))
							{
								_w.MakeCave(_pos.x, _pos.y + 1, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_DOWN);
						}
					}
					else
					{
						if (_pos.x > (_home.x + 2))
						{
							if (_w.isSolid(_pos.x - 1, _pos.y))
							{
								_w.MakeCave(_pos.x - 1, _pos.y , _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_LEFT);
						}
						else
						{
							if (_w.isSolid(_pos.x + 1, _pos.y))
							{
								_w.MakeCave(_pos.x + 1, _pos.y, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_RIGHT);
						}
					}
				}
			}
			else
			{
				if (_wait > 0)
					_wait--;
				else
				{
					_sinceBirth = SeedRnd.integer(120,400);
					_athome = false;
					_w.dwarfFood -= 15;
					_home.birthing = false;
					_w.SpawnDwarf(_pos.x,_pos.y);
					_action = -1;
				}
			}
		}
		
		
		private function Walk(D:uint):void
		{
			/*
			switch(D)
			{
				case DIR_LEFT:
					if (FlxCollision.pixelPerfectPointCheck(_pos.x - 1, _pos.y, _w.lyrMagma, 255))
						return;
					break;
				case DIR_RIGHT:
					if (FlxCollision.pixelPerfectPointCheck(_pos.x + 1, _pos.y, _w.lyrMagma, 255))
						return;
					break;
				case DIR_UP:
					if (FlxCollision.pixelPerfectPointCheck(_pos.x , _pos.y - 1, _w.lyrMagma, 255))
						return;
					break;
				case DIR_DOWN:
					if (FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y + 1, _w.lyrMagma, 255))
						return;
					break;
			}
			*/
			
			var xD:int;
			var yD:int;
			if (D == DIR_LEFT || D == DIR_RIGHT)
			{
				if (D == DIR_LEFT)
					xD = -1;
				else
					xD = 1;
					
				if (!_underground && _w.ground.points[_pos.x] <  _w.ground.points[_pos.x + xD] - 1)
				{
					_w.ground.cutGround(_pos.x, 1);
					_pos.y++;
					_w.ground.fillGround(_pos.x + xD, 1);
				}
				else if (!_underground && _w.ground.points[_pos.x  + xD] < _w.ground.points[_pos.x] - 1)
				{
					_w.ground.cutGround(_pos.x + xD, 1);
					_pos.y++;
					_w.ground.fillGround(_pos.x  , 1);
				}
				else
				{
					_pos.x+=xD;
				}
					
				
			}
			else
			{
				if (D == DIR_UP)
					_pos.y--;
				else if (D == DIR_DOWN)
					_pos.y++;
			}
		}
		
		private function BuildHouse():void
		{
			if (_building == null)
			{
				_action = -1;
				return;
			}
			if (_building.health <= 25)
			{
				_building.build(SeedRnd.integer(0, 3));
			}
			else
			{
				_building = null;
				_action = -1;
			}
			
		}
		
		
		
		
		private function MineTunnel():void
		{
			if (_room == null)
			{
				_startedRoom = false;
				var bX1:int = _pos.x - 20;
				var bX2:int = _pos.x + 20;
				var bY1:int = _pos.y - 20;
				var bY2:int = _pos.y + 20;
				
				if (bX1 < 10) bX1 = 10;
				else if (bX1 > FlxG.width - 20) bX1 = FlxG.width - 25;
				if (bX2 > FlxG.width - 10) bX2 = FlxG.width - 10;
				else if (bX2 < 20) bX2 = 20;
				
				
				for (var d:int = bX1; d < bX2; d++)
				{
					if (_w.ground.points[d] + 10 > bY1)
						bY1 = _w.ground.points[d];
				}
				if (bY2 <= bY1 + 10)
					bY2 = bY1 + 10;
				
				if (bY2 > FlxG.height - 30) bY2 = FlxG.height - 30;
				
				if (bX2 > bX1)
				{
					var bX3:int = bX1;
					bX1 = bX2;
					bX2 = bX3;
				}
								
				if (bY2 > bY1)
				{
					var bY3:int = bY1;
					bY1 = bY2;
					bY2 = bY3;
				}
				
				if (bX1 != bX2 && bY1 != bY2)
				{
					_room = new Rectangle(SeedRnd.integer(bX1, bX2), SeedRnd.integer(bY1, bY2), SeedRnd.integer(3, 8) * 5, SeedRnd.integer(1, 4) * 5);
					_room.x = int(_room.x);
					_room.y = int(_room.y);
					_room.width = int(_room.width);
					_room.height = int(_room.height);
					
					_room.y += 10 - (_room.y % 10);
					
					//debug
					//_w.caves.pixels.fillRect(_room, 0xffff0000);
					var t:FlxSprite = new FlxSprite(_room.x, _room.y).makeGraphic(_room.width, _room.height, 0xff000000,true);
					if (FlxCollision.pixelPerfectCheck(t, _w.dRooms))
					{
						_room = null;
						_action = -1;
					}
					else
					{
						_w.dRooms.pixels.fillRect(_room, 0xffff0000);
						_w.dRooms.dirty = true;
					}
					t.kill();
				}
				
			}
			else if (!_startedRoom)
			{
				var Dist11:Number = Math.abs(FlxU.getDistance(_pos, new FlxPoint(_room.x, _room.y)));
				var Dist21:Number = Math.abs(FlxU.getDistance(_pos, new FlxPoint(_room.x + _room.width, _room.y)));
				var Dist12:Number = Math.abs(FlxU.getDistance(_pos, new FlxPoint(_room.x, _room.y + _room.height)));
				var Dist22:Number = Math.abs(FlxU.getDistance(_pos, new FlxPoint(_room.x + _room.width, _room.y + _room.height)));
				
				if (Dist11 == 0 || (_pos.x == _room.x && _pos.y == _room.y))
				{
					_digDir = DIG_DIR_RD;
					_curDigX = 0;
					_curDigY = 0;
					_startedRoom = true;
				}
				else if (Dist12 == 0 || (_pos.x == _room.x && _pos.y == _room.y + _room.height))
				{
					_digDir = DIG_DIR_RU;
					_curDigX = 0;
					_curDigY = _room.height;
					_startedRoom = true;
				}
				else if (Dist21 == 0 || (_pos.x == _room.x + _room.width && _pos.y == _room.y))
				{
					_digDir = DIG_DIR_LD;
					_curDigX = _room.width;
					_curDigY = 0;
					_startedRoom = true;
				}
				else if (Dist22 == 0 || (_pos.x == _room.x + _room.width && _pos.y == _room.y + _room.height))
				{
					_digDir = DIG_DIR_LU;
					_curDigX = _room.width;
					_curDigY = _room.height;
					_startedRoom = true;
				}
				else
				{
					var closest:Number = Dist11;
					var dX:int = _room.x;
					var dY:int = _room.y;
					if (Dist12 < closest) 
					{
						closest = Dist12;
						dX = _room.x;
						dY = _room.y + _room.height;
					}
					if (Dist21 < closest) 
					{
						closest = Dist21;
						dX = _room.x + _room.width;
						dY = _room.y;
					}
					if (Dist22 < closest)
					{
						closest = Dist22;
						dX = _room.x + _room.width;
						dY = _room.y + _room.height;
					}
					if (Math.abs(_pos.y - dY) > Math.abs(_pos.x - dX))
					{
						if (_pos.y > dY)
						{
							if (_w.isSolid(_pos.x, _pos.y - 1))
							{
								_w.MakeCave(_pos.x, _pos.y - 1, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_UP);
						}
						else
						{
							if (_w.isSolid(_pos.x, _pos.y + 1))
							{
								_w.MakeCave(_pos.x, _pos.y + 1, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_DOWN);
						}
					}
					else
					{
						if (_pos.x > dX)
						{
							if (_w.isSolid(_pos.x - 1, _pos.y))
							{
								_w.MakeCave(_pos.x - 1, _pos.y , _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_LEFT);
						}
						else
						{
							if (_w.isSolid(_pos.x + 1, _pos.y))
							{
								_w.MakeCave(_pos.x + 1, _pos.y, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_RIGHT);
						}
					}
					
					
				}
				
			}
			else
			{
				if (_digDir == DIG_DIR_LD || _digDir == DIG_DIR_RD)
				{
					if (_digDir == DIG_DIR_RD)
					{
						if (_curDigX < _room.width)
						{
							if (_w.isSolid(_pos.x + 1, _pos.y))
							{
								_w.MakeCave(_pos.x + 1, pos.y, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_RIGHT);
							_curDigX++;
						}
						else if (_curDigY < _room.height)
						{
							if (_w.isSolid(_pos.x, _pos.y + 1))
							{
								_w.MakeCave(_pos.x, pos.y + 1, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_DOWN);
							_curDigY++;
							_digDir = DIG_DIR_LD;
						}
						else
						{
							_startedRoom = false;
							_curDigY = -1;
							_curDigX = -1;
							_room = null;
							_action = -1;
							return;
						}
					}
					else if (_digDir == DIG_DIR_LD)
					{
						if (_curDigX > 0)
						{
							if (_w.isSolid(_pos.x - 1, _pos.y))
							{
								_w.MakeCave(_pos.x - 1, pos.y, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_LEFT);
							_curDigX--;
						}
						else if (_curDigY < _room.height)
						{
							if (_w.isSolid(_pos.x, _pos.y + 1))
							{
								_w.MakeCave(_pos.x, pos.y + 1, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_DOWN);
							_curDigY++;
							_digDir = DIG_DIR_RD;
						}
						else
						{
							_startedRoom = false;
							_curDigY = -1;
							_curDigX = -1;
							_room = null;
							_action = -1;
							return;
						}
					}
				}
				else if (_digDir == DIG_DIR_LU || _digDir == DIG_DIR_RU)
				{
					if (_digDir == DIG_DIR_RU)
					{
						if (_curDigX < _room.width)
						{
							if (_w.isSolid(_pos.x + 1, _pos.y))
							{
								_w.MakeCave(_pos.x + 1, pos.y, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_RIGHT);
							_curDigX++;
						}
						else if (_curDigY > 0)
						{
							if (_w.isSolid(_pos.x, _pos.y - 1))
							{
								_w.MakeCave(_pos.x, pos.y - 1, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_UP);
							_curDigY--;
							_digDir = DIG_DIR_LU;
						}
						else
						{
							_startedRoom = false;
							_curDigY = -1;
							_curDigX = -1;
							_room = null;
							_action = -1;
							return;
						}
					}
					else if (_digDir == DIG_DIR_LU)
					{
						if (_curDigX > 0)
						{
							if (_w.isSolid(_pos.x - 1, _pos.y))
							{
								_w.MakeCave(_pos.x - 1, pos.y, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_LEFT);
							_curDigX--;
						}
						else if (_curDigY > 0)
						{
							if (_w.isSolid(_pos.x, _pos.y - 1))
							{
								_w.MakeCave(_pos.x, pos.y - 1, _w.CORIENT_P);
								_w.giveDOre();
							}
							Walk(DIR_UP);
							_curDigY--;
							_digDir = DIG_DIR_RU;
						}
						else
						{
							_startedRoom = false;
							_curDigY = -1;
							_curDigX = -1;
							_room = null;
							_action = -1;
							return;
						}
					}
				}
			}
		}
		
	}
	
	

}