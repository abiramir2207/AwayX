//common_js.js
function printPage()
{
	window.print();
}

function AllOpenLayers(bExpand)
{
	var allFieldsets = document.getElementsByTagName("fieldset");
	var i, FieldsetLen, thisFieldsetID, nameLast;
	var divObj, imgObj;
	FieldsetLen = allFieldsets.length;
	var checkToken = "border_";
	for(i=0;i<FieldsetLen;i++)
	{
		if(allFieldsets[i].id)
		{
			thisFieldsetID = allFieldsets[i].id;
			if(thisFieldsetID.substr(0,checkToken.length) == checkToken)
			{
				nameLast = thisFieldsetID.substr(checkToken.length,thisFieldsetID.length-checkToken.length);
				eval("divObj = allFieldsets[i].all.lyrGroup_" + nameLast);
				eval("imgObj = allFieldsets[i].all.image_" + nameLast);				
				if(bExpand == 0)
				{
					divObj.style.display = "";
				}
				else
				{
					divObj.style.display = "none";
				}
				imgObj.click();
			}
		}
	}	
}


function getParentObject(thisObj, tagName)
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

function showThisLinkPopup(thisObj,NoResize, hei, wid)
{
	var aObj = getParentObject(thisObj, "a");
	var resize = "Yes";
	var height = 600;
	var width = 800;
	if(arguments.length > 2)
	{
		height = hei;
	}
	if(arguments.length > 3)
	{
		width = wid;
	}

	if(NoResize)
	{
		resize = "No";
	}
	var winName = aObj.href.split("?")[0];
	winName = winName.split("/");
	winName = winName[winName.length - 1];
	winName = winName.split(".")[0];
	if(aObj)
	{
		//NewWindow(aObj.href, "ThisNewWindow" + Math.round(Math.random() * 100).toString(), width, height, "yes", resize);
		NewWindow(aObj.href, "ThisNewWindow" + winName, width, height, "yes", resize);		
	}
	return false;
}