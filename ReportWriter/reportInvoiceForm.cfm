<cfflush>
	<!--- header information --->
	<BLOCKQUOTE>
	<MARQUEE align="left"  loop=1   style="position:relative;left:0px" 
			 	SCROLLAMOUNT=40 SCROLLDELAY=2 behavior=slide direction=left > 
	<SPAN style="color: Navy;font-size: 16px;font-weight: bold;"><cfoutput>#VOL_INPUT_PAGE_TITLE#</cfoutput></SPAN>
	<HR COLOR="Orange" SIZE="1">
	</MARQUEE>

	<!---%%%%%%%%% initialization %%%%%%%%%%%%%%%%---->
	<cfparam NAME="toggled_filter" 			DEFAULT="">
	<cfparam NAME="FORM.rReportOutputType" 	DEFAULT="email_notification">
	<cfparam Name="FORM.rReportType" 		default="h" >
	<cfparam NAME="FORM.toggle" 			DEFAULT="Distributor">
	<cfparam NAME="report_rundate" 			DEFAULT="">
	<cfparam NAME="URL.email_flag" 			DEFAULT="0">
	<cfparam name="ListOfAvailUOMFF"		DEFAULT="">
	<!---check if session.form is existing, if so, copy it to form--->	
	<cfif isDefined("session.form") and Not StructIsEmpty(session.form)>
		<cfloop collection=#session.form# item="myItem">
			<cfoutput>
				<cfset "form.#trim(myItem)#" = #Evaluate('session.form.' & trim(myItem))# >
			</cfoutput>
		</cfloop>
	</cfif>
	<!---%%%%%%%%%%%%%%% query information %%%%%%%%%%%%%%%%%%--->
	<cfif isDefined("Form.toggled_filter")>
		<cfset toggled_filter = Form.toggled_filter>
	</cfif>
	<FORM ACTION="reportInvoiceAction.cfm" TARGET="_self" METHOD="post" NAME="MyInvoiceForm" ID="MyInvoiceForm" STYLE="DISPLAY:INLINE">
		<!-----		Essential Filters -------->
		<!-----		Invoice Filter ----->
		<cfif isDefined("sErr")>
			<BR>
			<TABLE BGCOLOR="Red" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
				<TR BGCOLOR="White">
					<TD>		
						<CFOUTPUT><FONT SIZE="2"><B>Update failed. Some of the fields are either missing or invalid.</B></FONT></CFOUTPUT>
					</TD>
				</TR>
			</TABLE>
		<cfelseif isDefined("URL.action")>
			<BR>
			<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
				<TR BGCOLOR="White">
					<TD><CFOUTPUT><FONT SIZE="2"><B>The report was <cfif URL.action EQ "edit">edited<cfelse>added</cfif> successfully.</B></FONT></CFOUTPUT></TD>
				</TR>
			</TABLE>
		</cfif>
		<BR>
		<CFINCLUDE TEMPLATE="reportInvoiceFilter.cfm">	
		<BR>
		<!---<HR COLOR="Orange" SIZE="1"> --->
		<!-----		Distributor Filter ------>
		<CFINCLUDE TEMPLATE="reportDistributorFilter.cfm">		
		<!-----		Optional Filter		------->
		<!-----  Product Filter ---->
		<CFINCLUDE TEMPLATE="reportProductFilter.cfm">
		<!-----		Broker Filter		------->
		<!-----		Comment out Broker for now ---->
		<!---<CFINCLUDE TEMPLATE="reportBrokerFilter.cfm"> --->
		<DIV>
			<BR>
			<HR COLOR="Orange" SIZE="1">		
			<BR>
			<!-----	Display Filter Switch CheckBox---->
			<cfset UOMList = "Case,Pound,Dollar">
				<table cellspacing="" width="500px" >
					<tr >
						<td nowrap bordercolor="#FFFFFF"><strong>Filter Toggles </strong></td>
					</tr>
					<tr>
						<td nowrap><input type="checkbox" name="toggle" 	value="Distributor" onclick="toggled_filter.value=document.all.MyInvoiceForm.toggle[0].value;filterHandler(document.all.MyInvoiceForm.toggle[0])" <cfif ListFind(FORM.toggle, "Distributor", ",") GT 0 > CHECKED </cfif> > <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> </td>
						<td nowrap><input type="checkbox" name="toggle" 	value="Product" onclick="toggled_filter.value=document.all.MyInvoiceForm.toggle[1].value;filterHandler(document.all.MyInvoiceForm.toggle[1])"  <cfif ListFind(FORM.toggle, "Product", ",") GT 0 > CHECKED </cfif> > Products </td>
						<td nowrap><input type="checkbox"   name="toggle" 	value="Broker" 	onclick="toggled_filter.value=document.all.MyInvoiceForm.toggle[2].value;filterHandler(document.all.MyInvoiceForm.toggle[2])" <cfif ListFind(FORM.toggle, "Broker", ",") GT 0 > CHECKED</cfif> disabled> Broker </td>
						<td align="right" nowrap >
							<font style="font-weight:bold; font-size:11px; color: navy;">Global UOM:</font>
								<select name="Global_UOM" id="Global_UOM">
									<option value="1"><cfoutput>#trim(ListGetAt(UOMList,1))#</cfoutput></option>
									<option value="2"><cfoutput>#trim(ListGetAt(UOMList,2))#</cfoutput></option>
									<option value="3"><cfoutput>#trim(ListGetAt(UOMList,3))#</cfoutput></option>
								</select>
						</td>
					</tr>
				</table>
						<input type="hidden" name="toggled_filter" 	value="<cfoutput>#toggled_filter#</cfoutput>"/>
				<table>
					<tr>
						<!---- report output type (email notification or direct---->
						<TD>
							<strong>Report output Type</strong>
						</TD>
						<TD>
							<INPUT TYPE="radio" ID="rReportType" NAME="rReportType" VALUE="h"<cfif rReportType EQ "h"> CHECKED</cfif>>HTML
						</TD>
						<TD>
							<INPUT TYPE="radio" ID="rReportType" NAME="rReportType" VALUE="e"<cfif rReportType EQ "e"> CHECKED</cfif>>Excel
						</TD>
						<TD>
							<INPUT TYPE="radio" ID="rReportType" NAME="rReportType" VALUE="c"<cfif rReportType EQ "c"> CHECKED</cfif>>CSV
						</TD>
						
						<!---- report output type (email notification or direct---->
						<TD width="37">&nbsp;</TD>
						<TD>
							<strong>Method</strong>
						</TD>
						<TD>
							<INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="email_notification"<cfif FORM.rReportOutputType EQ "email_notification"> CHECKED</cfif>>Email Notification
						</TD>
						<TD>
							<INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="direct"<cfif FORM.rReportOutputType EQ "direct"> CHECKED</cfif>>Direct
						</TD>
					</tr>
				</table>
				<!--- schedule the report --->
			<!--- handle the title --->
			<cfif isDefined("rID")>
				<cfif rID GT 0>
					<cfset bTitle="Edit This Report Schedule">
				<cfelse>
					<cfset bTitle="Save As Report Schedule">
				</cfif>
			<cfelse>
				<cfset bTitle="Save As Report Schedule">
			</cfif>
			<cfif isDefined("sErr")><cfset showClosed="No"><cfelse><cfset showClosed="Yes"></cfif>
				<!--- schedule the report --->
				<!--- report scheduling default information --->
				<!----------- Get a new report name --------------------->
				<CFQUERY NAME="q_reportName" datasource="#application.datasource#">
					SELECT Max(Report_Type_ID) as maxReport_Type_ID
					FROM Report_Type
				</CFQUERY>
				<CFIF q_reportName.recordCount GT 0>
					<CFIF q_reportName.maxReport_Type_ID EQ "">
						<CFSET rName="Volume Report 1">
					<CFELSE>
						<CFSET rName="Volume Report #Evaluate(q_reportName.maxReport_Type_ID+1)#">
					</CFIF>
				</CFIF>
				<CFSET thisFormName = "MyInvoiceForm">
				<CFSET rStartDate=dateformat(Now(), 'm/d/yyy')>
				<CFSET rEndDate=dateformat(Now(), 'm/d/yyy')>
				<CFSET rStartTime=thisTime>
				<cfset rIntervals="Once,Daily,Weekly,Monthly">
				<CFSET rInterval="once">
				<CFSET rEmailAddress="">
				<cfif isDefined("sErr")><cfset showClosed="No"><cfelse><cfset showClosed="Yes"></cfif>
				<CF_openLayer
				Border="yes"
				BorderSize="1"  
				BorderColor="orange"  
				Image="/images/plus2.gif"
				ImageOpen="/images/minus2.gif"
				Title="#bTitle#"  
				TitleClosed="#bTitle#"  
				TitleTooltip="#bTitle#"  
				TitleFont="font"  
				TitleColor="Blue"  
				TitleSize="9"  
				IsClosed="#showClosed#"  
				Width="100%">
					<CFSET repType="r">
					<CFINCLUDE TEMPLATE="reportInvoiceScheduleTemplate.cfm">		
				</CF_openLayer>
				<br>		
				<DIV ALIGN="center">
				<MARQUEE align="left"  loop=1   style="position:relative;"   
			 	SCROLLAMOUNT=12 SCROLLDELAY=5 behavior=slide direction=up > 
					<CFIF isDefined("url.email_flag") and url.email_flag EQ 0>
						<DIV ALIGN="center">
							<CF_BUTTON
							BUTTON_NAME		=	""
							BUTTON_CAPTION	=	"show report"
							BUTTON_ACTION	=	"javascript:confirmData(document.all.MyInvoiceForm);"
							BUTTON_TYPE		=	"javascript_link"
							BUTTON_WIDTH	=	"150"
							BUTTON_COLOR	=	"Navy"
							BUTTON_TIP		=	""
							FONT_COLOR		=	"White"
							FONT_SIZE		=	"12"
							FONT_WEIGHT		=	"bold">
						</DIV>
					</CFIF>
				</MARQUEE> 
				</DIV>
		</DIV>

		<!-----  Operator Filter ---->		
		<!-----  Broker Filter ---->
	</form>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
	function filterHandler(theObject)
	{
		if (theObject.checked)
		{
			eval("filter" + theObject.value + ".style.visibility" + "='visible'");
			eval("filter" + theObject.value + ".style.display" + "='block'");
		}
		else
		{
			eval("filter" + theObject.value + ".style.visibility" + "='hidden'")
			eval("filter" + theObject.value + ".style.display" + "='none'");
		}
	}
	function default_Invoice_Days(thisObj, shiptoObj, bObjType)
	{
	}	

	//document.body.onload=new Function ("default_Invoice_Days(document.all.Distributor, document.all.Ship_To, 1);")
	function confirmData(thisForm)
	{
		var allClear = true;
		var oldTarget = thisForm.target;
		
		if (thisForm.rReportOutputType[1].checked ) {
		//direct
			if (thisForm.rReportType[0].checked)
				thisForm.target = "reportInvoiceoutput";
			else 
				var  answer = confirm('This may take some time. Do you want to continue?');
			if (answer == false)
				return false;
			}
		else  //email
			thisForm.target = "reportInvoiceoutput";
		
		//if Report Output Type is Email Notification, create_email then eventually send email to customer for the criteria confirmation
		//else show the output report 
		if (thisForm.rReportOutputType[0].checked || thisForm.rReportType[0].checked ) 
			NewWindow('', 'reportInvoiceoutput', '800','550','Yes', 'Yes');
		
		if (thisForm.rReportOutputType[0].checked == true)
		{
			thisForm.action = "invoice_email_create.cfm?email_flag=1";
			//thisForm.action = "reportInvoiceForm.cfm?email_flag=1";
		}
		else
		{
			thisForm.action = "reportInvoiceAction.cfm";
		}
		thisForm.submit();
		thisForm.target = oldTarget;		
		return allClear;
	}
</SCRIPT>
<cfif isDefined("session.form") and Not StructIsEmpty(session.form)>
	<cfloop index="myItem" list="#form.toggle#" delimiters=",">
		<cfif trim(myItem) EQ "Product">
			<script>
				filterHandler(document.all.MyInvoiceForm.toggle[1]);
			</script>
		</cfif>
	</cfloop>
</cfif>
<!--- clear the session.form --->
<cfif isDefined("session.form") >
	<cfscript>
		StructClear(session.form);
	</cfscript> 
</cfif>