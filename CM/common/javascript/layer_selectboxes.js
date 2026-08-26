////<SCRIPT language=JavaScript1.2 src="/cm/common/javascript/layer_selectboxes.js"></SCRIPT>/////

var smallHelpArray = new Array();
var extraLeft = 123;
var extraTop = 0;
function showHideSelectBoxes(divObj)
{
	if(divObj.style.visibility == "visible")
	{
		var oDivDim = new getsmallHelpDim(divObj);
		smallHelpHideSelectBoxes(oDivDim);
	}
	else
	{
		smallHelpShowSelectBoxes();
	}
}

function smallHelpHideSelectBoxes(oDivDim)
{
	var thisObj;
	if(dropdown_names)
	{
		var i, dropdown_names_len = dropdown_names.length;
		if(dropdown_names_len)
		{
			smallHelpArray = new Array();
			for(i=0; i<dropdown_names_len; i++)
			{
				thisObj = eval('document.all.' + dropdown_names[i] + ';');
				smallHelpHideSelect(thisObj, oDivDim);
			}
		}
	}
}
function smallHelpHideSelect(oSelect, oDivDim)
{
	var oSelectDim = new getsmallHelpOffsetDim(oSelect);	
	var overlaps = false;
	//oDivDim.show();
	//oSelectDim.show();
	overlaps = overlaps || smallHelpFindInMiddle(oSelectDim, oDivDim);
	
	if(overlaps)
	{
		smallHelpArray[smallHelpArray.length] = new setSmallHelpSelectAsHidden(oSelect);
		oSelect.style.visibility = "hidden";				
	}
}

function smallHelpShowSelectBoxes()
{
	var len, i;
	len = smallHelpArray.length;
	for(i=0;i<len;i++)
	{
		smallHelpArray[i].obj.style.visibility = smallHelpArray[i].visibility;				
	}
}

function setSmallHelpSelectAsHidden(oSelect)
{
	this.obj = oSelect;
	this.visibility = oSelect.style.visibility;
}

function displayDim()
{
	oDim = this;		
	//alert(oDim.x11 + "\n" + oDim.y11 + "\n" + oDim.x12 + "\n" + oDim.y12);
	alert(oDim.x11 + "\n" + oDim.y11 + "\n" + (oDim.x12 - oDim.x11) + "\n" + (oDim.y12 - oDim.y11));
}

function getsmallHelpOffsetDim(obj)
{
	this.x11 = extraLeft + parseInt(getTotalOffsetProperty(obj, "body", "offsetLeft", 0));
	this.x11 = (isNaN(this.x11)?0:this.x11);
	var wid = parseInt(obj.offsetWidth);
	this.x12 = this.x11 + (isNaN(wid)?0:wid);
	this.y11 = extraTop + parseInt(getTotalOffsetProperty(obj, "body", "offsetTop", 0)) - document.body.scrollTop;
	this.y11 = (isNaN(this.y11)?0:this.y11);
	var hei = parseInt(obj.offsetHeight);
	this.y12 = this.y11 + (isNaN(hei)?10:hei);
	this.show = displayDim;
}

function getsmallHelpDim(obj)
{
	this.x11 = parseInt(obj.style.left);
	this.x11 = (isNaN(this.x11)?0:this.x11);
	var wid = parseInt(obj.offsetWidth);
	this.x12 = this.x11 + (isNaN(wid)?0:wid);
	this.y11 = parseInt(obj.style.top);
	this.y11 = (isNaN(this.y11)?0:this.y11);
	var hei = parseInt(obj.offsetHeight);
	this.y12 = this.y11 + (isNaN(hei)?10:hei);
	this.show = displayDim;
}

function smallHelpFindInMiddle(OBJ1, OBJ2)
{
	if(OBJ2.x11 >= OBJ1.x11 && OBJ2.x11 <= OBJ1.x12 && OBJ2.y11 <= OBJ1.y12  && OBJ2.y12 >= OBJ1.y12){
		return true;
	}
	
	if(OBJ2.x12 >= OBJ1.x11 && OBJ2.x12 <= OBJ1.x12 && OBJ2.y11 <= OBJ1.y12  && OBJ2.y12 >= OBJ1.y12){
		return true;
	}

	if(OBJ2.x11 >= OBJ1.x11 && OBJ2.x11 <= OBJ1.x12 && OBJ2.y12 <= OBJ1.y12  && OBJ2.y12 >= OBJ1.y11){
		return true;
	}

	if(OBJ2.x12 >= OBJ1.x11 && OBJ2.x12 <= OBJ1.x12 && OBJ2.y12 <= OBJ1.y12 && OBJ2.y12 >= OBJ1.y11){
		return true;
	}

	if(OBJ2.x11 <= OBJ1.x11 && OBJ2.x12 >= OBJ1.x12 && OBJ2.y11 <= OBJ1.y11 && OBJ2.y12 >= OBJ1.y12){
		return true;
	}

	if(OBJ2.x11 <= OBJ1.x11 && OBJ2.x12 >= OBJ1.x12 && OBJ2.y11 >= OBJ1.y11 && OBJ2.y11 <= OBJ1.y12){
		return true;
	}
	
	if(OBJ2.x11 <= OBJ1.x11 && OBJ2.x12 >= OBJ1.x12 && OBJ2.y12 >= OBJ1.y11 && OBJ2.y12 <= OBJ1.y12){
		return true;
	}
	return false;
}