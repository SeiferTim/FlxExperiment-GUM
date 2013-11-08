package  
{
	import org.flixel.*;
	
	[SWF(width = "800", height = "600", backgroundColor = "#000000")]
	[Frame(factoryClass = "Preloader")]
	
	public class GUM extends FlxGame
	{
		
		public function GUM() 
		{
			//super(400, 300, GameState, 2);
			super(800, 600, GameState, 1);
			FlxG.flashFramerate = 60;
			FlxG.framerate = 60;
			canPause = false;
			
			
		}
		
	}

}