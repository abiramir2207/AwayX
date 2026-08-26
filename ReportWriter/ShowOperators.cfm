<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<!------
ShowBrokers.cfm
----->
<CFPARAM NAME="FORM.Operator_List" 	DEFAULT="">
<CFPARAM NAME="URL.rOperators" 	DEFAULT="#FORM.Operator_List#">
<CFSET rOperators = URL.rOperators>
<CFSET OperatorName = "search">
<CFIF Len(rOperators) EQ 0>
	<CFSET rOperators = "-1">
</CFIF>
<CFIF rOperators NEQ -1 AND Len(rOperators) GT 0>
	<cfset useLakebaseForq_getOperators = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForq_getOperators>
	<cftry>
		<cfset q_getOperators = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"bsa_operator_id" = "eq.#rOperators#",
				"select" = "bsa_operator_id,operator_name"
			}), "bsa_operator_id,operator_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForq_getOperators = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForq_getOperators>
<CFQUERY NAME="q_getOperators" datasource="#application.datasource#">
	SELECT 		BSA_Operator.BSA_Operator_ID, BSA_Operator.Operator_Name
	FROM		BSA_Operator
	WHERE
			BSA_Operator.BSA_Operator_ID = '#rOperators#'
	</CFQUERY>
</cfif>
	<CFIF q_getOperators.recordCOunt GT 0>
		<CFSET OperatorName = Left(q_getOperators.Operator_Name, 20)>
	<CFELSE>
		<CFSET rOperators = "-1">
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
	function showOperatorsSearchWindow() 
	{
		NewWindow("/Billbacks/search_screens/pm_select_operators.cfm?Formname=Report_Search_Form", "Operatorwindow", 800, 600, "yes", "yes")
		return false;
	}
	function setParentOperatorID(OperatorID)
	{
		if(window.parent)
		{
			var OperatorInput = window.parent.document.all.rOperators;
			if(OperatorInput)
			{
				OperatorInput.value = OperatorID;
			}
		}
	}	
	
	function setChildOperatorID(OperatorID)
	{
		document.all.rOperators.value = OperatorID;
		setParentOperatorID(OperatorID);
		setChildSearchOperatorID(OperatorID);
		document.all.Operator_Exist.style.display = display_Div(document.all.Operator_Exist);
		document.all.All_Operators.style.display = display_Div(document.all.All_Operators);
	}
	function setChildSearchOperatorID(OperatorID)
	{
		if(OperatorID == "-1")
		{
			OperatorID = "";
		}
		document.all.Operator_List.value = OperatorID;
	}
	function display_Div(thisObj)
	{
		var show = "";
		var hide = "none";
		var OperatorValue = document.all.rOperators.value;
		if(thisObj.id)
		{
			if(thisObj.id == "Operator_Exist")
			{
				if(OperatorValue != "-1")
				{
					return show;
				}
				else
				{
					return hide;
				}
			}
			else if(thisObj.id == "All_Operators")
			{
				if(OperatorValue == "-1")
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
<DIV ID="Operator_Exist"<CFIF rOperators EQ -1> STYLE="DISPLAY:NONE;"</CFIF>>
<FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: return showOperatorsSearchWindow();">#OperatorName#</A><FONT COLOR="Red"> ]</FONT> <FONT COLOR="Red">[</FONT> <A HREF="javascript: void(0);" onClick="javaScript: return setChildOperatorID(-1);">All <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput></A><FONT COLOR="Red"> ]</FONT>
</DIV>
<DIV ID="All_Operators"<CFIF rOperators NEQ -1> STYLE="DISPLAY:NONE;"</CFIF>>
All <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> <FONT COLOR="Red">[ </FONT><A HREF="javascript: void(0);" onClick="javaScript: return showOperatorsSearchWindow();">search</A><FONT COLOR="Red"> ]</FONT>
</DIV>
</TD>
</TR>
</TABLE>
<CFIF rOperators NEQ "">
	<SCRIPT LANGUAGE="JavaScript">
	setParentOperatorID("#rOperators#");	
	</SCRIPT>
</CFIF>
<INPUT TYPE="Hidden" NAME="rOperators" VALUE="#rOperators#">
<CFIF rOperators EQ "-1"><CFSET rOperators = ""></CFIF>
<FORM NAME="Report_Search_Form" ACTION="ShowOperators.cfm" METHOD="post">
<INPUT TYPE="Hidden" NAME="Operator_List" VALUE="#rOperators#">
</FORM>
</BODY>
</CFOUTPUT>

