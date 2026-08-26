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
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.FlexGlobals;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.DateFormatter;
	import mx.formatters.NumberFormatter;
	
 public class StringUtils
 {
 	/*.......................  Properties  .......................*/
		public static var _numFormat:NumberFormatter =  new NumberFormatter();
		public static var _decFormat:NumberFormatter =  new NumberFormatter();
		public static var _decFormat2:NumberFormatter =  new NumberFormatter();
		public static var _decFormat2NoComma:NumberFormatter =  new NumberFormatter();
		public static var _dlrFormatter:CurrencyFormatter = new CurrencyFormatter();
		public static var _dlrFormatterDec:CurrencyFormatter = new CurrencyFormatter();
		public static var _dlrFormatterDec2:CurrencyFormatter = new CurrencyFormatter();
		public static var _dlrFormatterDec3:CurrencyFormatter = new CurrencyFormatter();		
		public static var _dtFormat:DateFormatter = new DateFormatter();
		public static var _dtFormatDateTime:DateFormatter = new DateFormatter();
  /**
   Constructor Function
  */
  public function StringUtils()
  {

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
  
 public static function roundDec(numIn:Number, decimalPlaces:int):Number {
	  var nExp:int = Math.pow(10,decimalPlaces) ; 
	  var nRetVal:Number = Math.round(numIn * nExp) / nExp
	  return nRetVal;
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
		
   /* Advanced datagrid labelFunc */
  	public static function FormatDecimal(item:Object, column:AdvancedDataGridColumn):String 
	{
		/* set formatter precision */
		_decFormat.precision = 4;
		_decFormat.useNegativeSign = false;
		return _decFormat.format(item[column.dataField]);
	}
  	public static function FormatDecimal2(item:Object, column:AdvancedDataGridColumn):String 
	{
		/* set formatter precision */
		_decFormat2.precision = 2;
		_decFormat2.useNegativeSign = false;
		return _decFormat2.format(item[column.dataField]);
	}
	public static function FormatNumber(item:Object, column:AdvancedDataGridColumn):String 
	{
		/* set formatter precision */
		_numFormat.precision = 0;
		_numFormat.useNegativeSign = false;
		return _numFormat.format(item[column.dataField]);
	}
	public static function FormatDollar(item:Object, column:AdvancedDataGridColumn):String 
	{
		_dlrFormatter.precision = 0;
		_dlrFormatter.currencySymbol = '$';
		_dlrFormatter.useNegativeSign = false;
		return _dlrFormatter.format(item[column.dataField]);		
	}	
	public static function FormatDollarDec(item:Object, column:AdvancedDataGridColumn):String 
	{
		_dlrFormatterDec.precision = 4;
		//_dlrFormatterDec.currencySymbol = '$';
		_dlrFormatterDec.useNegativeSign = false;
		return _dlrFormatterDec.format(item[column.dataField]);
	}	
	public static function FormatDollarDec2(item:Object, column:AdvancedDataGridColumn):String 
	{
		_dlrFormatterDec2.precision = 2;
		_dlrFormatterDec2.currencySymbol = '$ ';
		_dlrFormatterDec2.useNegativeSign = false;	
		return _dlrFormatterDec2.format(item[column.dataField]);
	}
	public static function FormatNumberDollarDec2(n:Number):String 
	{
		_dlrFormatterDec2.precision = 2;
		_dlrFormatterDec2.currencySymbol = '$ ';
		_dlrFormatterDec2.useNegativeSign = false;	
		return _dlrFormatterDec2.format(n);
	}
	public static function FormatDt(item:Object, column:AdvancedDataGridColumn):String
	{
		return _dtFormat.format(item[column.dataField]);
	}
	public static function FormatDtDg(item:Object, column:DataGridColumn):String
	{
		return _dtFormat.format(item[column.dataField]);
	}
	public static function FormatDate(d:Date):String
	{
		return _dtFormat.format(d);
	}
	
	public static function adgFormatDateTime(item:Object, column:AdvancedDataGridColumn):String 
	{
		_dtFormat.formatString = 'MM/DD/YYYY';
		_dtFormatDateTime.formatString 	= 'MM/DD/YYYY L:NN A';
		return _dtFormatDateTime.format(item[column.dataField]);
		
	}
	
	public static function formatDateTime(item:Object, column:DataGridColumn):String 
	{
		_dtFormat.formatString = 'MM/DD/YYYY';
		_dtFormatDateTime.formatString 	= 'MM/DD/YYYY L:NN A';
		return _dtFormatDateTime.format(item[column.dataField]);
		
	}
	public static function dgFormatDollarDec2(item:Object, column:DataGridColumn):String 
	{
		_dlrFormatterDec2.precision = 2;
		_dlrFormatterDec2.currencySymbol = '$';
		_dlrFormatterDec2.useNegativeSign = true;
		_dlrFormatterDec2.useThousandsSeparator = true;
		return _dlrFormatterDec2.format(item[column.dataField]);
	}	
	public static function dgFormatDecimal2(item:Object, column:DataGridColumn):String 
	{
		_decFormat2.precision = 2;
		_decFormat2.useNegativeSign = true;
		_decFormat2.useThousandsSeparator = true;
		return _decFormat2.format(item[column.dataField]);
	}
	
	
	/* accept a string parm */
	public static function getDecimal(s:String):String 
	{
		return _decFormat.format(s);
	}
	public static function getDecimal2(s:String):String 
	{
		/* set formatter precision */
		_decFormat2.precision = 2;
		_decFormat2.useNegativeSign = false;
		return _decFormat2.format(s);
	}
	public static function getDecimal2NoComma(s:String):Number 
	{
		_decFormat2NoComma.precision = 2;
		_decFormat2NoComma.useNegativeSign = false;
		_decFormat2NoComma.useThousandsSeparator = false;
		return Number(_decFormat2NoComma.format(s));
	}
	public static function getNumber(s:String):String 
	{
		return _numFormat.format(s);
	}
	public static function getNumberDec(s:String):String 
	{
		_numFormat.precision = 2;
		_numFormat.useNegativeSign = false;
		_numFormat.thousandsSeparatorFrom = ',';
		_numFormat.thousandsSeparatorTo = '';
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
	public static function getDollarDec2(s:String):String 
	{
		return _dlrFormatterDec2.format(s);	
	}
	/* 
		30402: Settlement Tab - Decimal Place view/ Anand Rao/13-Feb-2012 
		Not messing with existing functions and creating a new one with precision 2 and 
		dollar($) formatting.
	*/
	public static function getDollarDec3(s:String):String 
	{
		_dlrFormatterDec3.precision = 2;
		_dlrFormatterDec3.currencySymbol = '$';
		_dlrFormatterDec3.useNegativeSign = true;	
		//_dlrFormatterDec3.thousandsSeparatorFrom = ',';
		//_dlrFormatterDec3.thousandsSeparatorTo = '';	
		return _dlrFormatterDec3.format(s);
	}
	
	public static function getFormatDt(s:String):String
	{ 
		return _dtFormat.format(s);
	}
	public static function getDate(s:String):String 
	{
		return _dtFormat.format(s);
	}	
	public static function dateAdd(datepart:String = "", number:Number = 0, date:Date = null):Date
	{
		if (date == null) {
			date = new Date();
		}
		
		var returnDate:Date = new Date(date.time);;
		
		switch (datepart.toLowerCase()) {
			case "fullyear":
			case "month":
			case "date":
			case "hours":
			case "minutes":
			case "seconds":
			case "milliseconds":
				returnDate[datepart] += number;
				break;
			default:
				/* Unknown date part, do nothing. */
				break;
		}
		return returnDate;
	}
	
	/* I could not find a good dateDiff function to use. */
	public static function calculateDays( start:Date, end:Date ) :int 
	{ 
		var daysInMilliseconds:int = 1000*60*60*24 
		return (  (end.time - start.time)  / daysInMilliseconds ); 
	} 


 }
}