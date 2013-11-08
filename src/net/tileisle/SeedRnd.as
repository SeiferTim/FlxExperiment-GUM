package net.tileisle
{
	import org.flixel.FlxG;
	public class SeedRnd
	{
		// random(); // returns a number between 0-1 exclusive.
		public static function random(seeded:Boolean = true):Number 
		{
			if (seeded)
				return FlxG.random();
			else	
				return Math.random();	
		}
		// float(50); // returns a number between 0-50 exclusive
		// float(20,50); // returns a number between 20-50 exclusive
		public static function float(min:Number, max:Number = NaN, seeded:Boolean = true):Number
		{
			if (isNaN(max)) { max = min; min = 0; }
				return random(seeded) * (max - min) + min;
		}
		
		// boolean(); // returns true or false (50% chance of true)
		// boolean(0.8); // returns true or false (80% chance of true)
		public static function boolean(chance:Number = 0.5, seeded:Boolean = true):Boolean 
		{
			return (random(seeded) < chance);
		}
		
		// sign(); // returns 1 or -1 (50% chance of 1)
		// sign(0.8); // returns 1 or -1 (80% chance of 1)
		public static function sign(chance:Number = 0.5, seeded:Boolean = true):int 
		{
			return (random(seeded) < chance) ? 1 : -1;
		}
		
		// bit(); // returns 1 or 0 (50% chance of 1)
		// bit(0.8); // returns 1 or 0 (80% chance of 1)
		public static function bit(chance:Number=0.5, seeded:Boolean = true):int {
			return (random(seeded) < chance) ? 1 : 0;
		}
		
		// integer(50); // returns an integer between 0-49 inclusive
		// integer(20,50); // returns an integer between 20-49 inclusive
		public static function integer(min:Number,max:Number=NaN, seeded:Boolean = true):int {
			if (isNaN(max)) { max = min; min=0; }
			// Need to use floor instead of bit shift to work properly with negative values:
			return Math.floor(float(min, max, seeded));
		}	
	}

}