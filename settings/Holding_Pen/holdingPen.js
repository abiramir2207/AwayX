// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataForm(action,compId)
{	
	var actionFrm = document.DataForm;
		
	//if action is edit set the compId hidden value, then reset the action to the existing state
	if (action == "edit")
	{
		actionFrm.compId.value = compId;
		actionFrm.returnTo.value = actionFrm.display.value;
	}
		
	actionFrm.display.value = action;
	actionFrm.submit();
	return false;
}

 
///////////////////////////////////   Select All Checkboxes //////////////////////////////////////////
function selectAll(thisObj)
{
	var chObjs = document.all.CID;
	var bCheck = thisObj.checked;
	var i;
	if(chObjs)
	{
		if(chObjs.length)
		{
			for(i=0;i<chObjs.length;i++)
			{
				chObjs[i].checked = bCheck;
			}
		}
		else
		{
			chObjs.checked = bCheck;
		}
	}
}
 
function PopupCenter(url, title, w, h) 
{
    // Fixes dual-screen position                         Most browsers      Firefox
    var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : screen.left;
    var dualScreenTop = window.screenTop != undefined ? window.screenTop : screen.top;

    width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    var left = ((width / 2) - (w / 2)) + dualScreenLeft;
    var top = ((height / 2) - (h / 2)) + dualScreenTop;
    var newWindow = window.open(url, title, 'location=1,status=1,scrollbars=1,resizable=1, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);
	// window.open('','','width=450,height=200,location=1,status=1,scrollbars=1,resizable=1,top='+ top +',left=' + left);return false;">
    // Puts focus on the newWindow
    if (window.focus) {
        newWindow.focus();
    }
}
