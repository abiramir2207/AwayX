<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<!------
ShowBrokers.cfm
----->
<CFPARAM NAME="FORM.Distributor_List" 	DEFAULT="">
<CFPARAM NAME="URL.rDistributors" 	DEFAULT="#FORM.Distributor_List#">
<CFSET rDistributors = URL.rDistributors>
<CFSET DistributorName = "search">
<CFIF Len(rDistributors) EQ 0>
	<CFSET rDistributors = "-1">
</CFIF>
<CFIF rDistributors NEQ -1 AND Len(rDistributors) GT 0>
	<cfset useLakebaseForq_getDistributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_lob_active")>
<cfif useLakebaseForq_getDistributors>
	<cftry>
		<cfset q_getDistributors = application.oLakebase.toQuery(
			application.oLakebase.selectRows("customer_lob_active", {
				"bsa_foodservice_customers_id" = "eq.#rDistributors#",
				"select" = "bsa_foodservice_customers_id,name"
			}), "bsa_foodservice_customers_id,name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForq_getDistributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForq_getDistributors>
<CFQUERY NAME="q_getDistributors" datasource="#application.datasource#">
	SELECT 		customer_lob_active.BSA_FoodService_Customers_ID, customer_lob_active.Name
	FROM		customer_lob_active
	WHERE
			customer_lob_active.BSA_FoodService_Customers_ID = '#rDistributors#'
	</CFQUERY>
</cfif>
	<CFIF q_getDistributors.recordCOunt GT 0>
		<CFSET DistributorName = Left(q_getDistributors.Name, 20)>
	<CFELSE>
		<CFSET rDistributors = "-1">
	</CFIF>	
</CFIF>
<CFOUTPUT>
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">
<SCRIPT LANGUAGE="JavaScript">
	function disableAll(bDis)
	{
		var i, allLen, allObj;
		allObj = document.all;
		allLen = allObj.length;
		for(i=0;i<allLen;i++)
		{
			allObj[i].disabled = bDis;
			try
			{
				if(bDis)
				{
					allObj[i].style.display = "none";
				}
				else
				{
					if(allObj[i].tagName == "DIV")
					{
						allObj[i].style.display = display_Div(allObj[i]);
					}
					else
					{					
						allObj[i].style.display = "";
					}					
				}	
			}
			catch(e)
			{
				//alert(allObj[i].tagName + "\n" + e.description);
			}
		}
	}
	function showDistributorsSearchWindow() 
	{
		NewWindow("/Billbacks/search_screens/pm_select_distributors.cfm?Formname=Report_Search_Form", "Distributorwindow", 800, 600, "yes", "yes")
		return false;
	}
	function setParentDistributorID(DistributorID)
	{
		if(window.parent)
		{
			var DistributorInput = window.parent.document.all.rDistributors;
			if(DistributorInput)
			{
				DistributorInput.value = DistributorID;
			}
		}
	}	
	
	function setChildDistributorID(DistributorID)
	{
		document.all.rDistributors.value = DistributorID;
		setParentDistributorID(DistributorID);
		setChildSearchDistributorID(DistributorID);
		document.all.Distributor_Exist.style.display = display_Div(document.all.Distributor_Exist);
		document.all.All_Distributors.style.display = display_Div(document.all.All_Distributors);
	}
	function setChildSearchDistributorID(DistributorID)
	{
		if(DistributorID == "-1")
		{
			DistributorID = "";
		}
		document.all.Distributor_List.value = DistributorID;
	}
	function display_Div(thisObj)
	{
		var show = "";
		var hide = "none";
		var DistributorValue = document.all.rDistributors.value;
		if(thisObj.id)
		{
			if(thisObj.id == "Distributor_Exist")
			{
				if(DistributorValue != "-1")
				{
					return show;
				}
				else
				{
					return hide;
				}
			}
			else if(thisObj.id == "All_Distributors")
			{
				if(DistributorValue == "-1")
				{
					return show;
				}
				else
				{
					return hide;
				}
			}			
		}		
		return hide;
	}	
</SCRIPT>
<TABLE CELLPADDING="0" CELLSPACING="0" HEIGHT="100%">
<TR>
<TD VALIGN="middle">
<DIV ID="Distributor_Exist"<CFIF rDistributors EQ -1> STYLE="DISPLAY:NONE;"</CFIF>>
<FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: return showDistributorsSearchWindow();">#DistributorName#</A><FONT COLOR="Red"> ]</FONT> <FONT COLOR="Red">[</FONT> <A HREF="javascript: void(0);" onClick="javaScript: return setChildDistributorID(-1);">All #application.returned_customer_setting.distributor_label_plural#</A><FONT COLOR="Red"> ]</FONT>
</DIV>
<DIV ID="All_Distributors"<CFIF rDistributors NEQ -1> STYLE="DISPLAY:NONE;"</CFIF>>
All #application.returned_customer_setting.distributor_label_plural# <FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: return showDistributorsSearchWindow();">search</A><FONT COLOR="Red"> ]</FONT>
</DIV>
</TD>
</TR>
</TABLE>
<CFIF rDistributors NEQ "">
	<SCRIPT LANGUAGE="JavaScript">
	setParentDistributorID("#rDistributors#");	
	</SCRIPT>
</CFIF>
<INPUT TYPE="Hidden" NAME="rDistributors" VALUE="#rDistributors#">
<CFIF rDistributors EQ "-1"><CFSET rDistributors = ""></CFIF>
<FORM NAME="Report_Search_Form" ACTION="ShowDistributors.cfm" METHOD="post">
<INPUT TYPE="Hidden" NAME="Distributor_List" VALUE="#rDistributors#">
</FORM>
</BODY>
</CFOUTPUT>
