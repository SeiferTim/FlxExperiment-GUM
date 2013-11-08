package net.tileisle 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxU;
	import org.flixel.FlxG;
	import org.flixel.plugin.photonstorm.FlxMath;
	import org.flixel.plugin.photonstorm.FlxCollision;
	
	/**
	 * ...
	 * @author Tim
	 */
	public class Guy
	{
		
		private var _female:Boolean;
		
		public const COLOR_HUMAN:uint = 0xFF00FFFF;
		
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
		
		private var _life:Number; 
		private var _pos:FlxPoint;
		private var _action:int;
		
		private var _w:World;
		
		private var _targetTree:Tree;
		private var _home:House;
		private var _building:House;
		private var _athome:Boolean;
		private var _wait:Number;
		private var _sinceBirth:Number;
		private var _underground:Boolean;
		private var _digDir:int;
		
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
		
		public function Guy(w:World) 
		{
			_w = w;
		}
		
		public function spawn(X:Number, Y:Number):Guy
		{
			_life = 1;
			_female = SeedRnd.boolean();
			
			_pos = new FlxPoint(X, Y);
			_action = ACT_IDLE;
			_sinceBirth = SeedRnd.integer(60,100);
			_underground = false;
			_digDir = -1;
			_targetTree = null;
			_home = null;
			_athome = false;
			_building = null;
			_digDir = -1;
			_wait = 0;
			
			return this;
			
		}
		
		public function get atHome():Boolean
		{
			return _athome;
		}
		
		public function update():void
		{
			
			if (_action < ACT_TREE || _action == ACT_MINE)
			{
				_life-= SeedRnd.float(0.001, 0.003);
				
				if (SeedRnd.boolean(0.05))
				{
					if (_w.humanFood > 0)
						_w.humanFood -= SeedRnd.integer(0,2);
					else
						_life-=SeedRnd.float(0.003, 0.009);
				}
				
				if (FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y, _w.lyrMagma, 255))
				{
					//Magma!
					_life-=SeedRnd.float(0.3, 0.9);
				}
				
				if (_life <= 0)
				{
					//_dead = true;
					if (_home != null)
						_home.owned = false;
					return;
				}
			}
			
			if (_sinceBirth > 0)
				_sinceBirth--;
				
			if (_home == null)
			{
			// we need a house! check if there are any vacant ones...
				for each (var ch:House in _w.houses)
				{
					if (!ch.owned)
					{
						// my house!
						_home = ch;
						ch.owned = true;
					}
				}
			}
			
			
			/// if we're already doing something...
			if (_action > ACT_WALKDOWN)
			{
				switch(_action)
				{
					case ACT_TREE:
						ChopTree();
						break;
					case ACT_BUILD:
						BuildHouse();
						break;
					case ACT_BIRTH:
						BirthChild();
						break;
					case ACT_MINE:
						MineTunnel();
						break;
				}
			}
			else 
			{
				var t:Tree;
				t = null;
				if (!_underground && ((_home == null && _w.humanWood < 100) || _w.humanFood < 1000))
				{
					
					
					var closest:Number = FlxG.width * 2;
					var tDist:Number;
					_pos.y = _w.ground.points[_pos.x] - 1;
					
					/// find the nearest tree...
					for each (var t2:Tree in _w.trees)
					{
						if (t2.status == t2.STATUS_NORMAL && _pos.x > t2.x && _pos.x < t2.x + t2.width)
						{
							t = t2;
							_targetTree = t;
							t.status = t.STATUS_CUTTING;
							_action = ACT_TREE;
							break;
						}
					}
					
					if (_action != ACT_TREE)
					{
						for each (var t3:Tree in _w.trees)
						{
							if (t3.status == t2.STATUS_NORMAL)
							{
								tDist = Math.abs(FlxU.getDistance(_pos, new FlxPoint((t3.x/2)+1, t3.y+t3.height)));
								if (tDist < closest)
								{
									t = t3;
									closest = tDist;
								}
							}
						}
					}
					
				}
				
				if (t != null && _action != ACT_TREE)
				{
					if ((t.x / 2) + 1 < _pos.x)
					{
						//Walk(DIR_LEFT)
						_action = ACT_WALKLEFT;
						
					}
					else
					{
						//Walk(DIR_RIGHT);
						_action = ACT_WALKRIGHT;
					}
				}
				else if (_action != ACT_TREE)
				{
					if (_underground && _pos.y < _w.ground.points[_pos.x])
					{
						_underground = false;
						_pos.y = _w.ground.points[_pos.x] - 1;
						_action = -1;
					}
					
					if (_action == ACT_WALKLEFT)
					{
						if (_pos.x > 10 || (_underground && (!FlxCollision.pixelPerfectPointCheck(_pos.x - 1, _pos.y, _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(_pos.x - 1, _pos.y, _w.caves, 200) || _pos.y < _w.ground.points[_pos.x] + 16)))
							_action = -1;
					}
					
					if (_action == ACT_WALKRIGHT)
					{
						if (_pos.x < FlxG.width- 10 || (_underground && (!FlxCollision.pixelPerfectPointCheck(_pos.x + 1, _pos.y, _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(_pos.x + 1, _pos.y, _w.caves, 200) || _pos.y < _w.ground.points[_pos.x] + 16)))
							_action = -1;
					}
					
					if (_action == ACT_WALKUP)
					{
						if (!_underground || (_pos.y -2 < _w.ground.points[_pos.x] || (!FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y - 1, _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y - 1, _w.caves, 200))))
							_action = -1;
					}
					
					if (_action == ACT_WALKDOWN)
					{
						if (!_underground || (_pos.y > FlxG.height - 10 || (!FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y + 1, _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y + 1, _w.caves, 200))))
							_action = -1;
					}
					
					if (_action == -1 || SeedRnd.boolean(0.05))
					{
						// pick a new action!
						var acts:Array = new Array();
						acts.push(ACT_IDLE);
						if (_pos.x > 10)
						{
							if (!_underground || (FlxCollision.pixelPerfectPointCheck(_pos.x-1,_pos.y,_w.caves,50) && !FlxCollision.pixelPerfectPointCheck(_pos.x-1,_pos.y,_w.caves,200)))
								acts.push(ACT_WALKLEFT);
						}
						if (_pos.x < FlxG.width - 10)
						{
							if (!_underground || (FlxCollision.pixelPerfectPointCheck(_pos.x+1,_pos.y,_w.caves,50) && !FlxCollision.pixelPerfectPointCheck(_pos.x+1,_pos.y,_w.caves,200)))
								acts.push(ACT_WALKRIGHT);
						}
						if (_underground)
						{
							if (_pos.y -2 < _w.ground.points[_pos.x] || (FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y-1, _w.caves, 50) && !FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y-1, _w.caves, 200)))
								acts.push(ACT_WALKUP);
							if (_pos.y < FlxG.height - 10 && (FlxCollision.pixelPerfectPointCheck(_pos.x,_pos.y+1, _w.caves, 50) && !FlxCollision.pixelPerfectPointCheck(_pos.x,_pos.y+1, _w.caves, 200)))
								acts.push(ACT_WALKDOWN);
								
							acts.push(ACT_MINE);
						}
						else
						{
							if (_home == null && _w.humanWood > 100)
							{
								var avg:int;
								for (var s:int = _pos.x - 4; s < _pos.x +3; s++)
									avg += _w.ground.points[s];
								avg /= 7;
								
								var bX:int = _pos.x - 3;
								var bY:int = avg;
								
								var tmpS:FlxSprite = new FlxSprite(bX, bY-5).makeGraphic(7, 5, 0x00000000,true);
								if (!FlxG.overlap(_w.lyrHouses, tmpS) && !FlxG.overlap(_w.lyrTrees, tmpS))
									acts.push(ACT_BUILD);
								tmpS.kill();
							}
							
							if (_home != null)
							{
								if (_female)
								{
									if (_sinceBirth <= 0 && _w.humanFood >= 10)
										acts.push(ACT_BIRTH);
								}
								else
								{
									acts.push(ACT_MINE);
								}
							}
							
							for each (t in _w.trees)
							{
								if (t.status == t.STATUS_NORMAL)
								{
									if (_pos.x > t.x && _pos.x < t.x + t.width)
									{
										acts.push(ACT_TREE);
										break;
									}
								}
							}
							
						}
						
						_action = acts[SeedRnd.integer(0, acts.length)];
						
						switch(_action)
						{
							case ACT_TREE:
								_targetTree = t;
								t.status = t.STATUS_CUTTING;
								break;
							case ACT_BUILD:
								var h:House = new House(_w, bX,bY);
								_w.houses.push(h);
								_w.lyrHouses.add(h);
								_building = h;
								_home = h;
								h.owned = true;
								_w.humanWood -= 100;
								break;
							case ACT_MINE:
								if (!_underground)
								{
									_pos.y = _w.ground.points[_pos.x];
									_w.MakeCave(_pos.x, _pos.y,_w.CORIENT_D);
									
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
			
		}
		
		private function MineTunnel():void
		{
			/*
			 * else if (_pos.y < _w.ground.points[_pos.x] + 30)
			{
				if (FlxCollision.pixelPerfectPointCheck(_pos.x,_pos.y+1,_w.caves,50) && !FlxCollision.pixelPerfectPointCheck(_pos.x,_pos.y+1,_w.caves,255))
				{
					_pos.y++;
				}
				else
				{
					//want to go down, but no more down!
					//_w.caves.push(_w.lyrCaves.add(new Cave(_pos.x, _pos.y + 1)) as Cave);
					_w.MakeCave(_pos.x, _pos.y, 0);
					_pos.y++;
					
				}
			}*/
			
			if (!_underground)
			{
				_w.MakeCave(_pos.x, _pos.y,_w.CORIENT_D);
				_pos.y++;
				_underground = true;
			}
			else
			{
				
				if (_digDir == _w.CORIENT_L)
				{
					if (_pos.x < 10 || _pos.y < _w.ground.points[_pos.x] + 16) // (FlxCollision.pixelPerfectPointCheck(_pos.x - 1, _pos.y, _w.caves, 50)  && !FlxCollision.pixelPerfectPointCheck(_pos.x - 1, _pos.y, _w.caves, 200)) || 
					{
						if (SeedRnd.boolean(0.88))
							_digDir = _w.CORIENT_D;
						else 
							_digDir = _w.CORIENT_U;
					}
				}
				
				if (_digDir == _w.CORIENT_R)
				{
					if (_pos.x > FlxG.width- 10 ||  _pos.y < _w.ground.points[_pos.x] + 16)//(FlxCollision.pixelPerfectPointCheck(_pos.x + 1, _pos.y, _w.caves, 50) && !FlxCollision.pixelPerfectPointCheck(_pos.x + 1, _pos.y, _w.caves, 200)) ||
					{
						if (SeedRnd.boolean(0.88))
							_digDir = _w.CORIENT_D;
						else 
							_digDir = _w.CORIENT_U;
					}
				}
				
				if (_digDir == _w.CORIENT_U)
				{
					if (_pos.y  < _w.ground.points[_pos.x] )//|| (FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y - 1, _w.caves, 50) || !FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y - 1, _w.caves, 200)))
						_digDir = -1;
				}
				
				if (_digDir == _w.CORIENT_D)
				{
					if (_pos.y > FlxG.height - 10 )//|| (FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y + 1, _w.caves, 50) || !FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y + 1, _w.caves, 200)))
						_digDir = -1;
				}
				
				if (_digDir != -1 && SeedRnd.boolean(0.005)) 
				{	
					_digDir = -1;
					_action = -1;
				}
				else
				{
					var mDirs:Array = new Array();
					if (_digDir == -1 || _wait <=0)
					{
						_wait = SeedRnd.integer(5, 20);
						_digDir = -1;
						if (!FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y + 2, _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y + 2, _w.caves, 255) && _pos.y+1 < FlxG.height - 10)
						{
							mDirs.push(_w.CORIENT_D);
						}
						if ((!FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y - 2, _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(_pos.x, _pos.y - 2, _w.caves, 255)) && _pos.y >= _w.ground.points[_pos.x])
						{
							mDirs.push(_w.CORIENT_U);
						}
						
						if (_pos.y > _w.ground.points[_pos.x] + 16)
						{
							if ((!FlxCollision.pixelPerfectPointCheck(_pos.x+2, _pos.y, _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(_pos.x+2, _pos.y , _w.caves, 255)) && _pos.x + 1 < FlxG.width-10)
							{
								mDirs.push(_w.CORIENT_R);
							}
							if ((!FlxCollision.pixelPerfectPointCheck(_pos.x-2, _pos.y, _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(_pos.x-2, _pos.y, _w.caves, 255)) && _pos.x - 1 > 10)
							{
								mDirs.push(_w.CORIENT_L);
							}
						}
						
											
						if (mDirs.length > 0)
						{
							_digDir = mDirs[SeedRnd.integer(0, mDirs.length)];
						}
					}
					
					if (_digDir != -1)
					{
						_wait--;	
						_w.MakeCave(_pos.x, _pos.y, _digDir);
						Walk(_digDir);
					}
					else
					{
						_digDir	= -1;
						_action = -1;
					}
				}
			}
		}
		
		private function Walk(D:uint):void
		{
			// don't WALK into MAGMA!
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
		
		private function BirthChild():void
		{
			if (!_athome)
			{
				if (_home.x + 2 == _pos.x)
				{
					_athome = true;
					_wait = SeedRnd.integer(80, 120);
					_home.birthing = true;
					
				}
				else if (_home.x + 2 > _pos.x)
				{
					_pos.x++;
				}
				else if (_home.x +2 < _pos.x)
				{
					_pos.x--;
				}
			}
			else
			{
				if (_wait > 0)
					_wait--;
				else
				{
					_sinceBirth = SeedRnd.integer(70,100);
					_athome = false;
					_w.humanFood -= 10;
					_home.birthing = false;
					_w.SpawnGuy(_pos.x);
					_action = -1;
				}
			}
		}
		
		private function BuildHouse():void
		{
			if (_building == null)
			{
				_action = -1;
				return;
			}
			
			if (_building.health <= 50)
			{
				_building.build(SeedRnd.integer(0, 3));
			}
			else
			{
				_building = null;
				_action = -1;
			}
		}
		
		private function ChopTree():void
		{
			if (_targetTree == null) 
			{
				_action = -1;
				return;
			}
			
			var wood:int = SeedRnd.integer(0, 5);
			var food:int = SeedRnd.integer(5, 10);
			
			if (wood*3 > _targetTree.health) 
				_targetTree.health = 0;
			else
				_targetTree.health -= wood*3;
			_w.humanWood += wood;
			_w.humanFood += food;
			
			if (_targetTree.health <= 0)
			{
				_targetTree.status = _targetTree.STATUS_CUTDOWN;
				_targetTree.kill();
				_targetTree = null;
				_action = -1;
			}
			
		}
		
	}

}