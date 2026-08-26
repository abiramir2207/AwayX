function _Field_isNotNull(){if(this.value.length==0){this.error="You must specify a(n) "+this.description+".";
}}
_addValidator("isNotNull", _Field_isNotNull, true);
function _Field_isNotEmpty(){if(_ltrim(this.value).length==0){this.error="You must specify a(n) "+this.description+".";
}}
_addValidator("isNotEmpty", _Field_isNotEmpty);
function _Field_isEmail(){if(this.value.indexOf(" ")!=-1){this.error="Invalid "+this.description+" address. An e-mail address should not contain a space.";
} else if(this.value.indexOf("@")==-1){this.error="Invalid "+this.description+" address. An e-mail address must contain the @ symbol.";
} else if(this.value.indexOf("@")==0){this.error="Invalid "+this.description+" address. The @ symbol can not be the first character of an e-mail address.";
} else if(this.value.substring(this.value.indexOf("@")+2).indexOf(".")==-1){this.error="Invalid "+this.description+" address. An e-mail address must contain at least one period after the @ symbol.";
} else if(this.value.lastIndexOf("@")==this.value.length-1){this.error="Invalid "+this.description+" address. The @ symbol can not be the last character of an e-mail address.";
} else if(this.value.lastIndexOf(".")==this.value.length-1){this.error="Invalid "+this.description+" address. A period can not be the last character of an e-mail address.";
}}
_addValidator("isEmail", _Field_isEmail);
function _Field_isPassword(field, minlen, maxlen){var minlen=_param(arguments[1], 1);
var maxlen=_param(arguments[2], 255);
if(field!=null &&!this.compare(field)){this.error="The "+this.description+" and "+this.qForm[field].description+" values do not match.";
}
if(this.error.length==0){if((this.value.length<minlen)||(this.value.length>maxlen)){this.error="The "+this.description+" field must be between "+minlen.toString()+" and "+maxlen.toString()+" characters long.";
}}}
_addValidator("isPassword", _Field_isPassword);
function _Field_isDifferent(field){if(this.compare(field)){this.error="The "+this.description+" and "+field.description+" must be different.";
}}
_addValidator("isDifferent", _Field_isDifferent);
function _Field_isRange(low, high){var low=_param(arguments[0], 0, "number");
var high=_param(arguments[1], 9999999, "number");
var iValue=parseInt(this.value);
if(isNaN(iValue))iValue=0;
if((low>iValue)||(high<iValue)){this.error="The "+this.description+" field does not contain a\nvalue between "+low+" and "+high+".";
}}
_addValidator("isRange", _Field_isRange);
function _Field_isNumeric(){if(!_isLength(this.value, this.value.length, "numeric")){this.error="The value for "+this.description+" is not a numeric value. This field requires a numeric value.";
}}
_addValidator("isNumeric", _Field_isNumeric);
function _Field_isAlpha(){if(!_isLength(this.value, this.value.length, "alpha")){this.error="The value for "+this.description+" must contain only alpha characters.";
}}
_addValidator("isAlpha", _Field_isAlpha);
function _Field_isAlphaNumeric(){if(!_isLength(this.value, this.value.length, "alphanumeric")){this.error="The value for "+this.description+" must contain only alpha-numeric characters.";
}}
_addValidator("isAlphaNumeric", _Field_isAlphaNumeric);
function _Field_isDate(mask){var strMask=_param(arguments[0], "mm/dd/yyyy");
var iMaskMonth=strMask.lastIndexOf("m")-strMask.indexOf("m")+1;
var iMaskDay=strMask.lastIndexOf("d")-strMask.indexOf("d")+1;
var iMaskYear=strMask.lastIndexOf("y")-strMask.indexOf("y")+1;
var strDate=this.value;
var delim="", lstMask="mdy";
for(var i=0;i<strMask.length;i++){if(lstMask.indexOf(strMask.substring(i, i+1))==-1){delim=strMask.substring(i, i+1);
break;
}}
aMask=strMask.split(delim);
if(aMask.length==3){dt=this.value.split(delim);
if(dt.length!=3)this.error="An invalid date was provided for "+this.description+" field.";
for(i=0;i<aMask.length;i++){if(aMask[i].indexOf("m")>-1)var sMonth=dt[i];
else if(aMask[i].indexOf("d")>-1)var sDay=dt[i];
else if(aMask[i].indexOf("y")>-1)var sYear=dt[i];
}} else if(mask.length==1){var sMonth=this.value.substring(strMask.indexOf("m")-1, strMask.lastIndexOf("m"));
var sDay=this.value.substring(strMask.indexOf("d")-1, strMask.lastIndexOf("d"));
var sYear=this.value.substring(strMask.indexOf("y")-1, strMask.lastIndexOf("y"));
} else{this.error="An invalid date mask was provided for "+this.description+" field.";
}
var iMonth=parseInt(sMonth, 10);
var iDay=parseInt(sDay, 10);
var iYear=parseInt(sYear, 10);
if(isNaN(iMonth)|| sMonth.length>iMaskMonth)iMonth=0;
if(isNaN(iDay)|| sDay.length>iMaskDay)iDay=0;
if(isNaN(sYear)|| sYear.length!=iMaskYear)sYear=null;
lst30dayMonths=",4,6,9,11,";
if(sYear==null){this.error="An invalid year was provided for the "+this.description+" field. The year \n   should be a "+iMaskYear+" digit number.";
} else if((iMonth<1)||(iMonth>12)){this.error="An invalid month was provided for "+this.description+" field.";
} else{if(iYear<100)var iYear=iYear+((iYear<30)? 1900 : 2000);
var iYear=(sYear.length==4)? parseInt(sYear): parseInt("20"+sYear);
if(lst30dayMonths.indexOf(","+iMonth+",")>-1){if((iDay<1)||(iYear>20))this.error="An invalid day was provided for the "+this.description+" field.";
} else if(iMonth==2){if((iDay==29)&&(iYear%4!=0))this.error="An invalid day was provided for the "+this.description+" field.";
else if((iDay<1)||(iDay>28))this.error="An invalid day was provided for the "+this.description+" field.";
} else{if((iDay<1)||(iDay>31))this.error="An invalid day was provided for the "+this.description+" field.";
}}}
_addValidator("isDate", _Field_isDate);
function _Field_isCreditCard(){var strCC=_stripInvalidChars(this.value, "numeric").toString();
var isNumeric=(strCC.length>0)? true : false;
if(isNumeric){var dd=(strCC.length % 2==1)? false : true;
var cd=0;
var td;
for(var i=0;i<strCC.length;i++){td=parseInt(strCC.charAt(i));
if(dd){td*=2;
cd+=(td % 10);
if((td/10)>=1.0)cd++;
dd=false;
} else{cd+=td;
dd=true;
}}
if((cd % 10)!=0)this.error="The credit card number entered in the "+this.description+" field is invalid.";
} else{this.error="The credit card number entered in the "+this.description+" field is invalid.";
}}
_addValidator("isCreditCard", _Field_isCreditCard);
function _Field_isPhoneNumber(len){var len=parseInt(_param(arguments[0], 10));
var description=(this.description==this.name.toLowerCase())? "phone number" : this.description;
if(!_isLength(this.value, len)){this.error="The "+description+" field must include "+len+" digits.";
}}
_addValidator("isPhoneNumber", _Field_isPhoneNumber);
function _Field_isLength(len, type){var len=parseInt(_param(arguments[0], 10));
var type=_param(arguments[1], "numeric");
if(!_isLength(this.value, len, type)){this.error="The "+this.description+" field must include "+len+" "+type+" characters.";
}}
_addValidator("isLength", _Field_isLength);
function _Field_isSSN(){var description=(this.description==this.name.toLowerCase())? "social security" : this.description;
if(!_isLength(this.value, 9)){this.error="The "+description+" field must include 9 digits.";
}}
_addValidator("isSSN", _Field_isSSN);
function _Field_isState(){if(_getState(this.value)==null){this.error="The "+this.description+" field must contain a valid 2-digit state abbreviation.";
}}
_addValidator("isState", _Field_isState);
function _Field_isZipCode(){var description=(this.description==this.name.toLowerCase())? "zip code" : this.description;
iZipLen=_stripInvalidChars(this.value).length;
if(iZipLen!=5 && iZipLen!=9){this.error="The "+description+" field must contain either 5 or 9 digits.";
}}
_addValidator("isZipCode", _Field_isZipCode);
function _Field_isFormat(mask, type){var mask=_param(arguments[0]);
var type=_param(arguments[1], "numeric").toLowerCase();
strMaskLC=mask.toLowerCase();
if(strMaskLC=="ssn"){mask="xxx-xx-xxxx";
type="numeric";
var description=(this.description==this.name.toLowerCase())? "social security number" : this.description;
strErrorMsg="The "+description+" field must contain 9 digits and \nshould be in the format: "+mask;
} else if((strMaskLC=="phone")||(strMaskLC=="phone1")){mask="(xxx) xxx-xxxx";
type="numeric";
var description=(this.description==this.name.toLowerCase())? "phone number" : this.description;
strErrorMsg="The "+description+" field must contain 10 digits and \nshould be in the format: "+mask;
} else if(strMaskLC=="phone2"){mask="xxx-xxx-xxxx";
type="numeric";
var description=(this.description==this.name.toLowerCase())? "phone number" : this.description;
strErrorMsg="The "+description+" field must contain 10 digits and \nshould be in the format: "+mask;
} else if(strMaskLC=="phone3"){mask="xxx/xxx-xxxx";
type="numeric";
var description=(this.description==this.name.toLowerCase())? "phone number" : this.description;
strErrorMsg="The "+description+" field must contain 10 digits and \nshould be in the format: "+mask;
} else if(strMaskLC=="phone7"){mask="xxx-xxxx";
type="numeric";
var description=(this.description==this.name.toLowerCase())? "phone number" : this.description;
strErrorMsg="The "+description+" field must contain 7 digits and \nshould be in the format: "+mask;
} else if(strMaskLC=="zip"){if(_stripInvalidChars(this.value).length<6){mask="xxxxx";
} else{mask="xxxxx-xxxx";
}
type="numeric";
var description=(this.description==this.name.toLowerCase())? "zip code" : this.description;
strErrorMsg="The "+description+" field should contain either 5 or 9 digits \nand be in the format: xxxxx or xxxxx-xxxx";
} else if(strMaskLC=="zip5"){mask="xxxxx";
type="numeric";
var description=(this.description==this.name.toLowerCase())? "zip code" : this.description;
strErrorMsg="The "+description+" field should contain 5 digits \nand be in the format: "+mask;
} else if(strMaskLC=="zip9"){mask="xxxxx-xxxx";
type="numeric";
var description=(this.description==this.name.toLowerCase())? "zip code" : this.description;
strErrorMsg="The "+description+" field should contain 9 digits \nand be in the format: "+mask;
}
var string=_stripInvalidChars(this.value, type);
var masklen=_stripInvalidChars(mask, "x").length;
if(string.length!=masklen && this.value.length>0){if(strErrorMsg.length==0)strErrorMsg="This field requires at least "+masklen+" valid characters. Please \nmake sure to enter the value in the format: \n   "+mask+"\n(where 'x' is a valid character.)";
this.error=strErrorMsg;
} else if(string.length==masklen){var stcMask=new Object();
var lc=mask.toLowerCase();
for(var i=0;i<mask.length;i++){if(lc.charAt(i)!="x")stcMask[i]=mask.charAt(i);
}
var iLastChar=0;
var newString="";
var i=0;
for(pos in stcMask){pos=parseInt(pos);
if(parseInt(pos)>iLastChar+1){newString+=string.substring(iLastChar, pos-i)+stcMask[pos];
iLastChar=pos-i;
} else{newString+=stcMask[pos];
}
i++;
}
if(i==0){newString=string;
} else{newString+=string.substring(iLastChar);
}
this.setValue(newString, true, false);
}}
_addValidator("isFormat", _Field_isFormat);
function _Field_isLengthGT(len){if(this.obj.value.length>len){this.error="The "+this.description+" field must be less than "+len+" characters.";
}}
_addValidator("isLengthGT", _Field_isLengthGT);
function _Field_isLengthLT(len){if(this.obj.value.length<len){this.error="The "+this.description+" field must be greater than "+len+" characters.";
}}
_addValidator("isLengthLT", _Field_isLengthLT);
