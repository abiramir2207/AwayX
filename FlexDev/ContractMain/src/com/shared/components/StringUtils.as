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

package com.shared.components
{
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
      temp = temp.replace( obj1, "" );
      if ( temp == " " )
      temp = "";
    }
     return temp;
  }
  /** split a list to an array using the carriage return delimiter */	
	  public static function listToArray(value:String, delimiter:String = "\r"):Array 
		{	
			var a:Array = new Array();
			a = value.split(delimiter);
	        return a;
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
 }
}