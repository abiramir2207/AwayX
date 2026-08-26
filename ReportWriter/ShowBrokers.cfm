<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<!------
ShowBrokers.cfm
----->
<CFPARAM NAME="FORM.Broker_List" 	DEFAULT="">
<CFPARAM NAME="URL.rBrokers" 	DEFAULT="#FORM.Broker_List#">
<CFSET rBrokers = URL.rBrokers>
<CFSET BrokerName = "search">
<CFIF Len(rBrokers) EQ 0>
	<CFSET rBrokers = "-1">
</CFIF>
<CFIF rBrokers NEQ -1 AND Len(rBrokers) GT 0>
	<cfset useLakebaseForq_getBrokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("broker_lob_active")>
<cfif useLakebaseForq_getBrokers>
	<cftry>
		<cfset q_getBrokers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("broker_lob_active", {
				"bsa_foodservice_brokers_id" = "eq.#rBrokers#",
				"order" = "broker_name.asc",
				"select" = "bsa_foodservice_brokers_id,broker_name"
			}), "bsa_foodservice_brokers_id,broker_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForq_getBrokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForq_getBrokers>
<CFQUERY NAME="q_getBrokers" datasource="#application.datasource#">
		SELECT	BSA_Foodservice_Brokers_ID, Broker_Name
		FROM 	broker_lob_active
		WHERE
				broker_lob_active.BSA_Foodservice_Brokers_ID = '#rBrokers#'
		Order By Broker_Name
	</CFQUERY>
</cfif>
	<CFIF q_getBrokers.recordCount GT 0>
		<CFSET BrokerName = Left(q_getBrokers.Broker_Name, 25)>
	<CFELSE>
		<CFSET rBrokers = "-1">
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
	function showBrokersSearchWindow() 
	{
		NewWindow("/Billbacks/search_screens/pm_select_brokers.cfm?Formname=Report_Broker_Form", "brokerwindow", 800, 600, "yes", "yes")
		return false;
	}
	function setParentBrokerID(BrokerID)
	{
		if(window.parent)
		{
			var brokerInput = window.parent.document.all.rBrokers;
			if(brokerInput)
			{
				brokerInput.value = BrokerID;
			}
		}
	}	
	
	function setChildBrokerID(BrokerID)
	{
		document.all.rBrokers.value = BrokerID;
		setParentBrokerID(BrokerID);
		setChildSearchBrokerID(BrokerID);
		document.all.Broker_Exist.style.display = display_Div(document.all.Broker_Exist);
		document.all.All_Brokers.style.display = display_Div(document.all.All_Brokers);
	}
	function setChildSearchBrokerID(BrokerID)
	{
		if(BrokerID == "-1")
		{
			BrokerID = "";
		}
		document.all.Broker_List.value = BrokerID;
	}
	function display_Div(thisObj)
	{
		var show = "";
		var hide = "none";
		var brokerValue = document.all.rBrokers.value;
		if(thisObj.id)
		{
			if(thisObj.id == "Broker_Exist")
			{
				if(brokerValue != "-1")
				{
					return show;
				}
				else
				{
					return hide;
				}
			}
			else if(thisObj.id == "All_Brokers")
			{
				if(brokerValue == "-1")
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
<DIV ID="Broker_Exist"<CFIF rBrokers EQ -1> STYLE="DISPLAY:NONE;"</CFIF>>
<FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: return showBrokersSearchWindow();">#BrokerName#</A><FONT COLOR="Red"> ]</FONT> <FONT COLOR="Red">[</FONT> <A HREF="javascript: void(0);" onClick="javaScript: return setChildBrokerID(-1);">All Brokers</A><FONT COLOR="Red"> ]</FONT>
</DIV>
<DIV ID="All_Brokers"<CFIF rBrokers NEQ -1> STYLE="DISPLAY:NONE;"</CFIF>>
All Brokers <FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: return showBrokersSearchWindow();">search</A><FONT COLOR="Red"> ]</FONT>
</DIV>
</TD>
</TR>
</TABLE>
<CFIF rBrokers NEQ "">
	<SCRIPT LANGUAGE="JavaScript">
	setParentBrokerID("#rBrokers#");	
	</SCRIPT>
</CFIF>
<INPUT TYPE="Hidden" NAME="rBrokers" VALUE="#rBrokers#">
<CFIF rBrokers EQ "-1"><CFSET rBrokers = ""></CFIF>
<FORM NAME="Report_Broker_Form" ACTION="ShowBrokers.cfm" METHOD="post">
<INPUT TYPE="Hidden" NAME="Broker_List" VALUE="#rBrokers#">
</FORM>
</BODY>
</CFOUTPUT>
