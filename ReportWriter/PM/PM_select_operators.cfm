<CFIF isdefined("URL.FormName")>
	<FORM ACTION="pm_select_operators.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
	</FORM>
	<script>
		if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null){
			this.document.all.FinalItemList.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.Operator_List.value
			document.all.MyForm.submit()
		}
		else{
			alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
			window.close()
		}
	</script>
	<cfabort>
</CFIF>



<CFPARAM NAME="URL.CID" DEFAULT="">

<CFIF len(trim(URL.CID)) GT 0>

	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
	<cfquery name="GetContractInfo" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#cryp.value#'
	</cfquery>

	<!--- Do not show the tabs if the contract is approved --->
	<CFIF GetContractInfo.Contract_Status_Type_IDX GT 2>
		<script>
			history.back();
		</script>

		<CFABORT>
	</CFIF>	
</CFIF>


<CFSET PAGE_TITLE="Select Program <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>">
<CFSET GROUP="Contracts">




<CFPARAM name="FORM.button_caption"					default="continue">
<CFPARAM NAME="FORM.searchstring" DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedOperators"	Default="1">

<CFPARAM NAME="FORM.OPERATOR_NAME" DEFAULT="">
<CFPARAM NAME="FORM.OPERATOR_DBA" DEFAULT="">
<CFPARAM NAME="FORM.OPERATOR_CITY" DEFAULT="">
<CFPARAM NAME="FORM.Operator_Type" DEFAULT="">
<CFPARAM NAME="FORM.Operator_Location_Type" DEFAULT="">
<CFPARAM NAME="FORM.Operator_State" DEFAULT="">


<CFPARAM NAME="StartRow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=10>


<CFSET FORM.LoadSavedOperators=0>

<CFSET listofitemstodelete = "">

