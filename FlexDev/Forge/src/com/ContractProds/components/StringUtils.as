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

package com.ContractProds.components
{
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.formatters.NumberFormatter;
	import mx.formatters.CurrencyFormatter;
	
 public class StringUtils
 {
 	/*.......................  Properties  .......................*/
		public static var _numFormat:NumberFormatter =  new NumberFormatter();
		public static var _decFormat:NumberFormatter =  new NumberFormatter();
		public static var _dlrFormatter:CurrencyFormatter = new CurrencyFormatter();
		public static var _dlrFormatterDec:CurrencyFormatter = new CurrencyFormatter();
  /**
   Constructor Function
  */
  public function StringUtils()
  {
  	/* set formatter precision */
	_decFormat.precision = 4;
	_decFormat.useNegativeSign = false;
	/* set formatter precision */
	_numFormat.precision = 0;
	_numFormat.useNegativeSign = false;
	
	_dlrFormatter.precision = 0;
	_dlrFormatter.currencySymbol = '$';
	_dlrFormatter.useNegativeSign = false;
	
	_dlrFormatterDec.precision = 4;
	//_dlrFormatterDec.currencySymbol = '$';
	_dlrFormatterDec.useNegativeSign = false;
  }
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
	  public static function listToArray(value:String, delimiter:String = "\r\n"):Array 
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
  public static function IsNumeric( val : String ) : Boolean
  {
     if (val != null && !isNaN(Number(val))) {
         return true;
    }
    return false;
  }
  public static function leadingZero(i:int):String{
  	var s:String = '';
  		s = s + i as String;
  	if(i < 10){ 
		s = "0" + s;
	}
	return s;
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
   /* Advanced datagrid labelFunc */
  	public static function FormatDecimal(item:Object, column:AdvancedDataGridColumn):String 
	{
		return _decFormat.format(item[column.dataField]);
	}
	public static function FormatNumber(item:Object, column:AdvancedDataGridColumn):String 
	{
		return _numFormat.format(item[column.dataField]);
	}
	public static function FormatDollar(item:Object, column:AdvancedDataGridColumn):String 
	{
		return _dlrFormatter.format(item[column.dataField]);
		
	}
	public static function FormatDollarDec(item:Object, column:AdvancedDataGridColumn):String 
	{
			return _dlrFormatterDec.format(item[column.dataField]);
	
	}
	/* accept a string parm */
	public static function getDecimal(s:String):String 
	{
		return _decFormat.format(s);
	}
	public static function getNumber(s:String):String 
	{
		return _numFormat.format(s);
	}
	public static function getDollar(s:String):String 
	{
		return _dlrFormatter.format(s);
		
	}
	public static function getDollarDec(s:String):String 
	{
			return _dlrFormatterDec.format(s);
	
	}
 }
}