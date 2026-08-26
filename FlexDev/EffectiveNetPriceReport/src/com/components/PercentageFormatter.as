package com.components
{
    import mx.formatters.Formatter;
    //import mx.formatters.SwitchSymbolFormatter;

    public class PercentageFormatter extends Formatter 
    {
        // Declare the variable to hold the pattern string.
        public var precision:Number = 0;

        // Constructor
        public function PercentageFormatter() {
            // Call base class constructor.
            super();
        }
        
        private function numericRoundDecimal(fVal:Number, decimalLen:Number):Number
		{
			var divVal:Number = Math.pow(10, decimalLen);		
			var newAmount:Number = fVal;
			newAmount = newAmount * divVal;
			newAmount = Math.round(newAmount);
			newAmount = newAmount / divVal;
			return newAmount;
		}

        // Override format().
        override public function format(value:Object):String {
        	try
        	{
	            // 1. Validate value - must be a nonzero length string.
	            if( value.toString().length == 0)
				{   
					return "";
				}

		   		// 2. If the value is valid, format the string.
		    	return numericRoundDecimal(Number(value) * 100, precision) + "%";
        	}
        	catch(e:Error)
        	{
        		return "";
        	}
        	return "";		    
        }
    }
}