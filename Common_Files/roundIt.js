function roundit(what,places,iplaces,pad)
{
 var xx = 0
 var ii = 0
 var padstr = ''
 var astr = ''
 var rstr = ''
 var zstr = '0000000000000000'
 var theInt = ''
 var theFrac = ''
 var theNo = ''
 var rfac = ''
 var rfacx = 0
 var whatx = 0

 var l = what.length					               //length of number string
 
 xt = parseInt(places) + 1              //turn places into a number
 


 
 rstr = '' + zstr.substring(1,xt)       //make the rounding string
 rfac = '.' + rstr + '5'
 rfacx = parseFloat(rfac)               //turn it into a number

 xx = what.indexOf('.')                 //where is decimal point
 if (xx == -1 )                         //case: no decimal point  
 {                                      //pad out fractional part with zeros
  theFrac = zstr
  theInt = what.substring(1,xx) 
 }
 else if (xx == 0)                      //case: no integer part
 {                                      //set into to zero; get frac
  theInt = '0'
  whatx = 0 + parseFloat(what) + parseFloat(rfacx) 
  what = whatx + zstr
	theFrac = '' + what.substring(1, what.length)
 }
 else                                   //case: both frac and int parts
 {       
  theInt = what.substring(0,xx)         //separate out integer
  whatx = parseFloat(what) + rfacx      //make numbers and add rounding number
  what = '' + whatx + zstr		          //pad out fractional part with zeros
  theFrac = '' + what.substring(xx+1,xx + 1 + parseInt(places))
                                        //chop it off in the right place
 }
 theFrac = theFrac.substring(0,parseInt(places))
 var dif = iplaces - theInt.length      //how many places to pad left
 for (ii = 0 ; ii < dif ; ii++)         //make padding string
 {
  padstr += pad
 }
 theNo = padstr + theInt + '.' + theFrac//put all parts together

 return theNo                           //and return the rounded number
}


