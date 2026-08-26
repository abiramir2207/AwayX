<!---
	Name: contract_attachments.cfm
	Copyright (c) 2006 Blacksmith Applications, Inc.
	Description:
		logic for document attachments
	Created By: Ben Densmore 6/25/2007
	Purpose: filtering welcome_letters from this display.
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<CFSET PAGE_TITLE="Attachments">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.CID" 	DEFAULT="">
<cfparam name="file_name" default="">
<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Sales_Agreement_ID = temp>
<CFSET CSL_CallingPageCode = "at">
<CFSET FORM.Sales_Agreement_ID = cryp.value>
<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="Sales_Agreement_Status_legend.cfm"></div>
 <cfelse>
<CFINCLUDE TEMPLATE="Sales_Agreement_Status_legend.cfm">
</cfif>

<BLOCKQUOTE>
<cfif application.programlayout EQ 1>
 <div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 150px; top: 10px;"></cfif>
<!------
<cfquery name="GetContractInfo" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Main
	WHERE Contract_Main_ID = #cryp.value#
</cfquery>

	<HR COLOR="Blue" SIZE="1" WIDTH="800" ALIGN="left">


	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="800">
		<TR BGCOLOR="#ffce84">
			<TD align="right" nowrap><FONT SIZE="3">Contract Number: </FONT></TD>
			<TD WIDTH="100%"><B><FONT SIZE="3"><cfoutput>#GetContractInfo.Contract_Number#</cfoutput></FONT></B></TD>
		</TR>
	</TABLE>

	<HR COLOR="Blue" SIZE="1" WIDTH="800" ALIGN="left">
 ----->

 <!--- <cfinclude template="minimal_contract_info.cfm"> --->

<!---  <cfinclude template="Contract_Documents_Menu.cfm"> --->




<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>

<CFPARAM NAME="FORM.formcheck" 	DEFAULT="0">
<CFPARAM NAME="FORM.Doc_ID" DEFAULT="">
<CFPARAM NAME="FORM.Doc_Desc" DEFAULT="">
<CFPARAM NAME="FORM.This_Page_List" 	DEFAULT="">