<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF listfind(FORM.SelectedITEMS, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedITEMS#" DELIMITERS=",">
	<CFIF listfind(Form.FinalItemList, ListItem, ",") EQ 0>
		<CFSET Form.FinalItemList = listappend(FinalItemList, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(FORM.FinalItemList,ListItem, ",") GT 0>
		<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>

<CFIF FORM.finishedselectingitems EQ 1>
	<script>
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Operator_List.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit()
		window.close()		
	</script>
	<CFABORT>
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT>
		var operatorWindow = null
		function createOperator(){
			var winl = (screen.width - 435) / 2;
			var wint = (screen.height - 550) / 2;
			operatorWindow = window.open("/profiles/operators/Operator_Creation_Entry_Form_Stripped.cfm","opWindow",
    "height=500,width=660,status=no,toolbar=no,menubar=no,location=no,left="+winl+",top="+wint);
		}
		
		function doSearch(){
			if(operatorWindow != null) {
				if(confirm("Press OK to Close The <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Creation Window or CANCEL to Return To It.")){
					operatorWindow.close();
					restricted_Operator_Search();
				}
				else{
					operatorWindow.focus();
				}
			}
			else{
				restricted_Operator_Search();
			}
		}
	function restricted_Operator_Search()
	{
		var searchForm = document.MyForm;
		var any_Filter = false;
		
		if(searchForm.Operator_Type.value.toUpperCase() != "ALL")
		{
			any_Filter = true;
		}
		if(searchForm.Operator_Location_Type.value.toUpperCase() != "ALL")
		{
			any_Filter = true;
		}
		if(searchForm.Operator_State.value.toUpperCase() != "ALL")
		{
			any_Filter = true;
		}
		if(any_Filter)
		{
			searchForm.submit();
		}
		else
		{
			alert("you have to select atleast one of the following filters\n - Type of Operator\n - Location Type\n - State");
		}
	}
	
	function verifySave(){
		document.all.finishedselectingitems.value = 1;
		MyForm.submit();	
	}

	</SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="20" TOPMARGIN="0">

<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is help file that goes with this content													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	


	<FORM ACTION="PM_select_operators.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">
<BR><B>
<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue">
	<A HREF="/help_files/manual/projects/new.cfm#Operators" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Summary">
	read me first
	</A>
</FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>
	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> search</LEGEND>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Location_Type														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Operator_Location_Type" datasource="#application.datasource#">
Select	distinct Operator_Location_Type
From	BSA_Operator
Where	deleted = 0
</CFQUERY>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Type																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
   <!---------------------------------------------------------------------------- 
    Dev Notes: D19761 -Anand Rao 07/28/09
    Changed to query to have a where clause to look for active = 1 and 
    Deleted = 0 and pick the records from awayx_Operator_type table
 ------------------------------------------------------------------------------>
<CFQUERY NAME="Get_Operator_Type" datasource="#application.datasource#">
  SELECT	Distinct Operator_Type
  FROM awayX_Operator_Type
  WHERE Active = 1 AND Deleted = 0
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the states																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_States" datasource="#application.datasource#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>



 <TABLE>
<TR>
	<TD>
		<B><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name:</B><BR>
		<INPUT TYPE="text" NAME="Operator_Name" STYLE="width:	200px; font-size: 10px;" VALUE="<CFOUTPUT>#FORM.Operator_Name#</CFOUTPUT>">
	</TD>
	<TD>
		<B>Doing business as:</B><BR>
		<INPUT TYPE="Text" NAME="Operator_DBA" MAXLENGTH="510" STYLE="width:	200px; font-size: 10px;" VALUE="<CFOUTPUT>#FORM.Operator_DBA#</CFOUTPUT>">
	</TD>
	<TD>
		<B>City:</B><BR>
		<INPUT TYPE="Text" NAME="Operator_City" MAXLENGTH="510" STYLE="width:	200px; font-size: 10px;" VALUE="<CFOUTPUT>#FORM.Operator_City#</CFOUTPUT>">
	</TD>
</TR>
<TR>
	<TD>
		<B>Type of <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>:</B><BR>
		<SELECT NAME="Operator_Type" STYLE="width:	200px; font-size: 10px;">
		<OPTION VALUE="All" SELECTED>Select <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Type</OPTION>
		<OPTION VALUE="All">All types</OPTION>
		<CFOUTPUT QUERY="Get_Operator_Type"><OPTION VALUE="#Operator_Type#" <CFIF FORM.Operator_Type EQ Get_Operator_Type.Operator_Type>selected</CFIF>>#Operator_Type#</OPTION></CFOUTPUT>
		</SELECT>
	</TD>
	<TD>
		<B>Location Type:</B><BR>
		<SELECT NAME="Operator_Location_Type" STYLE="width:	200px; font-size: 10px;">
		<OPTION VALUE="All" SELECTED>Select Location Types</OPTION>
		<OPTION VALUE="All">All Location Types</OPTION>
		<CFOUTPUT QUERY="Get_Operator_Location_Type"><OPTION VALUE="#Operator_Location_Type#" <CFIF FORM.Operator_Location_Type EQ Get_Operator_Location_Type.Operator_Location_Type>selected</CFIF>>#Operator_Location_Type#</OPTION></CFOUTPUT>
		</SELECT>	
	</TD>
	<TD>
		<B>State:</B><BR>
		<SELECT NAME="Operator_State" STYLE="width:	200px; font-size: 10px;">
		<OPTION VALUE="All" SELECTED>Select State</OPTION>
		<OPTION VALUE="All">Any State</OPTION>
		<CFOUTPUT QUERY="Get_States"><OPTION VALUE="#State_Code#" <CFIF FORM.Operator_State EQ Get_States.State_Code>selected</CFIF>>#State_Name#</OPTION></CFOUTPUT>
		</SELECT>	
	</TD>
</TR>
<TR>
	<TD NOWRAP ALIGN="left">
	<B>Sort By:</B><BR>
	<CFSET sort_By_List="Operator Name,Location Type,City,State,Doing Business As">
	<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListFirst(sort_By_List))#">
	<CFOUTPUT>
	<CFSET sort_By_List=ListSort(sort_By_List,"Text")>	
	<SELECT ID="sort_by" NAME="sort_by" STYLE="width:	200px; font-size: 10px;">
	<CFLOOP LIST="#sort_By_List#" INDEX="thisItem">
		<CFSET thisItem=Trim(thisItem)>
		<OPTION VALUE="#thisItem#"<CFIF thisItem EQ FORM.sort_by> SELECTED</CFIF>>#thisItem#</OPTION>
	</CFLOOP>
	</SELECT>
	</CFOUTPUT>
	</TD>
	<TD NOWRAP ALIGN="left">
	<B>Order:</B><BR>
	<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC1">
	<SELECT ID="sort_Order" NAME="sort_Order" STYLE="width:	200px; font-size: 10px;">
		<OPTION VALUE="ASC"<CFIF FORM.sort_Order EQ "ASC"> SELECTED</CFIF>>Ascending</OPTION>
		<OPTION VALUE="DESC"<CFIF FORM.sort_Order EQ "DESC"> SELECTED</CFIF>>Descending</OPTION>
	</SELECT>
	</TD>
</TR>
</TABLE>

<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="center">
	<TR>
		<!------<TD ALIGN="left"><INPUT type="button" value="Search Operators" ONCLICK="doSearch()"></TD>----->
		<TD ALIGN="left" NOWRAP>
		<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
		&nbsp;&nbsp;
		<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript:doSearch();">search <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput></a><FONT COLOR="#FF0000">]</FONT></B>
		</TD>
	</TR>
</TABLE>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---><!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---> 
 
 		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	
	</FIELDSET>

<BR>

	<CFQUERY NAME="GetOperatorInfo" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Operator
		WHERE BSA_Operator_ID <CFIF len(FORM.FinalItemList) EQ 0>!= BSA_Operator_ID<CFELSE>IN(#FORM.FinalItemList#)</CFIF>
	</CFQUERY>
	
	<CFSCRIPT>
		Border="Yes";
		BorderSize=1;  
		BorderColor="Silver";
		Image="/images/plus3.gif";
		ImageOpen="/images/minus3.gif";
		TitleColor="Navy"; 
		TitleFont="Arial";
		TitleSize=8;
		IsClosed="No";  
		WIDTH="100%";
	</CFSCRIPT>
	
		<CFSET Open_Layer_Caption = "currently selected <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>">
		<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Hide #Open_Layer_Caption#"  
				TitleClosed="Show #Open_Layer_Caption#"  
				TitleTooltip="#Open_Layer_Caption#"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="Yes"
				Width="#width#">
	
			<CFIF GetOperatorInfo.recordcount GT 0>
				
				<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="700" BGCOLOR="white">
					<TR><CFOUTPUT QUERY="GetOperatorInfo">
						<TD NOWRAP BGCOLOR="eeeeee">#GetOperatorInfo.operator_name#<BR>#Operator_City# - #Operator_State#</TD>
		 				<CFIF GetOperatorInfo.currentrow mod 4><CFELSE></TR><TR></CFIF>
					</CFOUTPUT>	
				</TABLE>
			<CFELSE>
				<CFIF FORM.FinalItemList EQ "ALL"><B>ALL <cfoutput>#UCASE(application.returned_customer_setting.operator_label_plural)#</cfoutput></B><CFELSE><B>NONE</B></CFIF>
			</CFIF>
			<BR>
		</CF_openLayer>


<CFIF isdefined("FORM.DOSEARCH")>

	<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	 <br><br><br>
	 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
	 <br><br><br>
	</SPAN>
	<CFFLUSH>
	<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
	</SCRIPT>

	<CFSET form.searchstring = trim(form.searchstring)>

	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---><!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->



<CFSET sql_Sort_By="Operator_Name">
<CFSWITCH expression="#Form.sort_by#">
	<CFCASE value="Operator Name">
		<CFSET sql_Sort_By="Operator_Name">
	</CFCASE>
	<CFCASE value="Location Type">
		<CFSET sql_Sort_By="Operator_Location_Type">
	</CFCASE>
	<CFCASE value="City">
		<CFSET sql_Sort_By="Operator_City">
	</CFCASE>
	<CFCASE value="State">
		<CFSET sql_Sort_By="Operator_State">
	</CFCASE>
	<!------<CFCASE value="Number of Locations">
		<CFSET sql_Sort_By="Operator_Number_Of_Locations">
	</CFCASE>	----->
	<CFCASE value="Doing Business As">
		<CFSET sql_Sort_By="Operator_DBA">
	</CFCASE>
</CFSWITCH>

<CFSET sql_Sort_By_Order=" ASC">
<CFIF Form.sort_Order EQ "DESC">
	<CFSET sql_Sort_By_Order=" DESC">
</CFIF>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve operators																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="TheQuery" datasource="#application.datasource#">

Select		*

From		BSA_Operator

Where		deleted = 0
			<CFIF Operator_State NEQ "All">
				and
				Operator_State	=	'#Operator_State#'
			</CFIF>

			<CFIF Operator_Type NEQ "All">
				and
				Operator_Type	=	'#Operator_Type#'
			</CFIF>
			
			<CFIF Operator_Location_Type NEQ "All">
				and
				Operator_Location_Type	=	'#Operator_Location_Type#'
			</CFIF>
			
			<CFIF trim(Operator_Name) NEQ "">
				and
				(
					Operator_Name 	like 	'%#Operator_Name#%'
					or
					Operator_Name 	like 	'#Operator_Name#%'
					or
					Operator_Name 	like 	'%#Operator_Name#'
					or
					Operator_Name 	=	 	'#Operator_Name#'
				)
			</CFIF>
			
			<CFIF trim(Operator_City) NEQ "">
				and
				(
					Operator_City 	like 	'%#Operator_City#%'
					or
					Operator_City 	like 	'#Operator_City#%'
					or
					Operator_City 	like 	'%#Operator_City#'
					or
					Operator_City 	like 	'#Operator_City#'
				)
			</CFIF>

			<CFIF trim(Operator_DBA) NEQ "">
				and
				(
					Operator_DBA 	like 	'%#Operator_DBA#%'
					or
					Operator_DBA 	like 	'#Operator_DBA#%'
					or
					Operator_DBA 	like 	'%#Operator_DBA#'
					or
					Operator_DBA 	like 	'#Operator_DBA#'
				)
			</CFIF>

--ORDER BY 	Operator_Name
ORDER BY #sql_Sort_By# #sql_Sort_By_Order#

</CFQUERY>

<SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		function CA() {
			if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many operators in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
				for (var i=0;i<MyForm.elements.length;i++)
					{
						var e = MyForm.elements[i];
						if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
							e.checked = MyForm.allbox.checked;
						}
					}
			//toggleRowColors()
			}
			else {
				document.all.allbox.checked = false;
			}
		}
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</SCRIPT>
	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput><CFELSE><cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput></CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
		
			<!----<CFIF TheQuery.recordcount GTE 500>---->
			<CFIF 1 EQ 2>
				<FONT SIZE="3"><B>Your query returned more than 500 records. Please narrow your search.</B></FONT>
			<CFELSE>
			
				<TABLE border="0" cellspacing="0" cellpadding="2" align="center" CLASS="Maintable" width="100%">
					<TR ID="header" BGCOLOR="#ffce84">
						<TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Operators"></TD>
						<TD ID="header" align="left" NOWRAP><B><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name</B></TD>
						<!--- <TD align="left">Type</TD> --->
						<TD ID="header" align="left" WIDTH="150" NOWRAP><B>Location <WBR>Type</B></TD>
						<TD ID="header" align="left" WIDTH="100" NOWRAP><B>City <WBR>State</B></TD>
						<TD ID="header" align="left" WIDTH="100" NOWRAP><B># of <WBR>Locations</B>&nbsp;</TD>
						<TD ID="header" align="left" VALIGN="bottom" WIDTH="30%" NOWRAP><B>Doing Business As</B></TD>
	
					</TR>

				<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				
					<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> style="cursor: hand;">
						<TD align="center"><INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Operator_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Operator_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Operator_ID), ",")></CFIF>></TD>
						<TD NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.operator_name#</TD>
						<!--- <TD>#TheQuery.operator_type#&nbsp;</TD> --->
						<TD NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.Operator_Location_Type#&nbsp;</TD>
						<TD NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.Operator_City# - #TheQuery.Operator_State#&nbsp;</TD>
						<TD NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#numberformat(TheQuery.Operator_Number_Of_Locations,'_,___,___')#&nbsp;</TD>
						<TD onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.Operator_DBA#&nbsp;</TD>
	 				</TR>
					<cfflush>
				</CFOUTPUT>
				</TABLE>
				

				<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
					<CF_Next_Previous_For_Forms
					formname="MyForm"
					query="TheQuery"
					maxpages="40"
					previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
					next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
					previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
					nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
					addparams="">
				</DIV>

			</CFIF>
			
			
		</CFIF>
	</FIELDSET>	
