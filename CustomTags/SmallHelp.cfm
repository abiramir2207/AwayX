<!------ SmallHelp.cfm ----->
<CFSILENT>
<CFPARAM NAME="Attributes.showImage" DEFAULT="1">
<CFPARAM NAME="Attributes.showText" DEFAULT="">
<CFPARAM NAME="Attributes.showTextColor" DEFAULT="">
<CFPARAM NAME="Attributes.imgPath" 	DEFAULT="/Images/help_small.gif">
<CFPARAM NAME="Attributes.imgWidth" 	DEFAULT="14">
<CFPARAM NAME="Attributes.imgHeight" 	DEFAULT="14">
<CFPARAM NAME="Attributes.borderColor" 	DEFAULT="Navy">
<CFPARAM NAME="Attributes.borderWidth" 	DEFAULT="2">
<CFPARAM NAME="Attributes.backgroundColor" 	DEFAULT="##FFF8DC">
<CFPARAM NAME="Attributes.padding" 	DEFAULT="5">
<CFPARAM NAME="Attributes.width" 	DEFAULT="100">
<CFPARAM NAME="Attributes.height" 	DEFAULT="">
<CFPARAM NAME="Attributes.displayShifyX" 	DEFAULT="0">
<CFPARAM NAME="Attributes.displayShifyY" 	DEFAULT="0">
<CFPARAM NAME="Attributes.height" 	DEFAULT="">
<CFPARAM NAME="Attributes.overflow" 	DEFAULT="visible">
<CFPARAM NAME="Attributes.dropdownCheck" 	DEFAULT="1">
<CFPARAM NAME="Attributes.returnDivId" 	DEFAULT="">
<CFSET currentId = RandRange(1, 9999)>
<CFSET divId = "SmallHelp_#currentId#">
</CFSILENT>

<!------ <CFIF Attributes.displayText NEQ ""> ----->
<CFIF ThisTag.ExecutionMode EQ "start" AND thisTag.HasEndTag>
<CFOUTPUT>
	<SCRIPT language="JavaScript">
		var displayShifyX_#divId# = #Attributes.displayShifyX#;
		var displayShifyY_#divId# = #Attributes.displayShifyY#;
	</SCRIPT>
