<br>
<cfparam name="form.printonly" default="0">
<cfif form.printonly eq 0>
<TABLE WIDTH="95%" border="0" CELLPADDING="0" CELLSPACING="0" align="center">
 <tr>
		<td align="left" width="50">
		<CF_button
			button_name		=	""
			button_caption	=	"Print"
			button_action	=	"javascript:printform();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"View Pullback Rates"
			font_color		=	"White"
			font_size		=	"14"
			font_weight		=	"bold"
			>
		</td>
		<td align="left" colspan="100%">
		<CF_button
			button_name		=	""
			button_caption	=	"Close"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Edit Pullback Rates"
			font_color		=	"White"
			font_size		=	"14"
			font_weight		=	"bold"
			>
		</td>
	</tr>
 </table>
</cfif>
<SCRIPT LANGUAGE="javaScript">
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
	var sortBy;
	var sort_order;
	var orderFileName;
	
	initialise();
	function initialise()
	{		
		sortBy = "<cfoutput>#checksortby#</cfoutput>";
		<CFIF FORM.sort_order EQ "ASC">
			sort_order = 1;
		<CFELSE>
			sort_order = 0;		
		</CFIF>
		orderFileName = "<cfoutput>#Current_Image#</cfoutput>";
	}
	function setSortHref(sortVal)
	{
		if(sortBy == sortVal)
		{
			sort_order *= -1;
		}
		else
		{
			sort_order = 1;
			sortBy = sortVal;
		}
		var SORTORDER;
		
		if(sort_order < 0)
		{
			SORTORDER = "DESC";
			orderFileName = "<cfoutput>#DESC_IMG#</cfoutput>";
		}
		else
		{
			SORTORDER = "ASC";
			orderFileName = "<cfoutput>#ASC_IMG#</cfoutput>";
		}
		document.Templates.sort_by.value = sortVal;
		document.Templates.sort_Order.value = SORTORDER;
		
		var thisCell = getParentObject(event.srcElement,"TD");		
		//setSortImage(thisCell);
		document.Templates.submit();
	}
	/*
	function setSortImage(thisCell)
	{
		
		var thisSPObj = thisCell.all.SP_SP;
		var spObjs = document.all.SP_SP;
		var i;
		alert(orderFileName);
		for(i=0;i<spObjs.length;i++)
		{
			if(spObjs[i] == thisSPObj)
			{
				spObjs[i].all.S_IMG.src = "/Images/" + orderFileName;
				alert(spObjs[i].all.S_IMG.src);
				spObjs[i].style.visibility = "visible";
			}
			else
			{
				spObjs[i].style.visibility = "hidden";
			}
		}	
	}*/
</SCRIPT>
