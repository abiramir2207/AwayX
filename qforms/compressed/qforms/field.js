function _Field_makeContainer(bindTo){lstContainers=(arguments.length==0)? this.name : this.name+","+arguments[0];
this.container=true;
this.defaultValue=this.getValue();
this.lastValue=this.defaultValue;
this.dummyContainer=false;
this.boundContainers=_listToArray(lstContainers.toLowerCase());
var thisKey=this.qForm._name+"_"+this.name.toLowerCase();
qFormAPI.containers[thisKey]=new Object();
for(var i=0;i<this.obj.options.length;i++){qFormAPI.containers[thisKey][this.obj.options[i].value]=this.obj.options[i].text;
}}
Field.prototype.makeContainer=_Field_makeContainer;
function _Field_resetLast(){this.setValue(this.lastValue);
return true;
}
Field.prototype.resetLast=_Field_resetLast;
function _Field_toUpperCase(){this.setValue(this.getValue().toUpperCase());
return true;
}
Field.prototype.toUpperCase=_Field_toUpperCase;
function _Field_toLowerCase(){this.setValue(this.getValue().toLowerCase());
return true;
}
Field.prototype.toLowerCase=_Field_toLowerCase;
function _Field_ltrim(){this.setValue(_ltrim(this.getValue()));
return true;
}
Field.prototype.ltrim=_Field_ltrim;
function _Field_rtrim(){this.setValue(_rtrim(this.getValue()));
return true;
}
Field.prototype.rtrim=_Field_rtrim;
function _Field_trim(){this.setValue(_trim(this.getValue()));
return true;
}
Field.prototype.trim=_Field_trim;
function _Field_compare(field){if(this.getValue()==this.qForm[field].getValue()){return true;
} else{return false;
}
return true;
}
Field.prototype.compare=_Field_compare;
function _Field_mirrorTo(objName){isQForm=(objName.indexOf(".")>-1)?!eval("!objName.substring(0,objName.indexOf('.'))"): false;
if(isQForm){var strCommand=objName+".setValue("+this.pointer+".getValue()"+");";
} else{var strCommand=objName+" = "+this.pointer+".getValue();";
}
this.addEvent(_getEventType(this.type), strCommand, false);
}
Field.prototype.mirrorTo=_Field_mirrorTo;
function _Field_createDependencyTo(field, condition){var condition=(arguments.length>1)? "\"" + arguments[1] + "\"" : null;
var otherField=this.qForm._pointer+"['"+field+"']";
if(!eval(otherField))return alert("The "+field+" field does not exist. The dependency \nto "+this.name+" can not be created.");
if(this.qForm[field]._queue.dependencies.length==0)this.qForm[field].addEvent(_getEventType(this.name), otherField+".enforceDependency();", false);
this.qForm[field]._queue.dependencies[this.qForm[field]._queue.dependencies.length]=otherField+".isDependent('"+this.name+"', "+condition+");";
return true;
}
Field.prototype.createDependencyTo=_Field_createDependencyTo;
function _Field_isDependent(field, condition){var condition=_param(arguments[1], null);
this.value=this.getValue();
if(condition==null){var result=(this.isNotEmpty()|| this.required);
} else{if(condition.indexOf("this.")>-1 || condition=="true" || condition=="false"){var result=eval(condition);
} else{var result=(this.value==condition);
}}
var o=null;
o=new Object();
o.field=field;
o.result=result;
return o;
}
Field.prototype.isDependent=_Field_isDependent;
function _Field_enforceDependency(e){var lstExcludeFields=_param(arguments[0], ",");
var lstFieldsChecked=",";
var lstFieldsRequired=",";
for(var i=0;i<this._queue.dependencies.length;i++){var s=eval(this._queue.dependencies[i]);
if(lstFieldsChecked.indexOf(","+s.field+",")==-1)lstFieldsChecked+=s.field+",";
if(s.result && lstFieldsRequired.indexOf(","+s.field+",")==-1)lstFieldsRequired+=s.field+",";
}
aryFieldsChecked=lstFieldsChecked.split(",");
for(var j=1;j<aryFieldsChecked.length-1;j++){var result=(lstFieldsRequired.indexOf(","+aryFieldsChecked[j]+",")>-1);
this.qForm[aryFieldsChecked[j]].required=result;
if(lstExcludeFields.indexOf(","+aryFieldsChecked[j]+",")==-1)setTimeout(this.qForm._pointer+"."+aryFieldsChecked[j]+".enforceDependency('"+lstExcludeFields+this.name+",')", 1);
}}
Field.prototype.enforceDependency=_Field_enforceDependency;
function _Field_location(target, key){var target=_param(arguments[0], "self");
var key=_param(arguments[1]);
if(this.isLocked()|| this.isDisabled())return this.setValue(key);
var value=this.getValue();
this.setValue(key);
if(value!=key){eval(target+".location = value");
}
return true;
}
Field.prototype.location=_Field_location;
function _Field_format(mask, type){var type=_param(arguments[1], "numeric").toLowerCase();
this.validate=true;
this.validateFormat(mask, type);
}
Field.prototype.format=_Field_format;
function _Field_populate(struct, reset, sort, prefix){if(this.isLocked()|| this.isDisabled())return false;
var reset=_param(arguments[1], true, "boolean");
var sort=_param(arguments[2], false, "boolean");
var prefix=_param(arguments[3], null, "object");
if(this.type.substring(0,6)!="select")return alert("This method is only available to select boxes.");
if(reset)this.obj.length=0;
if(!!prefix)for(key in prefix)this.obj.options[this.obj.length]=new Option(prefix[key], key);
for(key in struct)this.obj.options[this.obj.length]=new Option(struct[key], key);
if(sort)_sortOptions(this.obj);
return true;
}
Field.prototype.populate=_Field_populate;
function _Field_transferTo(field, sort, type, selectItems, reset){if(this.isLocked()|| this.isDisabled())return false;
var sort=_param(arguments[1], true, "boolean");
var type=_param(arguments[2], "selected");
var selectItems=_param(arguments[3], true, "boolean");
var reset=_param(arguments[4], false, "boolean");
_transferOptions(this.obj, this.qForm[field].obj, sort, type, selectItems, reset);
return true;
}
Field.prototype.transferTo=_Field_transferTo;
function _Field_transferFrom(field, sort, type, selectItems, reset){if(this.isLocked()|| this.isDisabled())return false;
var sort=_param(arguments[1], true, "boolean");
var type=_param(arguments[2], "selected");
var selectItems=_param(arguments[3], true, "boolean");
var reset=_param(arguments[4], false, "boolean");
_transferOptions(this.qForm[field].obj, this.obj, sort, type, selectItems, reset);
return true;
}
Field.prototype.transferFrom=_Field_transferFrom;
function _Field_moveUp(){if(this.isLocked()|| this.isDisabled()|| this.type.substring(0,6)!="select")return false;
var oOptions=this.obj.options;
for(var i=1;i<oOptions.length;i++){if(oOptions[i].selected){_swapOptions(oOptions[i], oOptions[i-1]);
}}
return true;
}
Field.prototype.moveUp=_Field_moveUp;
function _Field_moveDown(){if(this.isLocked()|| this.isDisabled()|| this.type.substring(0,6)!="select")return false;
var oOptions=this.obj.options;
for(var i=oOptions.length-2;i>-1;i--){if(oOptions[i].selected){_swapOptions(oOptions[i+1], oOptions[i]);
}}
return true;
}
Field.prototype.moveDown=_Field_moveDown;