<CFIF NOT IsDefined("CALLER.SmallHelpScriptAdded")>
	<cf_script src="/script/javascript/dhtml.js"></cf_script>
	<SCRIPT language="JavaScript">
		var smallHelpArray = new Array();
		function showSmallHelp(divId, bShow, bArgCenterDivX)
		{
			var bCenterDivX = 0;
			if(bArgCenterDivX) bCenterDivX = bArgCenterDivX;
			var srcIsSameAsThisDiv = 0;
			var divObj = eval("document.all." + divId);
			var currentDisplay = divObj.style.display;
			if(bShow && currentDisplay == "none")
			{
				showSmallHelpDiv(divObj, bCenterDivX);
			}
			else if(!bShow && currentDisplay == "")
			{
				if(event)
				{
					if(event.toElement)
					{
						if(event.toElement.id)
						{
							if(event.toElement.id == divId)
							{
								srcIsSameAsThisDiv = 1;
							}
						}
					}
				}
				if(!srcIsSameAsThisDiv)
				{
					hideSmallHelpDiv(divObj);
				}
			}

		}
		function hideSmallHelpDiv(divObj)
		{
			divObj.style.display = "none";
			smallHelpShowSelectBoxes();
			return false;
		}


		function showSmallHelpDiv(divObj, bArgCenterDivX)
		{

			var bCenterDivX = 0;
			if(bArgCenterDivX) bCenterDivX = bArgCenterDivX;

			var wid, hei, divHeight;

			var displayShifyX = eval("displayShifyX_" + divObj.id);
			var displayShifyY = eval("displayShifyY_" + divObj.id);

			wid = event.clientX + 5;
			hei = event.clientY - 5;

			var oDivParent;

			/* On IE 11,the "divObj.offsetParent" is null, when "divObj.style.display" is "none".
			Resetting the style (divObj.style.display= "") below, so that "divObj.offsetParent" can be retrieved.
			*/
			divObj.style.display= "";
			if(divObj.offsetParent)
			{
				oDivParent = divObj.offsetParent;
			}
			var aObj = event.srcElement;
			if(aObj)
			{
				var l = getTotalOffsetProperty(aObj, "body", "offsetLeft", 0, oDivParent);
				wid = l + aObj.offsetWidth + displayShifyX;

				var h = getTotalOffsetProperty(aObj, "body", "offsetTop", 0, oDivParent);
				hei = h + aObj.offsetHeight + displayShifyY;
			}

			wid = wid + 'px';
			hei = hei + 'px';

			divObj.style.display= "";
			divHeight = divObj.offsetHeight;

			if(divHeight == 0 && !isNaN(parseFloat(divObj.style.height)))
			{
				divHeight = parseFloat(divObj.style.height);
			}
			var availHeight;
			if(oDivParent)
			{
				availHeight = oDivParent.clientHeight + oDivParent.scrollTop;
			}
			else
			{
				availHeight = document.body.clientHeight + document.body.scrollTop;
			}

			if(availHeight < hei + divHeight)
			{
				hei = availHeight - divHeight;
				hei = hei + 'px';
			}
			

			if(divObj)
			{			
				divObj.style.left = wid;
				divObj.style.top = hei;

				if(bCenterDivX)
					divObj.style.left = getCenterDivX(divObj);

				<cfif Attributes.dropdownCheck EQ 1>
				var oDivDim = new getsmallHelpDim(divObj);
				smallHelpHideSelectBoxes(oDivDim, oDivParent);
				</cfif>
				divObj.style.display= "";

			}
			event.cancelBubble = true;
			event.returnValue = false;
		}

		function smallHelpHideSelectBoxes(oDivDim, oDivParent)
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
						smallHelpHideSelect(thisObj, oDivDim, oDivParent);
					}
				}
			}
		}
		function smallHelpHideSelect(oSelect, oDivDim, oDivParent)
		{
			var oSelectDim = new getsmallHelpOffsetDim(oSelect, oDivParent);
			//oSelectDim.show();
			var overlaps = false;
			var doNotHide;
			overlaps = overlaps || smallHelpFindInMiddle(oSelectDim, oDivDim);

			if(overlaps)
			{
				doNotHide = false;
				if(oDivParent)
				{
					if(!isParentObject(oSelect, oDivParent))
					{
						doNotHide = true;
					}
				}
				if(!doNotHide)
				{
					smallHelpArray[smallHelpArray.length] = new setSmallHelpSelectAsHidden(oSelect);
					oSelect.style.visibility = "hidden";
				}
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
			alert(oDim.x11 + "\n" + oDim.y11 + "\n" + oDim.x12 + "\n" + oDim.y12);
		}

		function getsmallHelpOffsetDim(obj, oStopBeforeParent)
		{
			this.x11 = parseInt(getTotalOffsetProperty(obj, "body", "offsetLeft", 0, oStopBeforeParent));
			this.x11 = (isNaN(this.x11)?0:this.x11);
			var wid = parseInt(obj.offsetWidth);
			this.x12 = this.x11 + (isNaN(wid)?0:wid);
			this.y11 = parseInt(getTotalOffsetProperty(obj, "body", "offsetTop", 0, oStopBeforeParent));
			this.y11 = (isNaN(this.y11)?0:this.y11);
			var hei = parseInt(obj.offsetHeight);
			this.y12 = this.y11 + (isNaN(hei)?10:hei);
			this.show = displayDim;
		}

		function getsmallHelpDim(obj)
		{
			this.x11 = parseInt(obj.style.left);
			this.x11 = (isNaN(this.x11)?0:this.x11);
			var wid
			wid = obj.offsetWidth;
			if(wid == 0)
			{
				wid = parseInt(obj.style.width);
			}
			this.x12 = this.x11 + (isNaN(wid)?0:wid);
			this.y11 = parseInt(obj.style.top);
			this.y11 = (isNaN(this.y11)?0:this.y11);
			var hei
			hei = obj.offsetHeight;
			if(hei == 0)
			{
				hei = parseInt(obj.style.height);
			}
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

		function divMouseOut(divObj)
		{
			if(event.toElement)
			{
				if(!isParentObject(event.toElement, divObj))
				{
					showSmallHelp(divObj.id, false);
				}
			}
		}


		function getCenterDivX(divObj)
		{

			var winWidth = parseFloat(divObj.style.width);
 			var wid = document.body.clientWidth;
			wid = (wid/2) - (winWidth/2);
			return wid;

		}

	</SCRIPT>
	<CFSET CALLER.SmallHelpScriptAdded = true>
</CFIF>
<cfif Attributes.showImage EQ 1><IMG border="0" SRC="#Attributes.imgPath#" WIDTH="#Attributes.imgWidth#" HEIGHT="#Attributes.imgHeight#" onmouseover="showSmallHelp('#divId#', true)" onmouseout="showSmallHelp('#divId#', false)">
<cfelseif Attributes.showImage EQ 0><span <cfif Attributes.showTextColor NEQ "">style="color:#Attributes.showTextColor#"</cfif>onmouseover="showSmallHelp('#divId#', true)" onmouseout="showSmallHelp('#divId#', false)">#Attributes.showText#</span>
</cfif>
<DIV onclick="showSmallHelp('#divId#', false)" ID="#divId#" STYLE="overflow:#Attributes.overflow#; display:none; z-index: 500000000; position:absolute; width:#Attributes.width#px; height:#Attributes.height#px; border:#Attributes.borderWidth#px #Attributes.borderColor# solid; padding:#Attributes.padding#px; background-color:#Attributes.backgroundColor#; font-size:10px;" foo=1 onmouseout="divMouseOut(this);">
</CFOUTPUT>
<cfif Attributes.returnDivId NEQ "">
	<cfset "Caller.#Attributes.returnDivId#" = divId />
</cfif>
</CFIF>
<CFIF ThisTag.ExecutionMode EQ "end" AND thisTag.HasEndTag>
</DIV>
</CFIF>
