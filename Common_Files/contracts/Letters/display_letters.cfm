<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body onload="setfilepath();">
<cfset filepath = "#url.letterpath##url.letter_name#">
<cfinclude template="#Application.Doc_Mapping##url.letterpath##url.letter_name#">
<script>
function getParentObject(thisObj, tagName)
{
	var objProper = false;
	if(thisObj)
	{
		if(thisObj.tagName)
		{
			objProper = true;
		}
	}

	if(objProper)
	{
		if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
		{
			return thisObj;
		}
		else if(thisObj.tagName.toLowerCase() == "body")
		{
			return null;
		}
		else
		{
			return getParentObject(thisObj.parentElement, tagName);
		}
	}
	else if(thisObj)
	{
		if(thisObj.parentElement)
		{
			return getParentObject(thisObj.parentElement, tagName);
		}
	}
	return thisObj;
}

function propogateProperty(oObj, bProperty, bValue, bCheckEmpty, bInput)
{
	var i, objLen, oCells;
	//oCells = oObj.cells;
	oCells = oObj.all;
	objLen = oCells.length;
	
	var bChange;
	var checkInput = false;
	if (arguments.length > 4)
	{
		checkInput = bInput;
	}
	
	setProprtyForThisObj(oObj, bProperty, bValue, bCheckEmpty, checkInput);
	for(i=0;i<objLen;i++)
	{ 
		setProprtyForThisObj(oCells[i], bProperty, bValue, bCheckEmpty, checkInput);
	}
}

function setProprtyForThisObj(thisObj, bProperty, bValue, bCheckEmpty, checkInput)
{
	
			eval("thisObj." + bProperty + " = \"" + bValue + "\"");
	
}

function deleteThisPrice(bDelete1,fieldname)
	{	
		var deleteImg = new Image();
		deleteImg.src = "/Images/scissor.gif";
		var undodeleteImg = new Image();
		undodeleteImg.src = "/Images/undo.gif";
		var srcObj = event.srcElement;
		var trObj = getParentObject(srcObj, "tr");
		var trIndex = trObj.rowIndex;
		var bDelete = bDelete1;
		
		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";	
		if(trObj)
		{			
			if(bDelete)
			{ 
			
				trObj.height = trObj.offsetHeight;
				propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false,false, true);
				propogateProperty(trObj, "style.textDecoration", "line-through", true,false, true);				
				srcObj.title = "undo product deletion";
				srcObj.src = undodeleteImg.src;
				eval("Letters." + fieldname + ".value = 1");
			}
			else
			{
			var bgCol = "FFFFFF";
				if(trObj.rowIndex % 2 == 1)
				{
					bgCol = "C6FFC6";
				}
				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);
				
				srcObj.title = "delete this product";
				srcObj.src = deleteImg.src;
				
				propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);
				eval("Letters." + fieldname + ".value = 0");
			}
			srcObj.bDelete = !bDelete;
			trObj.bDelete = (bDelete?1:0);
		}		
		
	}
function confirmCompletion()
{
Letters.submit();
}
</script>

 <script>
 function MM_findObj(n, d) { //v4.0
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && document.getElementById) x=document.getElementById(n); return x;
}
 function MM_showHideLayers() { //v3.0
  hide_allLayers();
  var i,p,v,obj,args=MM_showHideLayers.arguments;
  for (i=0; i<(args.length-2); i+=3) if ((obj=MM_findObj(args[i]))!=null) { v=args[i+2];
    if (obj.style) { obj=obj.style; v=(v=='show')?'visible':(v='hide')?'hidden':v; }
    obj.visibility=v; }
}
function hide_allLayers() {
var length = document.getElementsByTagName('div').length;
for (i=0; i<length; i++)
{ 
document.getElementsByTagName('DIV')[i].style.visibility = "hidden"; }
}
function setfilepath(){
MM_showHideLayers('submitbutton','','show');
document.all.filepath.value = <cfoutput>"#url.letterpath#"</cfoutput>;
document.all.letter_name.value = <cfoutput>"#url.letter_name#"</cfoutput>;
document.all.contractId.value = <cfoutput>"#url.contractId#"</cfoutput>;
document.all.letter_id.value = <cfoutput>"#url.letter_id#"</cfoutput>;
ShowHide('displayscisscors','inline');
if(document.all.displaycustomerproductnumber)
{
	ShowHide('displaycustomerproductnumber','inline');
}
if(document.all.Test)
{
	ShowHide('Test','none');
}
}
function ShowHide(cual,displaytype) {
var xx = eval(cual);
if (xx.length) 
	{
	for (x=0;x<xx.length;x++) 
		{
		xx[x].style.display = displaytype 
		}
	}
	else
	{
		xx.style.display = displaytype
	}
}

</script> 

</body>
</html>
