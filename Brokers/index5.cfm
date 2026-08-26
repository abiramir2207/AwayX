<CFSET PAGE_TITLE="Brokers' Action Plan">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
<!--- Error checking to make sure the note has been entered --->	
<script language="JavaScript">
<!--BEGIN Script
	function checkData ()
			{
        		if (document.MyForm.Broker_Action_Plan_Notes.value == "") {
                alert("You have not entered any notes...")
                document.MyForm.Broker_Action_Plan_Notes.focus()
			}
		else
			{
				 document.all.MyForm.submit();
			}
	}
// -->
</script>

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<CFPARAM NAME="URL.APID" DEFAULT="9999999999999">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decrypt the ID																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="de" string ="#URL.ID#" key="#request.key#">
<CFSET URL.APID = cryp.value>


<!--- Get the broker plan data --->
<cfset useLakebaseForGetPlanData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("broker_action_plan")>
<cfif useLakebaseForGetPlanData>
	<cftry>
		<cfset Get_Plan_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("broker_action_plan", { "broker_action_plan_id" = "eq.#URL.APID#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetPlanData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPlanData>
	<CFQUERY NAME="Get_Plan_Data" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0, 24, 0, 0)#">
		Select	*
		From	Broker_Action_Plan
		Where	Broker_Action_Plan_ID	=	'#URL.APID#'
	</CFQUERY>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If there is tampering with the URL or there are no records that match the ID, stop the process --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF Get_Plan_Data.RecordCount EQ 0>
	<BR><BR><BR><BR><BR><BR><BR><BR><BR>
	<CENTER><H4>No action plan for this ID</H4></CENTER>
	<CFINCLUDE TEMPLATE="/includes/footer.cfm">	
	<CFABORT>
</CFIF>


<!--- Get the name of the operator --->
<CFQUERY NAME="Get_Operator_Name" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0, 24, 0, 0)#">
	Select		Operator_Name
	From		BSA_Operator
	Where		BSA_Operator_ID	=	#Get_Plan_Data.BSA_Operator_ID#
</CFQUERY>

<!--- Get the name of the user that created this broker plan --->
<CFQUERY NAME="Get_User_Name" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0, 24, 0, 0)#">
	Select		Name_First,
				Name_Last
	From		_Users
	Where		User_ID	=	'#Get_Plan_Data.User_ID#'
</CFQUERY>