</CFIF>

	<CFPARAM name="TheQuery.Recordcount" default="0">
	<SCRIPT>
		function resetform() {
			document.all.FinalItemList.value = 0;
			document.all.AlreadySelectedItems.value = 0;
		
			<CFIF TheQuery.Recordcount GT 0>
				document.all.SelectedITEMS.value = 0;
				for(var x=0; x<document.all.MyForm.elements.length;x++) {
					document.all.MyForm.elements[x].checked = false
				}
				
			</CFIF>
			document.all.MyForm.submit();
		}
	</SCRIPT>

<INPUT TYPE="hidden" NAME="ParentFormname" 						VALUE="<CFOUTPUT>#FORM.ParentFormname#</CFOUTPUT>">	
<INPUT TYPE="hidden" NAME="FinalItemList" VALUE="<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="<CFOUTPUT>#Form.AlreadySelectedItems#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="finishedselectingitems" VALUE="0">
<INPUT TYPE="hidden" NAME="LoadSavedOperators" VALUE="0">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="<CFOUTPUT>#startrow#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="<CFOUTPUT>#frompage#</CFOUTPUT>">	
</FORM>
	<cfif TheQuery.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"> import selected <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>

	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: hand;" onClick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"> import all returned <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: hand;" onClick="removeAllProducts()"> remove all selected <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>	
	</DIV>
	<BR>
	</cfif> 