<CFQUERY NAME = "Current_sel" DATASOURCE = "#Application.Datasource#">
	SELECT 		contract_attachments.doc_ID Doc_ID,document_details.*
	FROM 		contract_attachments
	INNER JOIN 	document_details ON contract_attachments.doc_id = document_details.doc_ID
				AND	(	(	Public_View = 1
						AND User_Position_ID IN (#Preservesinglequotes(Access_Position_List)#)
						)
						OR Public_View = 0
					)
	WHERE 		contract_attachments.Export_Sales_Agreement_ID = '#trim(FORM.Sales_Agreement_ID)#'
				AND contract_attachments.DELETED = 0
</CFQUERY>

<CFSET Current_Selection_List = ValueList(Current_sel.doc_iD)>
<CFIF isDefined("FORM.Current_Selection_List")>
	<CFSET Current_Selection_List = FORM.Current_Selection_List>
</CFIF>



<!---- Loop thru the existing items to delete the unchecked ones ---->
<CFLOOP LIST="#FORM.This_Page_List#" INDEX="Existing_Doc_ID">
	<CFIF NOT ListFindNoCase(FORM.Doc_ID, Existing_Doc_ID, ",")>
		<CFSET Current_Selection_List_Index = ListFindNoCase(Current_Selection_List, Existing_Doc_ID, ",")>
		<CFIF Current_Selection_List_Index GT 0>
			<CFSET Current_Selection_List = ListDeleteAt(Current_Selection_List, Current_Selection_List_Index, ",")>
		</CFIF>
	</CFIF>
</CFLOOP>

<!---- Loop thru the check box to add the newly added items ---->
<CFLOOP LIST="#FORM.Doc_ID#" INDEX="Check_Doc_ID">
	<CFIF NOT ListFindNoCase(Current_Selection_List, Check_Doc_ID, ",")>
		<CFSET Current_Selection_List = ListAppend(Current_Selection_List, Check_Doc_ID, ",")>
	</CFIF>
</CFLOOP>

<CFIF FORM.formcheck EQ "1">
	<cfset useLakebaseForupdate_del = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForupdate_del>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_attachments",
			{
				"export_sales_agreement_id" = "eq.#FORM.Sales_Agreement_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdate_del = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdate_del>
<CFQUERY NAME="update_del" DATASOURCE="#Application.Datasource#">
		UPDATE Contract_Attachments SET deleted = 1 WHERE Export_Sales_Agreement_ID = '#FORM.Sales_Agreement_ID#'
	</CFQUERY>
</cfif>


	<CFLOOP LIST="#Current_Selection_List#" INDEX="loop">
	<CFOUTPUT>
		<cfset useLakebaseForinsert_selection = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForinsert_selection>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_attachments", {
			"doc_id" = "#loop#",
			"export_sales_agreement_id" = "#FORM.Sales_Agreement_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsert_selection = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsert_selection>
<CFQUERY NAME = "insert_selection" DATASOURCE = "#Application.Datasource#">
			INSERT INTO Contract_Attachments(Doc_Id,Export_Sales_Agreement_ID) VALUES ('#loop#',#FORM.Sales_Agreement_ID#)
		</CFQUERY>
</cfif>
	</CFOUTPUT>
	</CFLOOP>
	<CFIF IsDefined("FORM.DeleteDocList")>
		<CFLOOP LIST="#FORM.DeleteDocList#" INDEX="LoopDelete">
			<CFQUERY NAME="" DATASOURCE="#Application.Datasource#">
				UPDATE Contract_Attachments SET deleted = 1 WHERE Export_Sales_Agreement_ID = '#FORM.Sales_Agreement_ID#' AND Doc_Id = '#LoopDelete#'
			</CFQUERY>
		</CFLOOP>
	</CFIF>
	<cflocation url="Sales_Agreement_Edit_Menu.cfm?CID=#URL.CID#">
</CFIF>


<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
	function ConfirmDelete()
	{
		document.FormAttach.formcheck.value = "1";
		document.FormAttach.submit()
	}
	function DeleteTool(DocID,action,currentRow)
	{
		var cellObj = eval("document.all.Delete_"+currentRow);
		var trObj = eval("document.all.TR_Delete_"+currentRow);
		var deleteIdArray = new Array()
		var ArrayValue = document.all.DeleteDocList.value;

		if (document.all.DeleteDocList.value != "")
		{
			deleteIdArray = ArrayValue.split(",");
		}

		if (action == 1)
		{
			if (document.all.DeleteDocList.value == "")
			{
				document.all.DeleteDocList.value = DocID;
			}
			else
			{
				document.all.DeleteDocList.value = document.all.DeleteDocList.value +","+DocID;
			}
			action = 0;
			cellObj.innerHTML = "<A HREF=\"Javascript: DeleteTool('"+DocID+"',"+action+","+currentRow+")\"><img src='/images/undo.gif' alt='Restore document' border='0'></A>";
			trObj.style.background = "c0c0c0";
		}
		else if (action == 0)
		{
			deleteIdArray = ArrayDeleteItem(deleteIdArray, DocID);
			if (deleteIdArray.length == 0)
			{
				document.all.DeleteDocList.value = "";
			}
			for (i=0;i<deleteIdArray.length;i++)
			{
				if (i == 0)
				{
					document.all.DeleteDocList.value = deleteIdArray[i];
				}
				else
				{
					document.all.DeleteDocList.value = document.all.DeleteDocList.value +","+deleteIdArray[i];
				}
			}
			action = 1;
			cellObj.innerHTML = "<A HREF=\"Javascript: DeleteTool('"+DocID+"',"+action+","+currentRow+")\"><img src='/Images/scissor.gif' width='14' height='9' alt='Remove document' border='0'></A>";
			if ((currentRow%2) == 0)
			{
				trObj.style.background = "C6FFC6";
			}
			else
			{
				trObj.style.background = "";
			}
		}

		if	(document.all.DeleteDocList.value == "")
		{
			document.all.TR_Confirm.style.display = "none";
		}
		else
		{
			document.all.TR_Confirm.style.display = "";
		}
	}
	function selectChange(thisobj)
	{
		var bShow = "none";
		if(thisobj.value == "Between")
		{
			bShow = "";
		}

		document.all.SP_To_Date.style.display = bShow;
		if(bShow == "")
		{
			//document.all.To_Date.focus();
		}
		else if(thisobj.value != "")
		{
			document.all.From_Date.focus();
		}
		else
		{
			document.all.From_Date.value = "";
		}
	}
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
	function validate()
	{
		x=document.FormAttach;
		/*var today = new Date;
		var dateString = (today.getMonth() + 1) + "/" + today.getDate() + "/" + today.getFullYear();*/
		if (x.From_Date.value != "")
		{
			if(x.Comp_Operator.value == "")
			{
				alert("Please select comparison <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>");
				x.Comp_Operator.focus();
				return false;
			}
		}
		if (x.Comp_Operator.value == "Between")
		{
			if (x.From_Date.value == "")
			{
				alert("Please enter two date value");
				x.From_Date.focus();
				return false;
			}
			if (x.To_Date.value == "")
			{
				alert("Please enter two date values if you select BETWEEN comparison <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>");
				x.To_Date.focus();
				return false;
			}
			if(checkDate(x.To_Date.value, x.today1.value)>=1)
			{
				alert("DATE cannot be more than todays date");
				x.To_Date.focus();
				return false;
			}
			if(checkDate(x.To_Date.value,x.From_Date.value)<0)
			{
				alert("Please make the FIRST DATE less than or equal to SECOND DATE");
				x.From_Date.focus();
				return false;
			}

		}
		if(checkDate(x.From_Date.value, x.today1.value)>=1)
		{
			alert("DATE cannot be more than todays date");
			x.From_Date.focus();
			return false;
		}
		x.submit();
		return false;
	}


	function sort_by_this_order(fieldName, sOrder)
	{
		var oForm = document.FormAttach;
		oForm.SORT_BY.value = fieldName;
		oForm.SORT_ORDER.value = sOrder;
		oForm.submit();
		return false;
	}

	function selectAll(thisobj)
	{
		var bCheck = thisobj.checked;
		var chObjs = document.all.Doc_ID;
		if(chObjs.length)
		{
			var chObjLen = chObjs.length;
			var i;
			for(i=0;i<chObjLen;i++)
			{
				chObjs[i].checked = bCheck;
			}
		}
		else
		{
			chObjs.checked = bCheck;
		}

	}


	function save_Documents()
	{
		document.FormAttach.formcheck.value = "1";
		document.FormAttach.submit();
	}

	function reset_Form_Fields()
	{
		resetSelect("Doc_type");
		resetSelect("Doc_Family");
		resetSelect("Uploaded_By");
		resetSelect("Comp_Operator");
		//resetSelect("To_Date");
		//document.all.curr_symbol.selectedIndex = 0;
		document.all.To_Date.value = "";
		document.all.Doc_Title.value = "";
	}

	function resetSelect(selName)
	{
		var sObj = document.getElementById(selName);
		if(sObj)
		{
			sObj.selectedIndex = 0;
			sObj.fireEvent('onchange');
		}
	}
</SCRIPT>
<!---Comp_Operator    --->
<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>



<SCRIPT>

function checkDate(dateStr1,dateStr2)
{
	var dateSplit;
	var retVal = null;
	dateSplit = dateStr1.split("/");
	if(dateSplit)
	{
		if(dateSplit.length > 2)
		{
			var date1 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
			dateSplit = dateStr2.split("/");
			if(dateSplit)
			{
				if(dateSplit.length > 2)
				{
					var date2 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
					retVal = days_between(date1, date2, true);
				}
			}
		}
	}
return retVal;
}
</SCRIPT>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

<CFPARAM NAME="URL.SORT_BY" 	DEFAULT="">
<CFPARAM NAME="URL.SORT_ORDER" 	DEFAULT="ASC">

<CFPARAM NAME="URL.Doc_Type" 		DEFAULT="">
<CFPARAM NAME="URL.Doc_Family" 		DEFAULT="">
<CFPARAM NAME="URL.uploaded_by" 	DEFAULT="">
<CFPARAM NAME="URL.Comp_Operator" 	DEFAULT="">
<CFPARAM NAME="URL.From_Date" 		DEFAULT="">
<CFPARAM NAME="URL.To_Date" 		DEFAULT="">
<CFPARAM NAME="URL.Doc_Title" 		DEFAULT="">
<CFPARAM NAME="url.docid"            default="">

<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="#URL.SORT_BY#">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="#URL.SORT_ORDER#">

<CFPARAM NAME="FORM.Doc_Type" 		DEFAULT="#URL.Doc_Type#">
<CFPARAM NAME="FORM.Doc_Family" 	DEFAULT="#URL.Doc_Family#">
<CFPARAM NAME="FORM.uploaded_by" 	DEFAULT="#URL.uploaded_by#">
<CFPARAM NAME="FORM.Comp_Operator" 	DEFAULT="#URL.Comp_Operator#">
<CFPARAM NAME="FORM.From_Date" 		DEFAULT="#URL.From_Date#">
<CFPARAM NAME="FORM.To_Date" 		DEFAULT="#URL.To_Date#">
<CFPARAM NAME="FORM.Doc_Title" 		DEFAULT="#URL.Doc_Title#">


<FORM ACTION="Sales_Agreement_attachments.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" METHOD="post" NAME="FormAttach" STYLE="DISPLAY:INLINE">
	<cfparam name="FORM.startrow"  default="1">
   <CFPARAM NAME="FORM.frompage"   DEFAULT="1">
   <cfparam name="FORM.pageLength"  default=10>
   <CFSET startrow=FORM.startrow>
   <CFSET frompage=FORM.frompage>
   <cf_Number_of_Rows maxrows="#FORM.pageLength#">
   <CFOUTPUT>
   	<INPUT TYPE="hidden" NAME="formcheck" VALUE="0">
	<INPUT TYPE="hidden" VALUE = "#Current_Selection_List#" NAME="Current_Selection_List">
   	<INPUT TYPE="hidden" VALUE = "#FORM.frompage#" NAME="frompage">
	<INPUT TYPE="hidden" VALUE = "#FORM.StartRow#" NAME="startrow">
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_BY#" NAME="SORT_BY">
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_ORDER#" NAME="SORT_ORDER">
	<INPUT TYPE="hidden" VALUE = "#FORM.Doc_Desc#" NAME="Doc_Desc">
	</CFOUTPUT>
	  <CFSET settoday = #DateFormat(Now(),"mm/dd/yyyy")#>
	<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="today1" VALUE="#settoday#">
	</CFOUTPUT>
	<INPUT TYPE="hidden" NAME="Search" VALUE="1">
	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">document search</LEGEND>
	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0">

		<TR>
			<CFQUERY NAME="Select_Family" DATASOURCE="#Application.Datasource#">
				SELECT DISTINCT(Doc_Family) FROM document_details WHERE Deleted = 0
			</CFQUERY>
			<TD>Family<br>
				<SELECT NAME="Doc_Family" STYLE="WIDTH:90px;">
					<OPTION VALUE="" SELECTED></OPTION>
					<CFOUTPUT QUERY="Select_Family">
						<OPTION VALUE="#Doc_Family#"<!--- <CFIF isdefined("URL.Doc_Family")><CFIF URL.Doc_Family EQ Doc_Family> SELECTED</CFIF></CFIF> ---><CFIF FORM.Doc_Family EQ Doc_Family> SELECTED</CFIF>>#Doc_Family#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<CFQUERY NAME="Select_type" DATASOURCE="#Application.Datasource#">
				SELECT DISTINCT(Doc_Type) FROM document_details WHERE Deleted = 0
			</CFQUERY>
			<TD>Type<br>
			<SELECT NAME="Doc_type" STYLE="WIDTH:135px;">
					<OPTION VALUE="" SELECTED></OPTION>
					<CFOUTPUT QUERY="Select_type">
						<OPTION VALUE="#Doc_Type#"<!--- <CFIF isdefined("URL.Doc_type")><CFIF URL.Doc_Type EQ Doc_Type> SELECTED</CFIF></CFIF> ---><CFIF FORM.Doc_Type EQ Doc_Type> SELECTED</CFIF>>#Doc_Type#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>Title<br>
				<INPUT TYPE="Text" NAME="Doc_Title" VALUE=<CFOUTPUT>"#FORM.Doc_Title#"</CFOUTPUT> STYLE="WIDTH:235px;">
				<!--- <SELECT NAME="Doc_Family" STYLE="WIDTH:235px;">
					<OPTION VALUE="" SELECTED></OPTION>
					<CFOUTPUT QUERY="Select_Family">
						<OPTION VALUE="#Doc_Family#"<!--- <CFIF isdefined("URL.Doc_Family")><CFIF URL.Doc_Family EQ Doc_Family> SELECTED</CFIF></CFIF> ---><CFIF FORM.Doc_Family EQ Doc_Family> SELECTED</CFIF>>#Doc_Family#</OPTION>
					</CFOUTPUT>
				</SELECT> --->
			</TD>
			<CFQUERY NAME="Select_name" DATASOURCE="#Application.Datasource#">
				<!--- SELECT DISTINCT(Uploaded_By) FROM document_details WHERE Deleted = 0 --->
				SELECT DISTINCT Uploaded_By,Name_First,Name_Last FROM document_details
				LEFT JOIN _users ON document_details.Uploaded_By = _users.User_ID
				WHERE document_details.Deleted = 0
			</CFQUERY>
			<TD>Uploaded By<br>
				<SELECT NAME="Uploaded_By" STYLE="WIDTH:235px;">
					<OPTION VALUE="" SELECTED></OPTION>
					<CFOUTPUT QUERY="Select_Name">
						<OPTION VALUE="#uploaded_by#"<!--- <CFIF isdefined("URL.Uploaded_By")><CFIF URL.Uploaded_By EQ Uploaded_By> SELECTED</CFIF></CFIF> ---><CFIF FORM.uploaded_by EQ uploaded_by> SELECTED</CFIF>>#Name_First# #Name_Last#<!--- #Uploaded_by# ---></OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>

		</TR>
		<TR>
			<TD>Uploaded Date<br>
				<SELECT NAME="Comp_Operator" STYLE = "WIDTH: 90px;" ONCHANGE="javaScript: selectChange(this);">
					<OPTION VALUE = ""<CFIF FORM.Comp_Operator EQ ""> SELECTED</CFIF>>
					<OPTION VALUE = ">"<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ ">"> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ ">"> SELECTED</CFIF>> Greater Than
					<OPTION VALUE = "<"<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ "<"> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ "<"> SELECTED</CFIF>> Less Than
					<OPTION VALUE = "="<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ "="> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ "="> SELECTED</CFIF>> Equal To
					<OPTION VALUE = "Between"<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ "Between"> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ "Between"> SELECTED</CFIF>>Between
				</SELECT>
				</TD>
				<TD><br>
				<CFOUTPUT>
<!--- 				<CFIF isdefined("URL.From_Date")>
					<CFSET default=URL.From_Date>
				<CFELSE> --->
					<CFSET default=FORM.From_date>
				<!--- </CFIF> --->
				<CF_EASYDATE FORMNAME="FormAttach" FIELDNAME="From_Date" FORMAT="mm/dd/yyyy" DEFAULT="#default#">
				</CFOUTPUT>
			</TD>

			<TD><br>
				<SPAN ID="SP_To_Date"<CFIF FORM.Comp_Operator NEQ "Between"> STYLE="display:none;"</CFIF>>
				<CFOUTPUT>
				<!--- <CFIF isdefined("URL.To_Date")>
					<CFSET To_default=URL.To_Date>
				<CFELSE> --->
					<CFSET To_default=FORM.To_date>
				<!--- </CFIF> --->
				<CF_EASYDATE FORMNAME="FormAttach" FIELDNAME="To_Date" FORMAT="mm/dd/yyyy" DEFAULT="#To_default#">
				</CFOUTPUT>
				</SPAN>
			</TD>
			<TD NOWRAP VALIGN="bottom">
			<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
				<A HREF="#" OnClick="javascript: return validate();"><B>search documents</B></A>
				<!--- <A HREF="javascript: document.FormAttach.submit()"><B>search documents</B></A> --->
			<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
 			<FONT COLOR="ff0000" SIZE="2">&nbsp;&nbsp;<B>[</B></FONT>
				<A HREF="javascript: reset_Form_Fields();"><B>reset</B></A>
			<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
			<CFOUTPUT>
			<FONT COLOR="ff0000" SIZE="2">&nbsp;&nbsp;<B>[</B></FONT>
				<A HREF="/Common_Files/Documents/create_document_details.cfm?FromProgram=0&CID=#url.cid#<CFIF FORM.Uploaded_By NEQ "">&Uploaded_By=#FORM.Uploaded_By#</CFIF><CFIF FORM.Doc_Type NEQ "">&Doc_Type=#FORM.Doc_Type#</CFIF><CFIF FORM.Doc_Family NEQ "">&Doc_Family=#FORM.Doc_Family#</CFIF><CFIF FORM.Comp_Operator NEQ "">&Comp_Operator=#FORM.Comp_Operator#&From_Date=#FORM.From_Date#</CFIF><CFIF FORM.Comp_Operator EQ "Between">&To_Date=#FORM.To_Date#</CFIF><CFIF FORM.Doc_Title NEQ "">&Doc_Title=#FORM.Doc_Title#</CFIF>"><B>upload documents</B></A>
			<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
			</CFOUTPUT>
			</TD>
		</TR>
	</TABLE>
	</FIELDSET>
	<!------</FORM>----->
	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently attached document(s)</LEGEND>

	<CFIF Current_sel.recordcount GT 0>
				<!--- <TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="100%" BGCOLOR="white">
					<TR><CFoutput QUERY="Current_sel">
							<TD BGCOLOR="eeeeee" WIDTH="33%"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view #Doc_Title#">#Doc_Title#</A></TD><!--- #doc_title# --->
		 				<CFIF Current_sel.currentrow mod 3><CFELSE></TR><TR></CFIF>
					</CFoutput>
					</TR>
					 <tr>	<td></td></tr>
				</TABLE> --->
				<INPUT TYPE="Hidden" NAME="DeleteDocList" VALUE="">
				<TABLE ID="Table_Delete" CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">
					<!--- TABLE HEADERS --->
					<TR BGCOLOR="#FFCE84" VALIGN="bottom">

						<TD ID="header"><FONT SIZE="1"><B>DATE<br>NAME</B></FONT></TD>
						<TD ID="header" ><FONT SIZE="1"><B>FILE</B></FONT></TD>
						<TD ID="header" ><FONT SIZE="1"><B>TITLE<br>DESCRIPTION</B></FONT></TD>
						<TD ID="header"><FONT SIZE="1"><B>TYPE</B></FONT></TD>
						<TD ID="header"><FONT SIZE="1"><B>DELETE</B></FONT></TD>
					</TR>
					<CFOUTPUT QUERY="Current_sel">
						<!--- DATA OUTPUT --->
						<TR ID="TR_Delete_#CurrentRow#" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
						<cfset useLakebaseForUser_Name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForUser_Name>
	<cftry>
		<cfset User_Name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Uploaded_By#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUser_Name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUser_Name>
<CFQUERY NAME="User_Name" DATASOURCE="#Application.Datasource#">
								SELECT Name_First, Name_Last FROM _USERS WHERE User_ID = '#Uploaded_By#'
						</CFQUERY>
</cfif>
							<CFSET SIZEinMB = #Doc_size#/1024>
							<TD ID="TD1_#CurrentRow#" WIDTH="16%">#DateFormat(Uploaded_Date,"mm/dd/yyyy")#<BR>#User_Name.Name_First# #User_Name.Name_Last#&nbsp;</TD>

							<TD ID="TD2_#CurrentRow#" NOWRAP TITLE="File Name: #Doc_File_Name#" ID=""><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
								<CFSET Display_Name=Left(Doc_File_Name,20)>
								<CFIF len(trim(Doc_File_Name)) GT 20>
									#LCASE(Display_Name)#...
								<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
									&nbsp;
								<CFELSE>
									#LCASE(Display_Name)#
								</CFIF>
								</A><BR>#NumberFormat(SIZEinMB,"_.___")# KB&nbsp;</TD>
							<TD ID="TD3_#CurrentROw#" WIDTH="58%"><FONT color="red"><b>#Doc_Title#</b></FONT><br>Description: #Doc_Description#&nbsp;</TD>
							<TD ID="TD4_#CurrentRow#" WIDTH="12%">#Doc_Type#&nbsp;</TD>
							<TD ID="Delete_#currentRow#"><A HREF="Javascript: DeleteTool('#Doc_ID#',1,'#CurrentRow#')"><img src="/Images/scissor.gif" width="14" height="9" alt="Remove entry" border="0"></A></TD>
						</TR>
					</CFOUTPUT>
					<CFSET Display_Button = 0>
					<TR ID="TR_Confirm" <CFIF Display_Button EQ 0>STYLE="DISPLAY:NONE"</CFIF>>
						<TD COLSPAN="100%" ALIGN="Right" STYLE="border-bottom:none;"><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="Javascript: ConfirmDelete()">confirm delete</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
					</TR>
				</TABLE>
	<CFELSE>
		NONE
	</CFIF>
	<BR>
	</FIELDSET>

	<CFIF isdefined("FORM.search") OR isdefined("URL.search")>

	<CFSWITCH EXPRESSION="#FORM.SORT_BY#">
		<CFCASE VALUE="Uploaded_Date,Doc_Title,Doc_File_Name,Doc_Description,Uploaded_By,Doc_Type,Doc_Family" DELIMITERS=",">
			<CFSET FORM.SORT_BY = FORM.SORT_BY>
		</CFCASE>
		<CFDEFAULTCASE>
			<CFSET FORM.SORT_BY = "Doc_Title">
		</CFDEFAULTCASE>
	</CFSWITCH>

	<CFIF FORM.SORT_ORDER NEQ "DESC">
		<CFSET FORM.SORT_ORDER = "ASC">
	</CFIF>


	<CFOUTPUT>
		<CFQUERY NAME="ret_data" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Document_Details
			WHERE
			deleted = 0
			AND (	(	Public_View = 1
						AND User_Position_ID IN (#preservesinglequotes(Access_Position_List)#)
					)
					OR Public_View = 0
				)
			<CFIF FORM.Uploaded_By NEQ "">
				AND Uploaded_By = '#FORM.Uploaded_By#'
			</CFIF>
			<CFIF FORM.Doc_Type NEQ "">
				AND Doc_Type = '#FORM.Doc_Type#'
			</CFIF>
			<CFIF FORM.Doc_Family NEQ "">
				AND Doc_Family = '#FORM.Doc_Family#'
			</CFIF>
			<CFIF FORM.Comp_Operator NEQ "">
				<!------ AND CONVERT(Char(10),Uploaded_Date,101) #FORM.Comp_Operator# '#FORM.From_Date#'<CFIF FORM.Comp_Operator EQ "Between"> and  '#FORM.To_Date#' </CFIF> ----->
				<CFIF FORM.Comp_Operator EQ "Between">
				AND DATEDIFF(d, #CreateODBCDate(FORM.From_Date)#, Uploaded_Date) >= 0
				AND DATEDIFF(d, #CreateODBCDate(FORM.To_Date)#, Uploaded_Date) <= 0
				<CFELSE>
				AND DATEDIFF(d, #CreateODBCDate(FORM.From_Date)#, Uploaded_Date) #FORM.Comp_Operator# 0
				</CFIF>
			</CFIF>
			<CFIF FORM.Doc_Title NEQ "">
				AND DOC_Title LIKE '%#FORM.Doc_Title#%'
			</CFIF>
			<CFIF url.docid NEQ "">
				AND DOC_ID = '#url.docid#'
			</CFIF>
			<CFIF FORM.Doc_Desc NEQ "">
				AND Doc_Description LIKE '#FORM.Doc_Desc#%'
			</CFIF>
			AND IS_WELCOME_LETTER = 0
			ORDER BY #FORM.SORT_BY# #FORM.SORT_ORDER#
		</CFQUERY>
	</CFOUTPUT>
	<!--- <CFIF isdefined("URL.search")>
	<CFOUTPUT>
		<CFQUERY NAME="ret_data" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Document_Details
			WHERE
			deleted = 0
			<CFIF isdefined("URL.Uploaded_By")>
				AND Uploaded_By = '#URL.Uploaded_By#'
			</CFIF>
			<CFIF isdefined("URL.Doc_Type")>
				AND Doc_Type = '#URL.Doc_Type#'
			</CFIF>
			<CFIF isdefined("URL.Doc_Family")>
				AND Doc_Family = '#URL.Doc_Family#'
			</CFIF>
			<CFIF isdefined("URL.Comp_Operator")>
				AND CONVERT(Char(10),Uploaded_Date,101) #URL.Comp_Operator# '#URL.From_Date#'<CFIF URL.Comp_Operator EQ "Between"> and  '#URL.To_Date#' </CFIF>
			</CFIF>
			ORDER BY #FORM.SORT_BY# #FORM.SORT_ORDER#
	 	</CFQUERY>
	</CFOUTPUT>
	</CFIF> --->


	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There<CFIF ret_data.recordcount EQ 0> Are No Documents <CFELSEIF ret_data.recordcount EQ 1> Is A Document<CFELSE> Are <CFOUTPUT>#ret_data.recordcount#</CFOUTPUT> Documents</CFIF>  That Match This Criteria</LEGEND>
	<!------<FORM ACTION="contract_attachments.cfm?CID=<CFOUTPUT>#EncryptedCID#</CFOUTPUT>" METHOD="post" NAME="Attachsearch">
	<INPUT TYPE="hidden" NAME="formcheck" VALUE="1">----->
	<CFINCLUDE TEMPLATE="contract_attach_search.cfm">
	<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
		<A HREF="javascript: save_Documents();"><B>attach selected documents</B></A>
	<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
	<!--- <CFOUTPUT>
	<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
		<A HREF="/Common_Files/Documents/create_document_details.cfm?FromProgram=1&CID=##<CFIF FORM.Uploaded_By NEQ "">&Uploaded_By=#FORM.Uploaded_By#</CFIF><CFIF FORM.Doc_Type NEQ "">&Doc_Type=#FORM.Doc_Type#</CFIF><CFIF FORM.Doc_Family NEQ "">&Doc_Family=#FORM.Doc_Family#</CFIF><CFIF FORM.Comp_Operator NEQ "">&Comp_Operator=#FORM.Comp_Operator#&From_Date=#FORM.From_Date#</CFIF><CFIF FORM.Comp_Operator EQ "Between">&To_Date=#FORM.To_Date#</CFIF>"><B>upload documents</B></A>
	<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
	</CFOUTPUT> --->
	<!------</FORM>----->
	<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <CF_Next_Previous_For_Forms
    formname="FormAttach"
    query="ret_data"
    maxpages="40"
    previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
    next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
    previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    addparams="">
   </DIV>
	<!--- Dev Note: Milan 9250 --->
	 <script language="javascript">
		function showstartingWith(sValue)
		{
			document.FormAttach.Doc_Desc.value =sValue;
			return validate();
		}
		</script>
		<TABLE CELLPADDING="2" CELLSPACING="1" BORDER="0" ALIGN="CENTER"><TR>
		<cfoutput>
			<cfloop index="LoopCount" from="65" to="90">
					<TD class="notranslate">
						<B>
						<CFIF chr(LoopCount) EQ form.Doc_Desc>
							<FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('#chr(LoopCount)#');">#chr(LoopCount)#</A>
					 <CFIF chr(LoopCount) EQ form.Doc_Desc>
						<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
			</cfloop>
			<cfloop index="LoopCount" from="0" to="9">
					<TD>
						<B>
						<CFIF LoopCount EQ form.Doc_Desc>
							<FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('#LoopCount#');">#LoopCount#</A>
						<CFIF LoopCount EQ form.Doc_Desc>
							<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
			</cfloop>
					<TD>
						<B>
						<CFIF "" EQ form.Doc_Desc>
						 <FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('');">ALL</A>
					 <CFIF "" EQ form.Doc_Desc>
						<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
	</cfoutput>
	 </TR>
	</TABLE>
	<!--- End Note: Milan 9250 --->
	</FIELDSET>
	</CFIF>
	</FORM>
</BLOCKQUOTE>
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>