<!--- Get the broker plan notes data --->
<cfset useLakebaseForGetNotes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("broker_action_plan_notes")>
<cfif useLakebaseForGetNotes>
	<cftry>
		<cfset Get_Notes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("broker_action_plan_notes", {
				"broker_action_plan_id" = "eq.#URL.APID#",
				"order" = "date_of_note.desc"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetNotes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetNotes>
	<CFQUERY NAME="Get_Notes" datasource="#application.datasource#">
		Select	*
		From	Broker_Action_Plan_Notes
		Where	Broker_Action_Plan_ID	=	#URL.APID#
		Order by	Date_of_Note desc
	</CFQUERY>
</cfif>

<!--- Get the product data --->
<cfset useLakebaseForGetProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("broker_action_plan_products")>
<cfif useLakebaseForGetProducts>
	<cftry>
		<cfset Get_Products = application.oLakebase.toQuery(
			application.oLakebase.selectRows("broker_action_plan_products", { "broker_action_plan_id" = "eq.#URL.APID#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetProducts>
	<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
		Select	*
		From	Broker_Action_Plan_Products
		Where	Broker_Action_Plan_ID	=	#URL.APID#
	</CFQUERY>
</cfif>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<FIELDSET STYLE="padding: 5px;">
<legend style="color:Navy; font-weight: bold; font-size: 14px;">Broker Plan</legend>

	<TABLE CLASS="MainTable" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
			<TR VALIGN="bottom" BGCOLOR="FFCE84">
				<TD WIDTH="120"><SPAN CLASS="title2">Plan Number</SPAN></TD>
				<TD WIDTH="350"><SPAN CLASS="title2"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name</SPAN></TD>
				<TD WIDTH="150"><SPAN CLASS="title2">Creation Date...</SPAN></TD>
				<TD><SPAN CLASS="title2">Plan created by...</SPAN></TD>
			</TR>
		<CFOUTPUT>
			<TR VALIGN="top">
				<TD>#Get_Plan_Data.Broker_Action_Plan_ID#</TD>
				<TD>#Get_Operator_Name.Operator_Name#</TD>
				<TD>#dateformat(Get_Plan_Data.Date_Created_On, 'mm/dd/yyyy')#</TD>
				<TD>#Get_User_Name.Name_First# #Get_User_Name.Name_Last#</TD>
			</TR>
		</CFOUTPUT>
	</TABLE>

</fieldset>

<BR>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<FIELDSET STYLE="padding: 5px;">
<legend style="color:Navy; font-weight: bold; font-size: 14px;">Broker Plan Products</legend>

	<TABLE BORDER="0" CLASS="MainTable" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
			<TR VALIGN="bottom" BGCOLOR="FFCE84">
				<TD WIDTH="120"><SPAN CLASS="title2">UPC</SPAN></TD>
				<TD WIDTH="350"><SPAN CLASS="title2">Description</SPAN></TD>
				<TD WIDTH="150"><SPAN CLASS="title2">Weekly Volume</SPAN></TD>
				<TD><SPAN CLASS="title2">Unit of Measure</SPAN></TD>
				<TD><SPAN CLASS="title2">Purchasing Status</SPAN></TD>
			</TR>
		<CFOUTPUT QUERY="Get_Products">
		
		
		<!--- Get the name of the product --->
		<CFQUERY NAME="Get_Product_Name" datasource="#application.datasource#">
			Select	Description
			From	BSA_Foodservice_Items_Master
			Where	UPC	=	'#Product_UPC#'
		</CFQUERY>

			<TR VALIGN="top" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD>#Product_UPC#&nbsp;</TD>
				<TD>#Get_Product_Name.Description#&nbsp;</TD>
				<TD>#Product_Week_Volume#&nbsp;</TD>
				<TD>#Product_UOM#&nbsp;</TD>
				<TD><CFIF Product_Purchasing_Status eq 1>Active<CFELSE>Inactive</CFIF></TD>
			</TR>
		</CFOUTPUT>
	</TABLE>

</fieldset>

<BR>

<FORM ACTION="add_notes.cfm" METHOD="post" NAME="MyForm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<FIELDSET STYLE="padding: 5px;">
<legend style="color:Navy; font-weight: bold; font-size: 14px;">Broker Plan Notes</legend>
	<TABLE CLASS="MainTable" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
		<TR VALIGN="bottom" BGCOLOR="FFCE84">
			<TD WIDTH="120"><SPAN CLASS="title2">Date</SPAN></TD>
			<TD><SPAN CLASS="title2">Notes/Comments</SPAN></TD>
		</TR>
	<CFOUTPUT QUERY="Get_Notes">
	<TR VALIGN="top" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD WIDTH="120">#dateformat(Date_of_Note, 'mm/dd/yy')#</TD>
			<TD>#Broker_Action_Plan_Notes#&nbsp;</TD>
		</TR>
	</CFOUTPUT>
	</TABLE>


	
<CF_openLayer
	Border="No"
	BorderSize="0"  
	BorderColor="silver"  
	Title=""  
	TitleClosed="+ add a note to this plan +"
	TitleTooltip="Click here to toggle selections"  
	TitleColor="Blue"  
	TitleFont="Arial"
	TitleSize="8"
	IsClosed="Yes"
	Width="96%">	

		<INPUT TYPE="hidden" NAME="Broker_Action_Plan_ID" VALUE="<CFOUTPUT>#URL.APID#</CFOUTPUT>">
		<TABLE WIDTH="100%">
		<TR>
			<TD VALIGN="top" WIDTH="120">
				<!--- <CFOUTPUT>#dateformat(now(), 'mm/dd/yy')#</CFOUTPUT><BR> --->
				<B>
				<FONT SIZE="2" COLOR="Red">[</FONT>
				<A HREF="javascript:checkData();">save this note</A>
				<FONT SIZE="2" COLOR="Red">]</FONT>
				</B>
			</TD>
			<TD VALIGN="top"><TEXTAREA ROWS="8" NAME="Broker_Action_Plan_Notes" STYLE="width:100%;"></TEXTAREA>
		</TR>
		</TABLE>
</CF_openLayer>
	
</fieldset>


	</FORM>		

	
<FIELDSET STYLE="padding: 5px; border: solid 1px white;">


<FORM ACTION="index6.cfm" METHOD="post" Name="MyForm2" ID="MyForm2">


<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="APID" VALUE="#URL.APID#">
	<INPUT TYPE="hidden" NAME="PRID" VALUE="#valuelist(Get_Products.Product_UPC)#">
</CFOUTPUT>


<TABLE WIDTH="100%">
<TR>
	<TD ALIGN="left">
		<CF_button
			button_name		=	""
			button_caption	=	"edit this plan"
			button_action	=	"javascript:document.all.MyForm2.submit();"
			button_type		=	"link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold">
	</TD>
	<TD ALIGN="right">
		<CF_button
			button_name		=	""
			button_caption	=	"view all plans"
			button_action	=	"index.cfm"
			button_type		=	"link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold">
	</TD>
</TR>
</TABLE>
</FORM>



</fieldset>	
	
	
</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>