<SCRIPT>
	<cfif TheQuery.recordcount GT 0>
		function importAllProducts(recordcount){
			<!------//recordcount = <CFOUTPUT>#ListLen(whole_Product_List)#</CFOUTPUT>;----->
			if(parseInt(recordcount) == 1) pString = "Product";
			else pString = "Products";
			
			if(confirm("Do you want to import all " + recordcount + " records from your search?")){
				document.all.allbox.checked = true;
				document.all.allbox.fireEvent("onclick");
				
				document.MyForm.finishedselectingitems.value = 1;
				if(document.MyForm.FinalItemList.value.length > 0){
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(TheQuery.BSA_Operator_ID)#</CFOUTPUT>";
					<!------//document.SearchForm.FinalUPCList.value 	= document.SearchForm.FinalUPCList.value + "," + "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";
					//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";----->
				}
				else{
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(TheQuery.BSA_Operator_ID)#</CFOUTPUT>";
					<!------//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";----->
				}
	
				document.MyForm.submit();
			}
			else
			{
			
			}
		}
		
		function removeAllProducts(){
			
			if(confirm("By pressing OK all selected records will be unselected")){
				document.all.allbox.checked = false;
				document.all.allbox.fireEvent("onclick");
				
				document.MyForm.finishedselectingitems.value = 0;
				document.MyForm.FinalItemList.value 	= "";
				document.MyForm.AlreadySelectedItems.value 	= "";
			}
			else
			{
			
			}
		}	
		
		function finishedSearching() {
			document.all.finishedselectingitems.value = 1
			document.all.MyForm.submit();
		}	
	</cfif>
</SCRIPT>
<SCRIPT>
	//load the name of the select boxes to hide
	//findselectboxes()	
</SCRIPT>
