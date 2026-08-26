var _c_dToday=new Date();
var _c_iExpiresIn=90;
var _c_strName=self.location.pathname;
function _getCookie(name){var iStart=document.cookie.indexOf(name+"=");
var iLength=iStart+name.length+1;
if((iStart==-1)||(!iStart &&(name==document.cookie.substring(0))))return null;
var iEnd=document.cookie.indexOf(";", iLength);
if(iEnd==-1)iEnd=document.cookie.length;
return unescape(document.cookie.substring(iLength, iEnd));
}
function _setCookie(name, value, expires, path, domain, secure){document.cookie=name+"="+escape(value)+((expires)? ";expires="+expires.toGMTString(): "")+((path)? ";path="+path : "")+((domain)? ";domain="+domain : "")+((secure)? ";secure" : "");
}
function _deleteCookie(name, path, domain){if(Get_Cookie(name))document.cookie=name+"="+((path)? ";path="+path : "")+((domain)? ";domain="+domain : "")+";expires=Thu, 01-Jan-1970 00:00:01 GMT";
}
function _createCookiePackage(struct){var cookie="";
for(key in struct){if(cookie.length>0)cookie+="&";
cookie+=key+":"+escape(struct[key]);
}
return cookie;
}
function _readCookiePackage(pkg){struct=new Object();
var a=pkg.split("&");
for(var i=0;i<a.length;i++)a[i]=a[i].split(":");
for(var i=0;i<a.length;i++)struct[a[i][0]]=unescape(a[i][1]);
return struct;
}
function _qForm_loadFields(){var strPackage=_getCookie("qForm_"+this._name+"_"+_c_strName);
if(strPackage==null)return false;
this.setFields(_readCookiePackage(strPackage), null, true);
}
qForm.prototype.loadFields=_qForm_loadFields;
function _qForm_saveFields(){var expires=new Date(_c_dToday.getTime()+(_c_iExpiresIn*86400000));
var strPackage=_createCookiePackage(this.getFields());
_setCookie("qForm_"+this._name+"_"+_c_strName, strPackage, expires);
}
qForm.prototype.saveFields=_qForm_saveFields;
function _qForm_saveOnSubmit(){var fn=_functionToString(this.onSubmit, "this.saveFields();");
this.onSubmit=new Function(fn);
}
qForm.prototype.saveOnSubmit=_qForm_saveOnSubmit;
