<cfset Color1="lightsteelblue"><!---Other Blue--->
<cfset Color2="FFCC66"><!---Yellow--->
<cfset Color3="CCFFCC"><!---Green--->
<cfset Color4="CCFFFF"><!---Light Blue--->


<cfparam name="ShowDetails" default="0">

<cfif isDefined("url.ShowDetails")>
<cfif url.ShowDetails IS 1>
	<cfset ShowDetails = 1>
<cfelse>
	<cfset ShowDetails = 0>
</cfif>
</cfif>

<cfif isDefined("form.ShowDetails")>
<cfif form.ShowDetails IS 1>
	<cfset ShowDetails = 1>
<cfelse>
	<cfset ShowDetails = 0>
</cfif>
</cfif>

<CFSCRIPT>
	Border="Yes";
	BorderSize=1;  
	BorderColor="Silver";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Black"; 
	TitleFont="Arial";
	TitleSize=8;
	IsClosed="Yes";  
	WIDTH="99%";
</CFSCRIPT>


<script>
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

 var displaystyle = 1;
 
function AllOpenLayers(bExpand,thisobj)
{	
	if(arguments.length > 2 ) 
	{
		var allFieldsets = document.getElementsByTagName("fieldset");
		var ExpandAll = true
	}
	else
	{
		var parentobj = getParentObject(thisobj, "fieldset");
		var allFieldsets = parentobj.getElementsByTagName("fieldset");
		var ExpandAll = false
	}
	var i, FieldsetLen, thisFieldsetID, nameLast;
	var divObj, imgObj;
	FieldsetLen = allFieldsets.length;
	var checkToken = "border_";
	try
	{
		if(thisobj.innerText.indexOf("Hide") >=0)
		{	
			showopenlayerstyle = "block";
			thisobj.innerText = " Show All Details ";
			displaystyle=1;	
		}
		else
		{
			showopenlayerstyle = "none";
			thisobj.innerText = " Hide All Details ";
			displaystyle=0;
		}
		
		for(i=0;i<FieldsetLen;i++)
		{
			if(allFieldsets[i].id)
			{
				thisFieldsetID = allFieldsets[i].id;
				{
					if(thisFieldsetID.substr(0,checkToken.length) == checkToken)
					{
						nameLast = thisFieldsetID.substr(checkToken.length,thisFieldsetID.length-checkToken.length);
						eval("divObj = allFieldsets[i].all.lyrGroup_" + nameLast);
						eval("imgObj = allFieldsets[i].all.image_" + nameLast);				
						
						if(!imgObj || ExpandAll)
						{
							eval("imgObj = allFieldsets[i].all.title_" + nameLast);	
							divObj.style.display=showopenlayerstyle;
							imgObj.click();	
						}				
					}
				}
			}
		}
		
		if (ExpandAll)
		{
			var oInnerDetails = document.all.InnerDetails
			if (oInnerDetails.length)
			{
				for (i = 0; i < oInnerDetails.length; i++)
				{
					oInnerDetails[i].innerText = thisobj.innerText;
					if (i == 10)
					break;
				}
			}
			else
			{
				oInnerDetails.innerText = thisobj.innerText;
			}
		}
	}
	catch(e)
	{
		//alert(e.description);
	}	
		
		return false;
}
</script>

