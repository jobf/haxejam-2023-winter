package test;

/**
	A stand in for real FlxRandom because the real class has dependencies which won't run on eval
**/
class FlxRandomShim
{
	public static inline var MAX_VALUE_INT:Int = 0x7FFFFFFF;

	/**
	 * Internal method to quickly generate a pseudorandom number. Used only by other functions of this class.
	 * Also updates the internal seed, which will then be used to generate the next pseudorandom number.
	 *
	 * @return  A new pseudorandom number.
	 */
	inline function generate():Float
	{
		return internalSeed = (internalSeed * MULTIPLIER) % MODULUS;
	}

	/**
	 * The global base random number generator seed (for deterministic behavior in recordings and saves).
	 * If you want, you can set the seed with an integer between 1 and 2,147,483,647 inclusive.
	 * Altering this yourself may break recording functionality!
	 */
	public var initialSeed(default, set):Int = 1;

	/**
	 * The actual internal seed. Stored as a Float value to prevent inaccuracies due to
	 * integer overflow in the generate() equation.
	 */
	var internalSeed:Float = 1;

	/**
	 * Constants used in the pseudorandom number generation equation.
	 * These are the constants suggested by the revised MINSTD pseudorandom number generator,
	 * and they use the full range of possible integer values.
	 *
	 * @see http://en.wikipedia.org/wiki/Linear_congruential_generator
	 * @see Stephen K. Park and Keith W. Miller and Paul K. Stockmeyer (1988).
	 *      "Technical Correspondence". Communications of the ACM 36 (7): 105–110.
	 */
	static inline var MULTIPLIER:Float = 48271.0;

	static inline var MODULUS:Int = MAX_VALUE_INT;

	public function new(?InitialSeed:Int)
	{
		if (InitialSeed != null)
		{
			initialSeed = InitialSeed;
		}
		else
		{
			resetInitialSeed();
		}
	}

	/**
	 * Function to easily set the global seed to a new random number.
	 * Please note that this function is not deterministic!
	 * If you call it in your game, recording may not function as expected.
	 *
	 * @return  The new initial seed.
	 */
	public inline function resetInitialSeed():Int
	{
		return initialSeed = rangeBound(Std.int(Math.random() * MAX_VALUE_INT));
	}

	/**
	 * Internal shared function to ensure an arbitrary value is in the valid range of seed values.
	 */
	static inline function rangeBound(Value:Int):Int
	{
		return Std.int(bound(Value, 1, MODULUS - 1));
	}

	/**
	 * Returns a pseudorandom integer between Min and Max, inclusive.
	 * Will not return a number in the Excludes array, if provided.
	 * Please note that large Excludes arrays can slow calculations.
	 *
	 * @param   Min        The minimum value that should be returned. 0 by default.
	 * @param   Max        The maximum value that should be returned. 2,147,483,647 by default.
	 * @param   Excludes   Optional array of values that should not be returned.
	 */
	public function int(Min:Int = 0, Max:Int = MAX_VALUE_INT, ?Excludes:Array<Int>):Int
	{
		if (Min == 0 && Max == MAX_VALUE_INT && Excludes == null)
		{
			return Std.int(generate());
		}
		else if (Min == Max)
		{
			return Min;
		}
		else
		{
			// Swap values if reversed
			if (Min > Max)
			{
				Min = Min + Max;
				Max = Min - Max;
				Min = Min - Max;
			}

			if (Excludes == null)
			{
				return Math.floor(Min + generate() / MODULUS * (Max - Min + 1));
			}
			else
			{
				var result:Int = 0;

				do
				{
					result = Math.floor(Min + generate() / MODULUS * (Max - Min + 1));
				}
				while (Excludes.indexOf(result) >= 0);

				return result;
			}
		}
	}

	/**
	 * Internal function to update the current seed whenever the initial seed is reset,
	 * and keep the initial seed's value in range.
	 */
	inline function set_initialSeed(NewSeed:Int):Int
	{
		return initialSeed = currentSeed = rangeBound(NewSeed);
	}

	/**
	 * Current seed used to generate new random numbers. You can retrieve this value if,
	 * for example, you want to store the seed that was used to randomly generate a level.
	 */
	public var currentSeed(get, set):Int;

	/**
	 * Returns the internal seed as an integer.
	 */
	inline function get_currentSeed():Int
	{
		return Std.int(internalSeed);
	}

	/**
	 * Sets the internal seed to an integer value.
	 */
	inline function set_currentSeed(NewSeed:Int):Int
	{
		return Std.int(internalSeed = rangeBound(NewSeed));
	}

	public static inline function bound(Value:Float, ?Min:Float, ?Max:Float):Float
	{
		var lowerBound:Float = (Min != null && Value < Min) ? Min : Value;
		return (Max != null && lowerBound > Max) ? Max : lowerBound;
	}
}
