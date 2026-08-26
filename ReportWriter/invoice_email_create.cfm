<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<CFINCLUDE TEMPLATE="reportInclude.cfm">
<html>
<head>
	<title><cfoutput>#VOL_EMAIL_PAGE_TITLE#</cfoutput></title>
</head>
<CFPARAM name="FORM.button_caption"					default="continue">
<CFPARAM NAME="FORM.searchstring" 					DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" 					DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 					DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" 			DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" 		DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedDistributors"			Default="1">
<CFPARAM NAME="Form.editcurrentweight"				Default="0">
<CFPARAM NAME="FORM.Distributor_Status" 			DEFAULT="A">
<CFPARAM NAME="Form.Ship_To" 						DEFAULT="">
<CFPARAM NAME="FORM.sort_Order" 					DEFAULT="ASC1">
<CFPARAM NAME="FORM.Family_Name" 					DEFAULT="0">
<CFPARAM NAME="FORM.Buying_Group" 					DEFAULT="0">
<CFPARAM NAME="FORM.Line_Of_Biz" 					DEFAULT="">
<CFPARAM NAME="FORM.Zone_ID"						DEFAULT=""> 		
<CFPARAM NAME="FORM.Region_ID"						DEFAULT=""> 		
<CFPARAM NAME="FORM.Broker"							DEFAULT="">
<CFPARAM NAME="FORM.state"							DEFAULT="">
<CFPARAM NAME="FORM.Family_Name"					DEFAULT="">
<CFPARAM NAME="FORM.Visible_Family_Name"			DEFAULT="">
<CFPARAM NAME="FORM.Visible_Buying_Group"			DEFAULT="">
<CFPARAM NAME="Line_Of_Business" 					DEFAULT="">
<body ONLOAD="">
	<script src="/wddx.js"></script>
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
		<cfoutput>
			<script>
				var ErrorCount = 0;
				function confirmCompletion()
				{
					var ErrorCount = 0;
				
						if(document.all.SenderAddress.value.length == 0)	
						{ 
							ErrorCount++;
							queueMessage("You must enter your email address", document.all.error_SenderAddress);
						}
						else
						{			
							clearQueue(document.all.error_SenderAddress);
						}		
							
						
						 if(document.all.SenderSubject.value.length == 0)
						{			
							ErrorCount++;
							queueMessage("You must enter a subject", document.all.error_SenderSubject);
						}
						else
						{			
							clearQueue(document.all.error_SenderSubject);
						}	
						//if(document.all.Broker_Address.value.length == 0) CHROMEFIX
						var baStr = jQuery("textarea[name=Broker_Address]").val();
						if(baStr.length == 0)
						{
							ErrorCount++;
							queueMessage("You must enter at least one email address", document.all.error_Broker_Address);
						}
						else
						{
							clearQueue(document.all.error_Broker_Address);
						}
						
				<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
					if(ErrorCount == 0) 
					{	
						EmailForm.action="invoice_email_send.cfm";
						EmailForm.submit();
						
					}
					else 
					{
						showMessageWindow();
					}	
				}
			</script>
	</cfoutput>
	<CF_MessageWindow>	

	<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	 <br><br><br>
	 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
	 <br><br><br>
	</SPAN>
	<CFFLUSH>

	<blockquote>
	<FORM ACTION="invoice_email_send.cfm" METHOD="post" NAME="EmailForm" ID="EmailForm">
		<SCRIPT LANGUAGE="JavaScript">
			 document.all.PleaseWaitMessage.style.display='none';
		</SCRIPT>
		&nbsp;&nbsp;
		<SPAN CLASS="title2">Message Details:</SPAN>
		<HR COLOR="Orange">
		
		<CFOUTPUT>
		
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
		<TR>
			<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
			<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;"></TD>
			<!--- <TD ROWSPAN="100%"><IMG SRC="/images/email.gif"></TD> --->
		</TR>
		<TR>
			<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B><span id="error_SenderAddress"></span></TD>
			<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)" STYLE="width: 250px;"></TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B><span id="error_SenderSubject"></span></TD>
			<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="#VOL_EMAIL_SUBJECT#"></TD>
		</TR>
		<TR>
			<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
			<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5"></TEXTAREA></TD>
		</TR>
		</TABLE>
		</CFOUTPUT>
		
		<BR><BR>
		
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<SPAN CLASS="title2">Recipients' Email Addresses</SPAN>
		<HR COLOR="Orange">
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
		<TR VALIGN="top">
			<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Broker_Address"></span></TD>
			<TD><TEXTAREA NAME="Broker_Address" COLS="75" ROWS="5" STYLE="width:300px;"></TEXTAREA>
			</TD>
			<TD ALIGN="left">
			<CF_Email_Address_Lookup 
					Destination_Form_Name="EmailForm"
					Destination_Field_Name="Broker_Address"
					width="200"
					size="5"
					Alert="true">
			</TD>
		</TR>
		<TR>
			<TD></TD>
			<TD COLSPAN="2">
			<FONT COLOR="Red"><B><I>To add more recipients, add the email addresses separating them with a semi- colon ( ;)</I></B></FONT>
			</TD>
		</TR>
		</TABLE>
		
		<BR><BR>
		
		<CFSAVECONTENT VARIABLE="Summary_Content">
			<DIV ALIGN="center">
				<cfoutput>
				<DIV align="left">
					<BLOCKQUOTE>
						<B>You have elected to run a report against invoices using the following criteria. Once the report is complete, we will inform you via email.</B>
					</BLOCKQUOTE>
				</DIV>
				<!--- for Invoice ---->
					<FIELDSET STYLE="padding:1px; border: 0px solid Blue; width:150px" >
					    <LEGEND STYLE="font: italic bold 12px sans-serif; color: Red; background-color:##FFFFCC;">Date Span Criteria</LEGEND>
							<TABLE border="5" cellspacing="5" cellpadding="4" STYLE="background-color:##F5FFFA;font: bold 10 sans-serif;">
								<TH ALIGN="left" STYLE="font: bold 12px sans-serif; color: gray;" NOWRAP>Fields</TH>
								<TH ALIGN="left" STYLE="font: bold 12px sans-serif; color: gray;" NOWRAP>Selected Values</TH>
								<TR><TD NOWRAP ALIGN="left" colspan="1">Date Value</TD><TD ALIGN="right">#FORM.invoicedate#</TD></TR>
								<TR><TD NOWRAP ALIGN="left" colspan="1">Fiscal Period</TD><td nowrap align="right"><Input TYPE="Checkbox" <cfif ListFind(FORM.history_period, "fiscal_period", ",") GT 0 > CHECKED </cfif> disabled></td></TR>
								<TR><TD NOWRAP ALIGN="left" colspan="1">Fiscal Quarter</TD><TD ALIGN="right"><Input TYPE="Checkbox" <cfif ListFind(FORM.history_period, "fiscal_quarter", ",") GT 0 > CHECKED </cfif> disabled></td></TR>
								<TR><TD NOWRAP ALIGN="left" colspan="1">Fiscal Year</TD><TD ALIGN="right"><Input TYPE="Checkbox" <cfif ListFind(FORM.history_period, "fiscal_year", ",") GT 0 > CHECKED </cfif>  disabled></td></TR>
							</TABLE>
						</LEGAND>
					</FIELDSET>
					
					<BR><BR>
					<!--- check for the toggled item --->
					  <cfset Dist_Flag = ListFindNoCase(FORM.toggle,"Distributor", ",")>
					  <cfset Product_Flag = ListFindNoCase(FORM.toggle,"Product", ",")>

				
				<!--- for Distributor --->
					<cfif Dist_Flag GT 0 >
						<FIELDSET STYLE="padding:1px; width: 150px; border: 0px solid Blue">
						    <LEGEND STYLE="font: italic bold 12px sans-serif; color: Red; background-color: ##FFFFCC; ">#application.returned_customer_setting.distributor_label_plural# Criteria</LEGEND>
								<TABLE BORDER="5" CELLPADDING="4" CELLSPACING="5" STYLE="background-color: ##F0F8FF;font: bold 10 sans-serif;">
									<TH ALIGN="left" STYLE="font: bold 12px sans-serif; color: gray;" NOWRAP>Fields</TH>
									<TH ALIGN="left" STYLE="font: bold 12px sans-serif; color: gray;" NOWRAP>Selected Values</TH>
									<TR><TD NOWRAP COLSPAN="1" ALIGN="left"><span ID="searchItemLabel">#application.returned_customer_setting.family_name_label_singular#</b></TD><TD ALIGN="right"><cfif FORM.Family_Name_Text EQ "">ALL<cfelse>#FORM.Family_Name_Text#</cfif></span><BR></TD></TR>
									<TR><TD ALIGN="left" NOWRAP><span ID="searchItemLabel">#application.returned_customer_setting.buying_group_label_singular# </TD><TD ALIGN="right"><cfif FORM.Buying_Group_Text EQ "">ALL<cfelse>#FORM.Buying_Group_Text#</cfif></span><BR></TD></TR>
									<TR><TD ALIGN="left" NOWRAP COLSPAN="1"><span ID="searchItemLabel">#application.returned_customer_setting.zone_label_singular# </TD><TD ALIGN="right"><cfif len(FORM.Zone_Name_Text) EQ 0>ALL<cfelse>#FORM.Zone_Name_Text#</cfif></span><BR></TD></TR>
									<TR><TD ALIGN="left" NOWRAP><span ID="searchItemLabel">#application.returned_customer_setting.region_label_singular# </TD><TD ALIGN="right"><cfif len(FORM.Region_Name_Text) EQ 0>ALL<cfelse>#FORM.Region_Name_Text#</cfif></span><BR></TD></TR>
									<TR><TD ALIGN="left" NOWRAP><span ID="searchItemLabel">#application.returned_customer_setting.shard_ship_to_label# </TD><TD ALIGN="right"><cfif len(Form.Ship_To) GT 0>#Form.Ship_To#<cfelse>ANY</cfif></span></TD></TR>
								</TABLE>	
							</LEGEND>
						</FIELDSET>
					</cfif>
					
					<BR><BR>
					<!--- Type_Code_Desc_Text, Type_Group_Desc_Text, item_number--->
					<cfif Product_Flag GT 0 >
						<FIELDSET STYLE="padding:1px; width: 150px; border: 0px solid Blue">
						    <LEGEND STYLE="font: italic bold 12px sans-serif; color: Red; background-color: ##FFFFCC; ">Product Criteria</LEGEND>
								<TABLE BORDER="5" CELLPADDING="4" CELLSPACING="5" STYLE="background-color: ##F0F8FF;font: bold 10 sans-serif;">
									<TH ALIGN="left" STYLE="font: bold 12px sans-serif; color: gray;" NOWRAP>Fields</TH>
									<TH ALIGN="left" STYLE="font: bold 12px sans-serif; color: gray;" NOWRAP>Selected Values</TH>
									<TR><TD NOWRAP COLSPAN="1" ALIGN="left"><span ID="searchItemLabel">#application.returned_customer_setting.type_code_label_singular#</b></TD><TD ALIGN="right"> <cfif FORM.Type_Code_Desc_Text EQ ""> ALL <cfelse> #FORM.Type_Code_Desc_Text# </cfif></span><BR></TD></TR>
									<TR><TD ALIGN="left" NOWRAP><span ID="searchItemLabel">#application.returned_customer_setting.type_group_label_singular# </TD><TD ALIGN="right"><cfif FORM.Type_Group_Desc_Text EQ "">ALL<cfelse>#FORM.Type_Group_Desc_Text#</cfif></span><BR></TD></TR>
									<TR><TD ALIGN="left" NOWRAP COLSPAN="1"><span ID="searchItemLabel">Item ## </TD><TD ALIGN="right"><cfif len(FORM.item_number) EQ 0>ALL<cfelse>#FORM.item_number#</cfif></span><BR></TD></TR>
								</TABLE>	
							</LEGEND>
						</FIELDSET>
					</cfif>
				</cfoutput>
			</DIV>
			<!---<CFINCLUDE TEMPLATE="reportInvoiceForm.cfm">--->
		</CFSAVECONTENT>
		<cfset session.saved_invoice_form = #Summary_Content#>

		<!--- confidential information --->
		<div align="Center">
		<table width="90%" BORDER="0" CELLSPACING="0" CELLPADDING="2">
			<TR>
				<TD COLSPAN="100%">
					<br>				
					<hr color="navy">
					<cfoutput>#application.returned_customer_setting.confidentiality_content#</cfoutput>
					<hr 				
					<hr color="navy">
				</TD>
			</TR>
		</table></div>
		
		<BR CLEAR="ALL">
		<BR>
		
		</blockquote>
		
		<TABLE>
			<TR>
				<TD>
					<CF_button
						button_name		=	""
						button_caption	=	"send email package"
						button_action	=	"javascript:confirmCompletion();"
						button_type		=	"javascript_link"
						button_width	=	"150"
						button_color	=	"Navy"
						button_tip		=	"Click here to send..."
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold">
				</TD>
			</TR>
		</TABLE>
		<!--- hidden variables --->
		<cfoutput>
			<cfloop collection=#FORM# item="myItem">
				<cfoutput>
					<INPUT TYPE="Hidden" NAME="#trim(myItem)#" VALUE="#Evaluate('FORM.' & trim(myItem))#">
				</cfoutput>
			</cfloop>
		</cfoutput>
	</FORM>

</body>
</html>
