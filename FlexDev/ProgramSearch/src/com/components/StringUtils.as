/**
 *  User StringUtils
 *
 *  This code defines a custom StringUtils that allows you to do following StringManipulations.
 * Trim:
 *  Trim/Strip unwanted spaces from the string.
 *  Syntax: Trim( String, Boolean = true) : String;
 *  If second @param is false Trim method will not remove the unwanted spaces in the String, But will trim the left and right spaces.
 *  
 * StripHtmlTags:
 *  Strip Html tags from the string.
 *  Syntax: StripHtmlTags( String ) : String;  
 *  
 * IsNumeric:
 *  Checks and returns Boolean whether given String is numeric or not.
 *  Syntax: IsNumeric( String ) : Boolean;
 *  
 * RemoveDuplicateWords:
 *  Removes the repeated words from the given String.
 *  Syntax: IsNumeric( String ) : Boolean;  
 *  
 * CapitalizeFirstLetters:
 *  Capitalizes the first character of the words in the given String.
 *  Syntax: CapitalizeFirstLetters( String , Boolean ) : Boolean;  
 *  If second @param is false CapitalizeFirstLetters method will Capitalize all the letters.
 *  
**/

package com.components
{
/**
  * Functions for string manipulation.There is also a built-in class called StringUtil.as
*/
 public class StringUtils
 {
  /**
   Constructor Function
  */
  public function StringUtils()
  {}
  /**
   * Trim/Strip unwanted spaces from the string.
   *
   * @param String  String to be trimmed
   * @param Boolean  default is true, if false is used will do only LTrim and RTrim.
   * @return    Trimmed String
   */
  public static function Trim( inputStr : String, extraWhiteSpace : Boolean = true ) : String
  {
   var temp : String = inputStr;
   var obj : RegExp = /^(\s*)([\W\w]*)(\b\s*$)/;
   if ( obj.test(temp) )
   temp = temp.replace(obj, '$2');
   if( extraWhiteSpace )
   {
      var obj1 : RegExp = / +/g;
      temp = temp.replace( obj1, " " );
      if ( temp == " " )
      temp = "";
    }
     return temp;
  }
  /**
   * Strip Html tags from the string.
   *
   * @param String  String to be Strip
   * @return    Clear String with no tags
   */
  public static function StripHtmlTags( inputStr : String ) : String
  {
   return inputStr.replace(RegExp(/<.*?>/g),"" );
  }
  /**
   * Checks and returns Boolean whether given String is numeric or not.
   *
   * @param String  String contains numeric data
   * @return    Boolean.
   */
  public static function IsNumeric( inputStr : String ) : Boolean
  {
   var obj:RegExp = /^(0|[1-9][0-9]*)$/;
   return obj.test(inputStr);
  }
  public static function RemoveDuplicateWords( inputStr : String ) : String
  {
   var obj:RegExp = new RegExp("\\b (?<word>[a-z]+) \\s+ \\k<word> \\b", "gix")
   return Trim(inputStr.replace(obj, "" ), true);
  }
  /**
   * Capitalizes the first character of the words in the given String.
   *
   * @param String  String to be Capitalized
   * @param Boolean  default is true, if false is used will capitalize all the chars.
   * @return    Capitalized String
   */
  public static function CapitalizeFirstLetters( inputStr:String, allChars : Boolean = true ) : String
  {
   
   var str:String;
   if( allChars )
   {
    var outputStr:String = "";
    var arr : Array = inputStr.split(" ");
    var len : Number = arr.length;
    for(var j : int = 0; j< len; j++){
    str = arr[j].substr(0,1)
    outputStr += str.toUpperCase()+arr[j].substr(1)+" ";
    }
    return Trim(outputStr);
   }
   return inputStr.toUpperCase();
  }
   /**
   * Return current date.
   * @param date  date to be formatted
	* @return    formatted date as string
   */
   public static function getUSDate(d:Date):String { 
		var weekDayLabels:Array = new Array("Sun",
		                    "Mon",
		                    "Tues",
		                    "Wed",
		                    "Thur",
		                    "Fri",
		                    "Sat");
		 var monthLabels:Array = new Array("January",
                  "February",
                  "March",
                  "April",
                  "May",
                  "June",
                  "July",
                  "August",
                  "September",
                  "October",
                  "November",
                  "December");
         var s:String;
         var m:Number;
         m = d.getMonth() + 1;
         //s = weekDayLabels[d.getDay()];
         //s = s + ' ' + monthLabels[d.getMonth()];
         //s = s + ' ' + m;
         s = m + '/' + d.getDate();
         s = s + '/' + d.getFullYear();
		return s;
   }
   /**
   * Return time.
   * @param int  hours  to be formatted
   * @param int  minutes to be formatted
	* @return    formatted time as string
   */		
  public static function getUSClockTime(hrs:uint, mins:uint):String {
	    var modifier:String = "PM";
	    var minLabel:String = doubleDigitFormat(mins) as String;
		var s:String;
	    if(hrs > 12) {
	        hrs = hrs-12;
	    } else if(hrs == 0) {
	        modifier = "AM";
	        hrs = 12;
	    } else if(hrs < 12) {
	        modifier = "AM";
	    }
		s = (doubleDigitFormat(hrs) + ":" + minLabel + " " + modifier);
	    return s;
	}
   /**
   * Return value appended by zero, if value less than 10
   * @param int  an inetger
	* @return    a 2 digit number with a zero appended
   */	
	public static function doubleDigitFormat(num:uint):String {
		var n:String;
		n = num.toString();
	    if(num < 10) {
	       n = "0" + n;
	    }
	    return n ;
	}
 }
}