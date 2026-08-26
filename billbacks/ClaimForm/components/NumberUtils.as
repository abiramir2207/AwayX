package components
{
   // Class to compare 2 Numbers. Returns True or false
   
	public class NumberUtils
	{
		public function numCompare(num1:Number,num2:Number):Boolean
			{
				return (num1 != num2);
				
			}
			
		public function totalsCompare(num1:Number,num2:Number):Boolean
		{
			return (num2 >= (num1 - 5) && num2 <= (num1 + 5));
		}
	}
}