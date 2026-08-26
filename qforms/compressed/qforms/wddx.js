function __serializeStruct(struct){var aWDDX=new Array("<wddxPacket version='1.0'><header/><data><struct>");
for(key in struct)aWDDX[aWDDX.length]="<var name='"+key+"'><string>"+__wddxValue(struct[key])+"</string></var>";
aWDDX[aWDDX.length]="</struct></data></wddxPacket>";
return aWDDX.join("");
}
function __wddxValue(str){var aValue=new Array();
for(var i=0;i<str.length;++i)aValue[aValue.length]=_encoding.table[str.charAt(i)];
return aValue.join("");
}
function _wddx_Encoding(){var et=new Array();
var n2c=new Array();
for(var i=0;i<256;++i){var d1=Math.floor(i/64);
var d2=Math.floor((i%64)/8);
var d3=i%8;
var c=eval("\"\\" + d1.toString(10) + d2.toString(10) + d3.toString(10) + "\"");
n2c[i]=c;
if(i<32 && i!=9 && i!=10 && i!=13){var hex=i.toString(16);
if(hex.length==1)hex="0"+hex;
et[n2c[i]]="<char code='"+hex+"'/>";
} else if(i<128){et[n2c[i]]=n2c[i];
} else{et[n2c[i]]="&#x"+i.toString(16)+";";
}}
et["<"]="&lt;";
et[">"]="&gt;";
et["&"]="&amp;";
this.table=et;
}
_encoding=new _wddx_Encoding();
function _a_serialize(exclude){var lstExclude=(arguments.length>0)? ","+_removeSpaces(arguments[0])+"," : "";
struct=new Object();
stcAllFields=qFormAPI.getFields();
for(key in stcAllFields){if(lstExclude.indexOf(","+key+",")==-1)struct[key]=stcAllFields[key];
}
return __serializeStruct(struct);
}
_a.prototype.serialize=_a_serialize;
function _q_serialize(exclude){var lstExclude=(arguments.length>0)? ","+_removeSpaces(arguments[0])+"," : "";
struct=new Object();
for(var j=0;j<this._fields.length;j++){if(lstExclude.indexOf(","+this._fields[j]+",")==-1)struct[this._fields[j]]=this[this._fields[j]].getValue();
}
return __serializeStruct(struct);
}
qForm.prototype.serialize=_q_serialize;
