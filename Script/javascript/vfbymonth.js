jQuery.extend({_commafy:function(str){return str.replace(/(\D?)(\d{4,})/g,function($0,$1,$2){return(/[.\w]/).test($1)?$0:$1+$2.replace(/\d(?=(?:\d\d\d)+(?!\d))/g,'$&,')})},_DimensionCount:function(a){var c=0;for(var i=0;i<a.length;i++){if(a[i].constructor==Array){c++}}return c},Abs:function(n){return Math.abs(n)},ArrayAppend:function(a,v){return a.push(v)},ArrayPrepend:function(a,v){return a.unshift(v)},ArraySort:function(a,st,so){var _so;if(st.toUpperCase()=='TEXTNOCASE'){if(!so||so.toUpperCase()!="DESC"){_so=function(a,b){a=a.toUpperCase();b=b.toUpperCase();if(a<b){return-1}else if(a>b){return 1}else{return 0}}}else{_so=function(a,b){a=a.toUpperCase();b=b.toUpperCase();if(a>b){return-1}else if(a<b){return 1}else{return 0}}}}else if(st.toUpperCase()=='TEXT'){if(!so||so.toUpperCase()!="DESC"){_so=function(a,b){if(a<b){return-1}else if(a>b){return 1}else{return 0}}}else{_so=function(a,b){if(a>b){return-1}else if(a<b){return 1}else{return 0}}}}else if(st.toUpperCase()=='NUMERIC'){if(!so||so.toUpperCase()!="DESC"){_so=function(a,b){return a-b}}else{_so=function(a,b){return b-a}}}return a.sort(_so)},ArrayToList:function(a,d){if(!d){d=","}var re=/[,]/gi;return a.toString().replace(re,d)},ArrayLen:function(a){return a.length},Ceiling:function(n){return Math.ceil(n)},Compare:function(s1,s2){if(s1==s2){return 0}if(s1>s2){return 1}else{return-1}},CompareNoCase:function(s1,s2){return this.Compare(s1.toUpperCase(),s2.toUpperCase())},CreateDate:function(y,m,d){var rd=new Date();rd.setFullYear(y);rd.setMonth(m-1);rd.setDate(d);rd.setHours(0);rd.setMinutes(0);rd.setSeconds(0);return rd},CreateDateTime:function(y,m,d,h,n,s){var rd=new Date();rd.setFullYear(y);rd.setMonth(m-1);rd.setDate(d);rd.setHours(h);rd.setMinutes(n);rd.setSeconds(s);return rd},CreateTime:function(h,n,s){var rd=new Date();rd.setFullYear(1899);rd.setMonth(11);rd.setDate(30);rd.setHours(h);rd.setMinutes(n);rd.setSeconds(s);return rd},CreateODBCDate:function(d){var error="invalid date object";var year,month,day;if(isNaN(Date.parse(d))){return error}year=d.getFullYear();month=d.getMonth()+1;month=(month<10)?"0"+month:month;day=d.getDate();day=(day<10)?"0"+day:day;return"{d '"+year+"-"+month+"-"+day+"'}"},CreateODBCDateTime:function(d){var error="invalid date object";var year,month,day,hours,minutes,seconds;if(isNaN(Date.parse(d))){return error}year=d.getFullYear();month=d.getMonth()+1;month=(month<10)?"0"+month:month;day=d.getDate();day=(day<10)?"0"+day:day;hours=d.getHours();minutes=d.getMinutes();seconds=d.getSeconds();return"{ts '"+year+"-"+month+"-"+day+" "+hours+":"+minutes+":"+seconds+"'}"},CreateODBCTime:function(d){var error="invalid date object";var hours,minutes,seconds;if(isNaN(Date.parse(d))){return error}hours=d.getHours();minutes=d.getMinutes();seconds=d.getSeconds();return"{t '"+hours+":"+minutes+":"+seconds+"'}"},DateDiff:function(dp,d1,d2){var dt1=new Date(d1);var dt2=new Date(d2);var iDiffMS=dt2.valueOf()-dt1.valueOf();var dtDiff=new Date(iDiffMS);var nYears=dt2.getUTCFullYear()-dt1.getUTCFullYear();var nMonths=dt2.getUTCMonth()-dt1.getUTCMonth()+(nYears!==0?nYears*12:0);var nQuarters=nMonths/3;var nMilliseconds=iDiffMS;var nSeconds=iDiffMS/1000;var nMinutes=nSeconds/60;var nHours=nMinutes/60;var nDays=nHours/24;var nWeeks=nDays/7;var iDiff=0;switch(dp.toLowerCase()){case"yyyy":return nYears;case"q":return nQuarters;case"m":return nMonths;case"y":return nDays;case"d":return nDays;case"w":return nDays;case"ww":return nWeeks;case"h":return nHours;case"n":return nMinutes;case"s":return nSeconds;case"ms":return nMilliseconds;default:return"invalid interval: '"+dp+"'"}},DateFormat:function(d,mask){if(!(d instanceof Date)){d=new Date(d)}var zeroize=function(value,length){if(!length){length=2}value=String(value);for(var i=0,zeros='';i<(length-value.length);i++){zeros+='0'}return zeros+value};return mask.replace(/"[^"]*"|'[^']*'|\b(?:d{1,4}|m{1,4}|yy(?:yy)?|([hHMstT])\1?|[lLZ])\b/g,function($0){switch($0){case'd':return d.getDate();case'dd':return zeroize(d.getDate());case'ddd':return['Sun','Mon','Tue','Wed','Thr','Fri','Sat'][d.getDay()];case'dddd':return['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'][d.getDay()];case'm':return d.getMonth()+1;case'mm':return zeroize(d.getMonth()+1);case'mmm':return['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.getMonth()];case'mmmm':return['January','February','March','April','May','June','July','August','September','October','November','December'][d.getMonth()];case'yy':return String(d.getFullYear()).substr(2);case'yyyy':return d.getFullYear();case'h':return d.getHours()%12||12;case'hh':return zeroize(d.getHours()%12||12);case'H':return d.getHours();case'HH':return zeroize(d.getHours());case'M':return d.getMinutes();case'MM':return zeroize(d.getMinutes());case's':return d.getSeconds();case'ss':return zeroize(d.getSeconds());case'l':return zeroize(d.getMilliseconds(),3);case'L':var m=d.getMilliseconds();if(m>99){m=Math.round(m/10)}return zeroize(m);case'tt':return d.getHours()<12?'am':'pm';case't':return d.getHours()<12?'a':'p';case'TT':return d.getHours()<12?'AM':'PM';case'T':return d.getHours()<12?'A':'P';case'Z':return d.toUTCString().match(/[A-Z]+$/);default:return $0.substr(1,$0.length-2)}})},DatePart:function(dp,d){var d1;switch(dp){case"yyyy":return d.getFullYear();case"q":var m=d.getMonth()+1;switch(m){case 1:case 2:case 3:return 1;case 4:case 5:case 6:return 2;case 7:case 8:case 9:return 3;case 10:case 11:case 12:return 4}case"m":m=d.getMonth()+1;m=(m<10)?"0"+m:m;return m;case"y":d1=this.CreateDate(d.getFullYear(),1,1);return Math.ceil(this.DateDiff("d",d1,d));case"d":var day=d.getDate();day=(day<10)?"0"+day:day;return day;case"w":return d.getDay()+1;case"ww":d1=this.CreateDate(d.getFullYear(),1,1);return Math.round(this.DateDiff("d",d1,d)/7);case"h":return d.getHours();case"n":return d.getMinutes();case"s":return d.getSeconds();case"l":return d.getMilliseconds()}},DecimalFormat:function(n){return(this._commafy(n.toFixed(2)))},DollarFormat:function(n){var _n=n.toString().replace(/\$|\,/g,'');_n=_n.toString().replace('(','-');_n=_n.toString().replace(')','');if(isNaN(_n)){_n=0}var sign=(_n==(_n=Math.abs(n)));_n=Math.floor(_n*100+0.50000000001);var cents=_n%100;_n=Math.floor(_n/100).toString();if(cents<10){cents="0"+cents}_n+="."+cents;_n=this._commafy(_n);return(((sign)?'':'(')+'$'+_n+((sign)?'':')'))},Find:function(sb,s){return s.toString().indexOf(sb)+1},FindNoCase:function(sb,s){return this.Find(sb.toUpperCase(),s.toUpperCase())},HTMLCodeFormat:function(s){return'<pre>'+this.HTMLEditFormat(s)+'</pre>'},HTMLEditFormat:function(s){var my={};s+='';my.sf='';for(my.i=0;my.i<s.length;my.i++){my.c=s.slice(my.i,my.i+1);switch(my.c){case'"':my.c='&quot;';break;case'&':my.c='&amp;';break;case'>':my.c='&gt;';break;case'<':my.c='&lt;';break;default:break}my.sf+=my.c}return my.sf},Insert:function(sb,s,p){s+="";return s.slice(0,p)+sb+s.slice(p,s.length)},IsArray:function(a,dim){if(dim){nod=this._DimensionCount(a);if(nod==dim){return true}return false}if(a.constructor==Array){return true}return false},IsBoolean:function(v){if(v.constructor==Boolean){return true}return false},IsDate:function(d){var datePat=/^(\d{1,2})(\/|-)(\d{1,2})(\/|-)(\d{4})$/;var matchArray=d.toString().match(datePat);if(matchArray===null){return false}var month=matchArray[1];var day=matchArray[3];var year=matchArray[5];var isleap=(year%4===0&&(year%100!==0||year%400===0));if(month<1||month>12){return false}if(day<1||day>31){return false}if((month==4||month==6||month==9||month==11)&&day==31){return false}if(month==2){if(day>29||(day==29&&!isleap)){return false}}return true},IsDefined:function(o){if(typeof o!="undefined"){return true}return false},IsLeapYear:function(y){if((y/4)!=Math.floor(y/4)){return false}if((y/100)!=Math.floor(y/100)){return true}if((y/400)!=Math.floor(y/400)){return false}return true},IsNumeric:function(s){if(isNaN(s)){return false}return true},IsSimpleValue:function(v){if(this.IsString(v)){return true}if(this.IsNumeric(v)){return true}if(this.IsBoolean(v)){return true}if(this.IsDate(v)){return true}return false},IsString:function(s){if(s.constructor==String){return true}return false},IsStruct:function(s){if(s.constructor==Object){return true}return false},IsValid:function(t,v,r,m){t=t.toLowerCase();switch(t){case"any":return this.IsSimpleValue(v);case"array":return this.IsArray(v);case"date":return this.IsDate(v);case"boolean":return this.IsBoolean(v);case"email":return this.IsValid("regex",v,/(^[a-z]([a-z_\.]*)@([a-z_\.]*)([.][a-z]{2,4})$)/i);case"eurodate":return this.IsDate(v);case"float":return this.IsNumeric(v);case"guid":return this.IsValid("regex",v,/(^[0-9-a-fA-F]{8}-([0-9-a-fA-F]{4}-){3}[0-9-a-fA-F]{12}$)/);case"integer":return this.IsValid("regex",v,/(^-?\d\d*$)/);case"numeric":return this.IsNumeric(v);case"range":return(((v*1)>=r)&&((v*1)<=m))?true:false;case"regex":return v.toString().match(r)?true:false;case"regular_expression":return this.IsValid("regex",v,r);case"social_security_number":return this.IsValid("ssn",v);case"ssn":return this.IsValid("regex",v,/^([0-6]\d{2}|7[0-6]\d|77[0-2])([ \-]?)(\d{2})\2(\d{4})$/);case"string":return this.IsString(v);case"struct":return this.IsStruct(v);case"telephone":return this.IsValid("regex",v,/^(\([1-9]\d{2}\)\s?|[1-9]\d{2}[\.\-])?\d{3}[\.\-]\d{4}$/);case"time":return this.IsDate(v);case"url":return this.IsValid("regex",v,/(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i);case"uuid":return this.IsValid("regex",v,/(^[0-9-a-fA-F]{8}-([0-9-a-fA-F]{4}-){2}[0-9-a-fA-F]{15}$)/);case"variablename":return this.IsValid("regex",v,/(^[a-zA-Z_][0-9a-zA-Z_]*$)/);case"zipcode":return this.IsValid("regex",v,/(^\d{5}$)|(^\d{5}-\d{4}$)/);case"creditcard":if(!this.IsValid("range",v.length,13,16)){return false}var sum=0;var i,digit;for(i=(2-(v.length%2));i<=v.length;i+=2){sum+=parseInt(v.charAt(i-1),10)}for(i=(v.length%2)+1;i<v.length;i+=2){digit=parseInt(v.charAt(i-1),10)*2;sum+=(digit<10)?digit:(digit-9)}return((sum%10)===0)?true:false}},LCase:function(s){s+="";return s.toLowerCase()},Left:function(s,c){s+="";return s.slice(0,c)},Len:function(s){s+="";return s.length},ListAppend:function(l,v,d){l+="";if(!d){d=","}var r="";if(this.ListLen(l)){r=l+d+v}else{r=v}return r},ListChangeDelims:function(l,nd,od){l+="";if(!od){od=","}var spc="^,$,|,.,+,*,?,\,/";if(this.ListFind(spc,od)){od="\\"+od}var re=new RegExp(od,"gi");return l.replace(re,nd)},ListContains:function(l,sb,d){l+="";if(!d){d=","}var spc="^,$,|,.,+,*,?,\,/";if(this.ListFind(spc,sb)){sb="\\"+sb}l=l.split(d);var re=new RegExp(sb,"g");for(var i=0;i<l.length;i++){if(re.test(l[i])){return true}}return false},ListContainsNoCase:function(l,sb,d){l+="";if(!d){d=","}var spc="^,$,|,.,+,*,?,\,/";if(this.ListFind(spc,sb)){sb="\\"+sb}l=l.split(d);var re=new RegExp(sb,"gi");for(var i=0;i<l.length;i++){if(re.test(l[i])){return true}}return false},ListDeleteAt:function(l,p,d){l+="";if(!d){d=","}var i,posInList;var posInArray=p-1;var thisD="";var r="";for(i=0;i<l.split(d).length;i++){if(i!=posInArray){posInList=i+1;if(r.length){thisD=d}r+=thisD+this.ListGetAt(l,posInList,d)}}return r},ListFind:function(l,v,d){l+="";if(!d){d=","}var r=0;var listToArray=l.split(d);for(var i=0;i<listToArray.length;i++){if(listToArray[i]==v){r=i+1;break}}return r},ListFindNoCase:function(l,v,d){l+="";if(!d){d=","}return this.ListFind(l.toUpperCase(),v.toUpperCase(),d)},ListFirst:function(l,d){l+="";if(!d){d=","}return l.split(d)[0]},ListGetAt:function(l,p,d){l+="";if(!d){d=","}return l.split(d)[p-1]},ListInsertAt:function(l,p,v,d){var a;l+="";if(!d){d=","}l=l.split(d);if(p===0){l.unshift(v)}else{a=l.splice(p);l.push(v);l=l.concat(a)}return this.ListChangeDelims(l.toString(),d,",")},ListLast:function(l,d){l+="";if(!d){d=","}l=l.split(d);return l[l.length-1]},ListLen:function(l,d){l+="";if(!d){d=","}if(l.length){return l.split(d).length}return 0},ListPrepend:function(l,v,d){l+="";if(!d){d=","}var r="";if(this.ListLen(l)){r=v+d+l}else{r=v}return r},ListRest:function(l,d){l+="";if(!d){d=","}l=l.split(d);l.splice(0,1);l=(l.length)?this.ArrayToList(l,d):"";return l},ListSetAt:function(l,p,v,d){l+="";if(!d){d=","}l=l.split(d);l[p-1]=v;return this.ListChangeDelims(l.toString(),d,",")},ListSort:function(l,st,so,d){l+="";if(!d){d=","}l=l.split(d);l=this.ArraySort(l,st,so);return this.ListChangeDelims(l.toString(),d,",")},ListToArray:function(l,d){l+="";var r,a,i;if(!d){d=","}r=[];a=l.split(d);return a},ListValueCount:function(l,v,d){var c=0;l+="";if(!d){d=","}l=l.split(d);for(var i=0;i<l.length;i++){if(l[i]==v){c++}}return c},ListValueCountNoCase:function(l,v,d){var c=0;l+="";if(!d){d=","}l=l.split(d);for(var i=0;i<l.length;i++){if(l[i].toUpperCase()==v.toUpperCase()){c++}}return c},LTrim:function(s){s+="";if(s.length){return s.replace(/^\s*/,'')}return''},Mid:function(s,start,c){s+="";start-=1;return s.slice(start,start+c)},Pad:function(s,n,pc,pd){if(arguments.length<=3){pd="R"}if(arguments.length<=2){pc=" "}if(arguments.length<=1){n=10}if(arguments.length===0){s=""}var sl=s.length;var pl=n-sl;if(sl>=n){return s}if(pd=="R"||pd=="Right"){return s+this.RepeatString(pc,pl)}return this.RepeatString(pc,pl)+s},Param:function(n,d){if(!this.IsDefined(n)){if(this.IsString(d)){eval("var "+n+" = '"+d+"';")}else{eval("var "+n+" = "+d+";")}}},RepeatString:function(s,n){var rs="";for(var i=1;i<=n;i++){rs+=s}return rs},Replace:function(s,sb1,sb2,sc){s+="";if(!sc||sc.toUpperCase()!="ALL"){sc=""}else{sc="g"}var re=new RegExp(sb1,sc);return s.replace(re,sb2)},ReplaceNoCase:function(s,sb1,sb2,sc){s+="";if(!sc||sc.toUpperCase()!="ALL"){sc="i"}else{sc="gi"}var re=new RegExp(sb1,sc);return s.replace(re,sb2)},Reverse:function(s){s+="";var i=s.length;var r="";for(i;0<=i;i--){r+=s.charAt(i)}return r},Right:function(s,c){s+="";return s.slice(s.length-c,s.length)},Round:function(n,p){if(!isNaN(n.toFixed(p))){return n.toFixed(p)}return n},RTrim:function(s){s+="";if(s.length){return s.replace(/\s*$/,'')}return''},StructKeyArray:function(s){var k;var a=[];for(k in s){a.push(k)}return a},StructKeyExists:function(s,k){return!!s[k]},StructKeyList:function(s,d){var k;var a="";if(!d){d=","}for(k in s){a=this.ListAppend(a,k,d)}return a},TimeFormat:function(t,m){return this.DateFormat(t,m)},Trim:function(s){s+="";if(s.length){return s.replace(/^\s\s*/,'').replace(/\s\s*$/,'')}return''},UCase:function(s){return s.toString().toUpperCase()},URLDecode:function(s){return unescape(s)},URLEncodedFormat:function(s){return encodeURI(s)}});/*
 * jQuery Calculation Plug-in
 *
 * Copyright (c) 2011 Dan G. Switzer, II
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 * Revision: 13
 * Version: 0.4.09
 *
*/
(function($){var defaults={reNumbers:/(-?\$?)(\d+(,\d{3})*(\.\d{1,})?|\.\d{1,})/g,cleanseNumber:function(v){return v.replace(/[^0-9.\-]/g,"")},useFieldPlugin:(!!$.fn.getValue),onParseError:null,onParseClear:null};$.Calculation={version:"0.4.09",setDefaults:function(options){$.extend(defaults,options)}};$.fn.parseNumber=function(options){var aValues=[];options=$.extend(options,defaults);this.each(function(){var $el=$(this),sMethod=($el.is(":input")?(defaults.useFieldPlugin?"getValue":"val"):"text"),v=$.trim($el[sMethod]()).match(defaults.reNumbers,"");if(v==null){v=0;if(jQuery.isFunction(options.onParseError))options.onParseError.apply($el,[sMethod]);$.data($el[0],"calcParseError",true)}else{v=options.cleanseNumber.apply(this,[v[0]]);if($.data($el[0],"calcParseError")&&jQuery.isFunction(options.onParseClear)){options.onParseClear.apply($el,[sMethod]);$.data($el[0],"calcParseError",false)}}aValues.push(parseFloat(v,10))});return aValues};$.fn.calc=function(expr,vars,cbFormat,cbDone){var $this=this,exprValue="",precision=0,$el,parsedVars={},tmp,sMethod,_,bIsError=false;for(var k in vars){expr=expr.replace((new RegExp("("+k+")","g")),"_.$1");if(!!vars[k]&&!!vars[k].jquery){parsedVars[k]=vars[k].parseNumber()}else{parsedVars[k]=vars[k]}}this.each(function(i,el){var p,len;$el=$(this);sMethod=($el.is(":input")?(defaults.useFieldPlugin?"setValue":"val"):"text");_={};for(var k in parsedVars){if(typeof parsedVars[k]=="number"){_[k]=parsedVars[k]}else if(typeof parsedVars[k]=="string"){_[k]=parseFloat(parsedVars[k],10)}else if(!!parsedVars[k]&&(parsedVars[k]instanceof Array)){tmp=(parsedVars[k].length==$this.length)?i:0;_[k]=parsedVars[k][tmp]}if(isNaN(_[k]))_[k]=0;p=_[k].toString().match(/\.\d+$/gi);len=(p)?p[0].length-1:0;if(len>precision)precision=len}try{exprValue=eval(expr);if(precision)exprValue=Number(exprValue.toFixed(Math.max(precision,4)));if(jQuery.isFunction(cbFormat)){var tmp=cbFormat.apply(this,[exprValue]);if(!!tmp)exprValue=tmp}}catch(e){exprValue=e;bIsError=true}$el[sMethod](exprValue.toString())});if(jQuery.isFunction(cbDone))cbDone.apply(this,[this]);return this};$.each(["sum","avg","min","max"],function(i,method){$.fn[method]=function(bind,selector){if(arguments.length==0)return math[method](this.parseNumber());var bSelOpt=selector&&(selector.constructor==Object)&&!(selector instanceof jQuery);var opt=bind&&bind.constructor==Object?bind:{bind:bind||"keyup",selector:(!bSelOpt)?selector:null,oncalc:null};if(bSelOpt)opt=jQuery.extend(opt,selector);if(!!opt.selector)opt.selector=$(opt.selector);var self=this,sMethod,doCalc=function(){var value=math[method](self.parseNumber(opt));if(!!opt.selector){sMethod=(opt.selector.is(":input")?(defaults.useFieldPlugin?"setValue":"val"):"text");opt.selector[sMethod](value.toString())}if(jQuery.isFunction(opt.oncalc))opt.oncalc.apply(self,[value,opt])};doCalc();return self.bind(opt.bind,doCalc)}});var math={sum:function(a){var total=0,precision=0;$.each(a,function(i,v){var p=v.toString().match(/\.\d+$/gi),len=(p)?p[0].length-1:0;if(len>precision)precision=len;total+=v});if(precision)total=Number(total.toFixed(precision));return total},avg:function(a){return math.sum(a)/a.length},min:function(a){return Math.min.apply(Math,a)},max:function(a){return Math.max.apply(Math,a)}}})(jQuery);/*
 * jQuery Variable Debugger Plugin 1.0
 *
 * http://andygroff.com/jquery-debugger-debugging-plugin/
 * http://plugins.jquery.com/project/VariableDebugger
 *
 * Copyright (c) 2010 - 2012 Andrew Groff (http://andygroff.com)
 *
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */

(function($) {
  $.fn.closeDebugger = function(divId) {
    $("#"+divId).remove();
  }
  $.debug = function(variable, options) {
    // define defaults and override with options, if available
    // by extending the default settings, we don't modify the argument
    var settings = $.extend({
      divId: "debugDiv",
      divCss: {
        "border": "1px solid #AAA",
        "background": "#FFF",
        "padding": "15px",
        "width": "70%",
        "position": "absolute",
        "top": "60px",
        "left": "10%",
        "z-index": "2000",
        "color:": "#444"
      },
      spanId: "debugSpanTitle",
      spanText: "Object Properties",
      objectInfoId: "debugObjectInfo",
      recursive: true
    }, options);

    var vars = {
      debugContainer: $('<div style="text-align:left;" id="'+settings.divId+
        '" ><span id="'+settings.spanId+
        '">'+settings.spanText+
        '</span>'+
        '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+
        '<a href="javascript:void(0);" onclick="$().closeDebugger(\''+settings.divId+'\');">Close</a>'+
        '<hr /><div id="'+settings.objectInfoId+
        '"></div></div>')
    }

      var object = variable;
      if(variable == undefined){
        object = this;
        settings.recursive = false;
      }
      printDebug(object);

    function typeOf(value) {
      var s = typeof value;
      if (s === 'object') {
        if (value) {
          if (typeof value.length === 'number' &&
            !(value.propertyIsEnumerable('length')) &&
            typeof value.splice === 'function') {
            s = 'array';
          }
        } else {
          s = 'null';
        }
      }
      return s;
    }


    function printDebug(obj){
      //create the div to display debuggable object
      createDebugDiv();
      //get object html
      var html = getObjectHtml(obj);
      //set little div to object html
      $("#"+settings.objectInfoId).html(html);
    }

    function createDebugDiv(){
      //remove all existing debugDivs
      $("#"+settings.divId).remove();
      //apply css
      $(vars.debugContainer).css(settings.divCss);
      $('body').append(vars.debugContainer);
    }

    function getObjectHtml(obj){
      var html = "";
      var br   = "<br />";
      //html += obj.innerHTML+br;
      if(obj.innerHTML != undefined){
        html += doHtmlElementHtml(obj);
        return html;
      }
      else if(typeof obj == "string" ){
        html += "String: "+obj+br;
        return html;
      }
      else if(typeof obj == "number" ){
        html += "Number: "+obj+br;
        return html;
      }
      else if(typeof obj == "boolean" ){
        html += "Boolean: "+obj+br;
        return html;
      }
      else if(obj instanceof Function){
        html += formatFunction(obj);
      }
      for (var prop in obj) {
        if(prop != "prototype"){
          
          if(obj[prop] instanceof Array && settings.recursive){
            html += doArrayHtml(obj, prop);
          }
          else if(obj[prop] instanceof Function && settings.recursive){
            html += doFunctionHtml(obj, prop);
          }
          else if(obj[prop] instanceof Object && settings.recursive){
            html += doObjectHtml(obj, prop);
          }
          else{
            html += "<span style=\"display:block;\">"+prop+": "+obj[prop]+"</span>";
          }
        }
      }
      return html;
    }

    function doHtmlElementHtml(obj){
      var html = "";
      var currentElement = "";
      var desiredElements = new Array(
        "tagName",
        "className",
        "id",
        "title",
        "tabIndex",
        "align",
        "scrollWidth",
        "clientLeft",
        "clientHeight",
        "clientWidth",
        "clientTop",
        "innerHTML",
        "textContent"
        );
      for(var prop in desiredElements){
        currentElement = desiredElements[prop];
        html += "<span style=\"display:block\">"+currentElement+": "+obj[currentElement]+"</span>";
      }
      return html;
    }

    function doArrayHtml(obj, prop){
      var id= getUniqueId(prop);
      return '<a href="javascript:void(0);" style="display:block;" onclick="$(\'#'+id+'\').toggle();">Array: '+
      prop+'...</a><div style="display:none;padding-left:15px;" id="'+id+
      '">'+getObjectHtml(obj[prop])+'</div>';
    }

    function doFunctionHtml(obj, prop){
      var id= getUniqueId(prop);
      return '<a href="javascript:void(0);" style="display:block;" onclick="$(\'#'+id+'\').toggle();">Function: '+
      prop+'...</a><div style="display:none;padding-left:15px;" id="'+id+
      '">'+formatFunction(obj[prop])+'</div>';
    }

    function doObjectHtml(obj, prop){
      var id= getUniqueId(prop);
      return '<a href="javascript:void(0);" style="display:block;" onclick="$(\'#'+id+'\').toggle();">Object: '+
      prop+'...</a><div style="display:none;padding-left:15px;" id="'+id+
      '">'+getObjectHtml(obj[prop])+'</div>';
    }

    function getUniqueId(property){
      var t = new Date();
      var randomnumber = Math.floor(Math.random()*110)
      return "div"+property+"-"+t.getTime()+randomnumber;
    }

    function formatFunction(str){
      return "<pre>"+str+"</pre>";
    }

  }
})(jQuery);

/*
 * jQuery Impromptu
 * By: Trent Richardson [http://trentrichardson.com]
 * Version 3.1
 * Last Modified: 3/30/2010
 * 
 * Copyright 2010 Trent Richardson
 * Dual licensed under the MIT and GPL licenses.
 * http://trentrichardson.com/Impromptu/GPL-LICENSE.txt
 * http://trentrichardson.com/Impromptu/MIT-LICENSE.txt
 * 
 */
(function($){$.prompt=function(message,options){options=$.extend({},$.prompt.defaults,options);$.prompt.currentPrefix=options.prefix;var ie6=($.browser.msie&&$.browser.version<7);var $body=$(document.body);var $window=$(window);options.classes=$.trim(options.classes);if(options.classes!='')options.classes=' '+options.classes;var msgbox='<div class="'+options.prefix+'box'+options.classes+'" id="'+options.prefix+'box">';if(options.useiframe&&(($('object, applet').length>0)||ie6)){msgbox+='<iframe src="javascript:false;" style="display:block;position:absolute;z-index:-1;" class="'+options.prefix+'fade" id="'+options.prefix+'fade"></iframe>';}else{if(ie6){$('select').css('visibility','hidden');}msgbox+='<div class="'+options.prefix+'fade" id="'+options.prefix+'fade"></div>';}msgbox+='<div class="'+options.prefix+'" id="'+options.prefix+'"><div class="'+options.prefix+'container"><div class="';msgbox+=options.prefix+'close">X</div><div id="'+options.prefix+'states"></div>';msgbox+='</div></div></div>';var $jqib=$(msgbox).appendTo($body);var $jqi=$jqib.children('#'+options.prefix);var $jqif=$jqib.children('#'+options.prefix+'fade');if(message.constructor==String){message={state0:{html:message,buttons:options.buttons,focus:options.focus,submit:options.submit}};}var states="";$.each(message,function(statename,stateobj){stateobj=$.extend({},$.prompt.defaults.state,stateobj);message[statename]=stateobj;states+='<div id="'+options.prefix+'_state_'+statename+'" class="'+options.prefix+'_state" style="display:none;"><div class="'+options.prefix+'message">'+stateobj.html+'</div><div class="'+options.prefix+'buttons">';$.each(stateobj.buttons,function(k,v){if(typeof v=='object')states+='<button name="'+options.prefix+'_'+statename+'_button'+v.title.replace(/[^a-z0-9]+/gi,'')+'" id="'+options.prefix+'_'+statename+'_button'+v.title.replace(/[^a-z0-9]+/gi,'')+'" value="'+v.value+'">'+v.title+'</button>';else states+='<button name="'+options.prefix+'_'+statename+'_button'+k+'" id="'+options.prefix+'_'+statename+'_button'+k+'" value="'+v+'">'+k+'</button>';});states+='</div></div>';});$jqi.find('#'+options.prefix+'states').html(states).children('.'+options.prefix+'_state:first').css('display','block');$jqi.find('.'+options.prefix+'buttons:empty').css('display','none');$.each(message,function(statename,stateobj){var $state=$jqi.find('#'+options.prefix+'_state_'+statename);$state.children('.'+options.prefix+'buttons').children('button').click(function(){var msg=$state.children('.'+options.prefix+'message');var clicked=stateobj.buttons[$(this).text()];if(clicked==undefined){for(var i in stateobj.buttons)if(stateobj.buttons[i].title==$(this).text())clicked=stateobj.buttons[i].value;}if(typeof clicked=='object')clicked=clicked.value;var forminputs={};$.each($jqi.find('#'+options.prefix+'states :input').serializeArray(),function(i,obj){if(forminputs[obj.name]===undefined){forminputs[obj.name]=obj.value;}else if(typeof forminputs[obj.name]==Array||typeof forminputs[obj.name]=='object'){forminputs[obj.name].push(obj.value);}else{forminputs[obj.name]=[forminputs[obj.name],obj.value];}});var close=stateobj.submit(clicked,msg,forminputs);if(close===undefined||close){removePrompt(true,clicked,msg,forminputs);}});$state.find('.'+options.prefix+'buttons button:eq('+stateobj.focus+')').addClass(options.prefix+'defaultbutton');});var ie6scroll=function(){$jqib.css({top:$window.scrollTop()});};var fadeClicked=function(){if(options.persistent){var i=0;$jqib.addClass(options.prefix+'warning');var intervalid=setInterval(function(){$jqib.toggleClass(options.prefix+'warning');if(i++>1){clearInterval(intervalid);$jqib.removeClass(options.prefix+'warning');}},100);}else{removePrompt();}};var keyPressEventHandler=function(e){var key=(window.event)?event.keyCode:e.keyCode;if(key==27){fadeClicked();}if(key==9){var $inputels=$(':input:enabled:visible',$jqib);var fwd=!e.shiftKey&&e.target==$inputels[$inputels.length-1];var back=e.shiftKey&&e.target==$inputels[0];if(fwd||back){setTimeout(function(){if(!$inputels)return;var el=$inputels[back===true?$inputels.length-1:0];if(el)el.focus();},10);return false;}}};var positionPrompt=function(){$jqib.css({position:(ie6)?"absolute":"fixed",height:$window.height(),width:"100%",top:(ie6)?$window.scrollTop():0,left:0,right:0,bottom:0});$jqif.css({position:"absolute",height:$window.height(),width:"100%",top:0,left:0,right:0,bottom:0});$jqi.css({position:"absolute",top:options.top,left:"50%",marginLeft:(($jqi.outerWidth()/2)*-1)});};var stylePrompt=function(){$jqif.css({zIndex:options.zIndex,display:"none",opacity:options.opacity});$jqi.css({zIndex:options.zIndex+1,display:"none"});$jqib.css({zIndex:options.zIndex});};var removePrompt=function(callCallback,clicked,msg,formvals){$jqi.remove();if(ie6){$body.unbind('scroll',ie6scroll);}$window.unbind('resize',positionPrompt);$jqif.fadeOut(options.overlayspeed,function(){$jqif.unbind('click',fadeClicked);$jqif.remove();if(callCallback){options.callback(clicked,msg,formvals);}$jqib.unbind('keypress',keyPressEventHandler);$jqib.remove();if(ie6&&!options.useiframe){$('select').css('visibility','visible');}});};positionPrompt();stylePrompt();if(ie6){$window.scroll(ie6scroll);}$jqif.click(fadeClicked);$window.resize(positionPrompt);$jqib.bind("keydown keypress",keyPressEventHandler);$jqi.find('.'+options.prefix+'close').click(removePrompt);$jqif.fadeIn(options.overlayspeed);$jqi[options.show](options.promptspeed,options.loaded);$jqi.find('#'+options.prefix+'states .'+options.prefix+'_state:first .'+options.prefix+'defaultbutton').focus();if(options.timeout>0)setTimeout($.prompt.close,options.timeout);return $jqib;};$.prompt.defaults={prefix:'jqi',classes:'',buttons:{Ok:true},loaded:function(){},submit:function(){return true;},callback:function(){},opacity:0.6,zIndex:999,overlayspeed:'slow',promptspeed:'fast',show:'fadeIn',focus:0,useiframe:false,top:"15%",persistent:true,timeout:0,state:{html:'',buttons:{Ok:true},focus:0,submit:function(){return true;}}};$.prompt.currentPrefix=$.prompt.defaults.prefix;$.prompt.setDefaults=function(o){$.prompt.defaults=$.extend({},$.prompt.defaults,o);};$.prompt.setStateDefaults=function(o){$.prompt.defaults.state=$.extend({},$.prompt.defaults.state,o);};$.prompt.getStateContent=function(state){return $('#'+$.prompt.currentPrefix+'_state_'+state);};$.prompt.getCurrentState=function(){return $('.'+$.prompt.currentPrefix+'_state:visible');};$.prompt.getCurrentStateName=function(){var stateid=$.prompt.getCurrentState().attr('id');return stateid.replace($.prompt.currentPrefix+'_state_','');};$.prompt.goToState=function(state,callback){$('.'+$.prompt.currentPrefix+'_state').slideUp('slow');$('#'+$.prompt.currentPrefix+'_state_'+state).slideDown('slow',function(){$(this).find('.'+$.prompt.currentPrefix+'defaultbutton').focus();if(typeof callback=='function')callback();});};$.prompt.nextState=function(callback){var $next=$('.'+$.prompt.currentPrefix+'_state:visible').next();$('.'+$.prompt.currentPrefix+'_state').slideUp('slow');$next.slideDown('slow',function(){$next.find('.'+$.prompt.currentPrefix+'defaultbutton').focus();if(typeof callback=='function')callback();});};$.prompt.prevState=function(callback){var $next=$('.'+$.prompt.currentPrefix+'_state:visible').prev();$('.'+$.prompt.currentPrefix+'_state').slideUp('slow');$next.slideDown('slow',function(){$next.find('.'+$.prompt.currentPrefix+'defaultbutton').focus();if(typeof callback=='function')callback();});};$.prompt.close=function(){$('#'+$.prompt.currentPrefix+'box').fadeOut('fast',function(){$(this).remove();});};$.fn.prompt=function(options){if(options==undefined)options={};if(options.withDataAndEvents==undefined)options.withDataAndEvents=false;$.prompt($(this).clone(options.withDataAndEvents).html(),options);}})(jQuery);
/*
<SCRIPT SRC="/Script/javascript/math_functions.js"></SCRIPT>
*/

function removeExponentialFormatting(iVal, decimalLen)
{
	var returnString = iVal;
	var sStr = iVal + "";
	if(arguments.length < 2)
	{
		decimalLen = 2;
	}
	//1.6393442622950821e+25
	var sAr = sStr.split(".");
	if(sAr.length > 1)
	{
		returnString = sAr[0];
		sStr = sAr[1];
		sAr = sStr.split("e+");
			var expPart2;
			var expPart1 = sAr[0];
			if(sAr.length > 1)
			{
				expPart2 = parseInt(sAr[1], 10);
			}
			else
			{
				expPart2 = 0;
			}
			
			returnString = returnString + PadString(expPart1, expPart2 + decimalLen, "0", false);
			returnString2 = returnString;
			var nonDecimalPart = returnString.substr(0, returnString.length - decimalLen);
			var decimalPart = returnString.substr(returnString.length - decimalLen);
			returnString1 = returnString;
			returnString = nonDecimalPart + "." + decimalPart;
			
		
	}
	return returnString;
}


function addNumbers() {
	var total = 0, precision = 0;
      
  // loop through the value and total them
  for (var i = 0; i < arguments.length; i++) {
        // check for decimals and check the precision
        var p = arguments[i].toString().match(/\.\d+$/gi), len = (p) ? p[0].length-1 : 0;
        // track the highest level of precision
        if( len > precision ) 
        	precision = len; 
        // we add 0 to the value to ensure we get a numberic value
        total += arguments[i];
  }
  
  // fix any the precision errors
  if( precision ) 
  	total = Number(total.toFixed(precision));
  
  return total;
}
function keepHeaderFixed(topPosition,leftPosition)
{
	var top_position = topPosition + 'px';
	var left_position = leftPosition + 'px';

	$(".headerTop").css({top: top_position }); 
	$(".headerTopAndLeft").css({top: top_position }); 

	$(".headerLeft").css({left: left_position }); 
	$(".headerTopAndLeft").css({left: left_position }); 
}