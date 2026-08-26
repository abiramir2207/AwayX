<cfsilent>
<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" 	DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 	DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" 	DEFAULT="0">
<CFPARAM NAME="URL.bFromSettings" 	DEFAULT="0">
<CFPARAM NAME="Form.bFromSettings" 	DEFAULT="0">
<CFPARAM NAME="URL.BillbackList" 	DEFAULT="">
<CFPARAM NAME="Form.BillbackList" 	DEFAULT="">
<CFPARAM NAME="URL.ProgramList" 	DEFAULT="">
<CFPARAM NAME="Form.ProgramList" 	DEFAULT="">
<CFPARAM NAME="layoutId" 		DEFAULT="manageDocuments" />
<CFPARAM NAME="FORM.Form_Name" DEFAULT="">
<CFPARAM NAME="FlexAppName" DEFAULT="">
<CFPARAM NAME="URL.disableUpload" 	DEFAULT="0">
<CFPARAM NAME="Form.disableUpload" 	DEFAULT="0">
<CFPARAM NAME="URL.Deduction_ID" 	DEFAULT="0">
<!--- "URL.ProgramList" gets passed from flex program search tool. --->
<cfif URL.ProgramList neq "">
	<cfset Form.ProgramList = URL.ProgramList>
</cfif>

<!---
Label 42223 - Unable to upload documents to Billbacks:
	Modified code to bypass the layout menu and use the upload link from version 6.2 only when coming from Billback documents.
	Users were not able to upload and attach documents to Billbacks as expected
--->
<!--- FlexAppName neq "" means - Whenever the request comes from flex. --->
<cfif FORM.Form_Name eq "Billback_Attachments" OR FlexAppName neq "">
	<cfset layoutId = "" />
</cfif>
<cfif URL.bFromSettings EQ 1>
	<cfset Form.bFromSettings = 1>
</cfif>
</cfsilent>

<cfmodule template="/customTags/layout.cfm"
							layoutID = "#layoutId#"
							selectedIndex = "0" >

<CFIF Form.bFromSettings EQ 1>
	<cfset pageName = "Document Search" />
	<!--- <CFINCLUDE TEMPLATE="/Common_Files/Documents/Attach_Document_header.cfm"> --->
	<cfset MaxRows =100>
</CFIF>

<cfif NOT isDefined("Get_Profile_Settings")>
	<cfinclude template="/get_access_profile.cfm" />
</cfif>

<CFSET thisTemplate="#GetFileFromPath(GetCurrentTemplatePath())#?Deduction_ID=#url.Deduction_ID#">


<CFIF IsDefined("URL.Form_Name")>
	<FORM ACTION="<CFOUTPUT>#thisTemplate#</CFOUTPUT>" METHOD="post" NAME="Search_First_Page">
		<INPUT NAME="Form_Name" TYPE="Hidden" VALUE="">
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
		<cfif URL.disableUpload eq 1>
			<INPUT NAME="disableUpload" TYPE="HIDDEN" VALUE="1">
		</cfif>
	</FORM>

	<SCRIPT LANGUAGE="JavaScript">
		var parentForm;
		eval("parentForm = window.opener." + "<CFOUTPUT>#URL.Form_Name#</CFOUTPUT>" + ";");
		if(parentForm)
		{
			this.Search_First_Page.Form_Name.value = "<CFOUTPUT>#URL.Form_Name#</CFOUTPUT>";
			if(parentForm.Attachment_List)
			{
				this.Search_First_Page.FinalItemList.value = parentForm.Attachment_List.value;
			}

			document.Search_First_Page.submit();
		}
		else
		{
			alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
			window.close()
		}
	</SCRIPT>

</CFIF>

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
	<!--- When this page gets called from flex program search tool, we include the action page below
	to insert the attached documents to the program list, which could be multiple programs.
	 --->
	<cfif Form.FlexAppName neq "" AND Form.ProgramList neq "">
		<cfset FORM.Doc_ID = Form.FinalItemList>
		<cfinclude template="/common_files/contracts/contract_attachments_Action.cfm">
		<script>
		window.close();
		</script>
	<cfelse>
	<!--- This is the code which is used in most places in the application. --->
	<script>
		opener.document.all.<CFOUTPUT>#Form.Form_Name#</CFOUTPUT>.Attachment_List.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
		opener.document.<CFOUTPUT>#Form.Form_Name#</CFOUTPUT>.submit();
		window.close();
	</script>
	<CFABORT>
	</cfif>
</CFIF>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
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
	function upload_doc(thisobj)
	{
		x=document.FormAttach;
		x.action = thisobj.href;
		x.submit();
		return false;
	}
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
	function deleteDoc(Doc_Id)
	{
		if(confirm("Do you really want to delete the selected document?"))
		{
			x=document.FormAttach;
			x.Delete_Doc_Id.value = Doc_Id;
			x.submit();
			return false;
		}
		return false;
	}
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
		var chObjs = document.all.SelectedITEMS;
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
		document.FormAttach.finishedselectingitems.value = 1;
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
		document.all.Doc_Description.value = "";
		document.all.Doc_File_Name.value = "";
		resetSelect("Public_View");
		resetSelect("deleted");
		resetSelect("AttachedTo");
	}

	function resetSelect(selName)
	{
		var sObj = document.getElementById(selName);
		if(sObj)
		{
			sObj.selectedIndex = 0;
			callfireEvent(document,sObj,'Change');
		}
	}

</SCRIPT>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

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

<CFPARAM NAME="URL.SORT_BY" 	DEFAULT="">
<CFPARAM NAME="URL.SORT_ORDER" 	DEFAULT="ASC">

<CFPARAM NAME="URL.Doc_Type" 		DEFAULT="">
<CFPARAM NAME="URL.Doc_Family" 		DEFAULT="">
<CFPARAM NAME="URL.uploaded_by" 	DEFAULT="">
<CFPARAM NAME="URL.Comp_Operator" 	DEFAULT="">
<CFPARAM NAME="URL.From_Date" 		DEFAULT="">
<CFPARAM NAME="URL.To_Date" 		DEFAULT="">
<CFPARAM NAME="URL.Doc_Title" 		DEFAULT="">
<CFPARAM NAME="URL.Doc_ID" 		DEFAULT="">
<CFPARAM NAME="URL.Doc_Description" 		DEFAULT="">
<CFPARAM NAME="URL.Doc_File_Name" 		DEFAULT="">
<CFPARAM NAME="URL.Public_View" 		DEFAULT="">
<CFPARAM NAME="URL.deleted" 		DEFAULT="">
<CFPARAM NAME="URL.AttachedTo" 		DEFAULT=0>

<CFPARAM NAME="FORM.SORT_BY" 		DEFAULT="#URL.SORT_BY#">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="#URL.SORT_ORDER#">

<CFPARAM NAME="FORM.Doc_Type" 		DEFAULT="#URL.Doc_Type#">
<CFPARAM NAME="FORM.Doc_ID" 		DEFAULT="#URL.Doc_ID#">
<CFPARAM NAME="FORM.Doc_Family" 	DEFAULT="#URL.Doc_Family#">
<CFPARAM NAME="FORM.uploaded_by" 	DEFAULT="#URL.uploaded_by#">
<CFPARAM NAME="FORM.Comp_Operator" 	DEFAULT="#URL.Comp_Operator#">
<CFPARAM NAME="FORM.From_Date" 		DEFAULT="#URL.From_Date#">
<CFPARAM NAME="FORM.To_Date" 		DEFAULT="#URL.To_Date#">
<CFPARAM NAME="FORM.Doc_Title" 		DEFAULT="#URL.Doc_Title#">
<CFPARAM NAME="FORM.Doc_Description" 	DEFAULT="#URL.Doc_Description#">
<CFPARAM NAME="FORM.Doc_File_Name" 	DEFAULT="#URL.Doc_File_Name#">
<CFPARAM NAME="FORM.Public_View" 	DEFAULT="#URL.Public_View#">
<CFPARAM NAME="FORM.deleted" 		DEFAULT="#URL.deleted#">
<CFPARAM NAME="FORM.AttachedTo" 	DEFAULT="#URL.AttachedTo#">


<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="">
<CFPARAM NAME="FORM.from_common_attachment" DEFAULT="">
<CFPARAM NAME="FORM.Delete_Doc_Id" DEFAULT="0">
<cfif FORM.Delete_Doc_Id NEQ 0>
	<cfset useLakebaseForDeleteDocId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
	<cfif useLakebaseForDeleteDocId>
		<cftry>
			<cfset application.oLakebase.updateRows("document_details",
				{ "doc_id" = "eq.#FORM.Delete_Doc_Id#" },
				{ "deleted_permanent" = true, "deleted" = true }
			)>
			<cfcatch type="any">
				<cfset useLakebaseForDeleteDocId = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDeleteDocId>
		<CFQUERY NAME="DeleteDocId" DATASOURCE="#Application.Datasource#">
	 		update    Document_Details
			set       Deleted_Permanent = 1,Deleted = 1
			where     Doc_ID = '<cfoutput>#FORM.Delete_Doc_Id#</cfoutput>'
		</CFQUERY>
	</cfif>
</cfif>

<FORM ACTION="Attach_Document.cfm" METHOD="post" NAME="FormAttach" STYLE="DISPLAY:INLINE;">

	<cfparam name="FORM.startrow"  default="1">
   <CFPARAM NAME="FORM.frompage"   DEFAULT="1">
   <cfparam name="FORM.pageLength"  default=10>

   <CFSET startrow=FORM.startrow>
   <CFSET frompage=FORM.frompage>

   <cf_Number_of_Rows maxrows="#FORM.pageLength#">
   <CFOUTPUT>
   	<INPUT TYPE="hidden" NAME="bFromSettings" VALUE = "#Form.bFromSettings#">
   	<INPUT TYPE="hidden" VALUE = "#FORM.frompage#" NAME="frompage">
	<INPUT TYPE="hidden" VALUE = "#FORM.StartRow#" NAME="startrow">
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_BY#" NAME="SORT_BY">
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_ORDER#" NAME="SORT_ORDER">
	<INPUT TYPE="hidden" VALUE = "0" NAME="Delete_Doc_Id">
	</CFOUTPUT>
	  <CFSET settoday = #DateFormat(Now(),"mm/dd/yyyy")#>
	<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="today1" VALUE="#settoday#">
	</CFOUTPUT>
	<INPUT TYPE="hidden" NAME="Search" VALUE="1">
	<FIELDSET STYLE="padding:0.5%; width:97.5%; border: 1px solid Blue; margin:0.5%;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">document search</LEGEND>

	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0">
	<!---	Redesign layout  by 23692
		<TR>
			<CFQUERY NAME="Select_Family" DATASOURCE="#Application.Datasource#">
				SELECT DISTINCT(Doc_Family) FROM document_details WHERE Deleted = 0
			</CFQUERY>
			<TD>Family<br>
				<SELECT NAME="Doc_Family" STYLE="WIDTH:85px;">
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
			<SELECT NAME="Doc_type" ID="Doc_type" STYLE="WIDTH:132px;">
					<OPTION VALUE="" SELECTED></OPTION>
					<CFOUTPUT QUERY="Select_type">
						<OPTION VALUE="#Doc_Type#"<!--- <CFIF isdefined("URL.Doc_type")><CFIF URL.Doc_Type EQ Doc_Type> SELECTED</CFIF></CFIF> ---><CFIF FORM.Doc_Type EQ Doc_Type> SELECTED</CFIF>>#Doc_Type#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>Title<br>
				<INPUT TYPE="Text" NAME="Doc_Title" VALUE=<CFOUTPUT>"#FORM.Doc_Title#"</CFOUTPUT> STYLE="WIDTH:220px;">
				<!--- <SELECT NAME="Doc_Family" STYLE="WIDTH:220px;">
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
				<SELECT NAME="Uploaded_By" ID="Uploaded_By" STYLE="WIDTH:220px;">
					<OPTION VALUE="" SELECTED></OPTION>
					<CFOUTPUT QUERY="Select_Name">
						<OPTION VALUE="#uploaded_by#"<!--- <CFIF isdefined("URL.Uploaded_By")><CFIF URL.Uploaded_By EQ Uploaded_By> SELECTED</CFIF></CFIF> ---><CFIF FORM.uploaded_by EQ uploaded_by> SELECTED</CFIF>>#Name_First# #Name_Last#<!--- #Uploaded_by# ---></OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>

		</TR>
		<TR>
			<TD>Uploaded Date<br>
				<SELECT NAME="Comp_Operator" ID="Comp_Operator" STYLE = "WIDTH: 85px;" ONCHANGE="javaScript: selectChange(this);">
					<OPTION VALUE = ""<CFIF FORM.Comp_Operator EQ ""> SELECTED</CFIF>>
					<OPTION VALUE = ">"<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ ">"> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ ">"> SELECTED</CFIF>> greater than
					<OPTION VALUE = "<"<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ "<"> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ "<"> SELECTED</CFIF>> less than
					<OPTION VALUE = "="<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ "="> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ "="> SELECTED</CFIF>> equal to
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
		---> <!--- New format designed by 23692 --->
		<TR>
			<TD colspan="2">Title<br>
				<cfoutput><INPUT TYPE="Text" NAME="Doc_Title" VALUE="#FORM.Doc_Title#" STYLE="WIDTH:300px"></cfoutput>
			</TD>
			<TD colspan="2">Description<br>
				<cfoutput><INPUT TYPE="Text" NAME="Doc_Description" VALUE="#FORM.Doc_Description#" STYLE="WIDTH:300px"></cfoutput>
			</TD>
		</TR>
		<TR>
			<TD colspan=2>File Name<br>
				<cfoutput><INPUT TYPE="Text" NAME="Doc_File_Name" VALUE="#FORM.Doc_File_Name#" STYLE="WIDTH:300px;"></cfoutput>
			</TD>
			<CFQUERY NAME="Select_Family" DATASOURCE="#Application.Datasource#">
				SELECT DISTINCT(Doc_Family) FROM document_details WHERE Deleted = 0 order by Doc_Family
			</CFQUERY>
			<TD>Family<br>
				<SELECT NAME="Doc_Family" ID="Doc_Family" STYLE="WIDTH:185px;">
					<OPTION VALUE="" SELECTED></OPTION>
					<CFOUTPUT QUERY="Select_Family">
						<OPTION VALUE="#Doc_Family#"<CFIF FORM.Doc_Family EQ Doc_Family> SELECTED</CFIF>>#Doc_Family#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<CFQUERY NAME="Select_type" DATASOURCE="#Application.Datasource#">
				SELECT DISTINCT(Doc_Type) FROM document_details WHERE Deleted = 0 order by Doc_Type
			</CFQUERY>
			<TD align=left>Type<br>
				<SELECT NAME="Doc_type" ID="Doc_type" STYLE="WIDTH:185px;">
					<OPTION VALUE="" SELECTED></OPTION>
					<CFOUTPUT QUERY="Select_type">
						<OPTION VALUE="#Doc_Type#"<CFIF FORM.Doc_Type EQ Doc_Type> SELECTED</CFIF>>#Doc_Type#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
		</TR>
		<TR>
			<TD colspan = 4>
				<table>
				<tr>
					<TD>Attached To<br>
						<SELECT NAME="AttachedTo" ID="AttachedTo" STYLE="WIDTH:90px;">
							<OPTION VALUE="0"  <CFIF FORM.AttachedTo EQ 0> SELECTED</CFIF>>All</OPTION>
							<OPTION VALUE="Billback"  <CFIF FORM.AttachedTo EQ "Billback"> SELECTED</CFIF> >Billback</OPTION>
							<OPTION VALUE="Deduction"  <CFIF FORM.AttachedTo EQ "Deduction"> SELECTED</CFIF>>Deduction</OPTION>
							<OPTION VALUE="Program"  <CFIF FORM.AttachedTo EQ "Program"> SELECTED</CFIF>>Program</OPTION>
						</SELECT>
					</TD>
					<TD>Privacy<br>
						<SELECT NAME="Public_View" ID="Public_View" STYLE="WIDTH:90px;">
							<OPTION VALUE=""></OPTION>
							<OPTION VALUE="0"  <CFIF FORM.Public_View EQ 0> SELECTED</CFIF>>Not Private</OPTION>
							<OPTION VALUE="1"  <CFIF FORM.Public_View EQ 1> SELECTED</CFIF>>Private</OPTION>
						</SELECT>
					</TD>
					<TD>Availability<br>
						<SELECT NAME="deleted" ID="deleted" STYLE="WIDTH:74px;">
							<OPTION VALUE="0" <CFIF FORM.deleted EQ 0> SELECTED</CFIF>>Active</OPTION>
							<OPTION VALUE="1"  <CFIF FORM.deleted EQ 1> SELECTED</CFIF>>Inactive</OPTION>
						</SELECT>
					</TD>
					<CFQUERY NAME="Select_name" DATASOURCE="#Application.Datasource#">
						<!--- SELECT DISTINCT(Uploaded_By) FROM document_details WHERE Deleted = 0 --->
						SELECT DISTINCT Uploaded_By,Name_First,Name_Last FROM document_details
						LEFT JOIN _users ON document_details.Uploaded_By = _users.User_ID
						WHERE document_details.Deleted = 0
						ORDER BY _users.Name_Last
					</CFQUERY>
					<TD>Uploaded By<br>
						<SELECT NAME="Uploaded_By" ID="Uploaded_By" STYLE="WIDTH:140px;">
							<OPTION VALUE="" SELECTED></OPTION>
							<CFOUTPUT QUERY="Select_Name">
								<OPTION VALUE="#uploaded_by#"<!--- <CFIF isdefined("URL.Uploaded_By")><CFIF URL.Uploaded_By EQ Uploaded_By> SELECTED</CFIF></CFIF> ---><CFIF FORM.uploaded_by EQ uploaded_by> SELECTED</CFIF>>#Name_First# #Name_Last#<!--- #Uploaded_by# ---></OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
					<TD>Uploaded Date<br>
						<SELECT NAME="Comp_Operator" ID="Comp_Operator" STYLE = "WIDTH: 95px;" ONCHANGE="javaScript: selectChange(this);">
							<OPTION VALUE = ""<CFIF FORM.Comp_Operator EQ ""> SELECTED</CFIF>>
							<OPTION VALUE = ">"<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ ">"> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ ">"> SELECTED</CFIF>> greater than
							<OPTION VALUE = "<"<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ "<"> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ "<"> SELECTED</CFIF>> less than
							<OPTION VALUE = "="<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ "="> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ "="> SELECTED</CFIF>> equal to
							<OPTION VALUE = "Between"<!--- <CFIF isdefined("URL.Comp_Operator")><CFIF URL.Comp_Operator EQ "Between"> SELECTED</CFIF></CFIF> ---><CFIF FORM.Comp_Operator EQ "Between"> SELECTED</CFIF>>Between
						</SELECT>
					</TD>
					<TD><br>
						<CFOUTPUT>
							<CFSET default=FORM.From_date>
							<CF_EASYDATE FORMNAME="FormAttach" FIELDNAME="From_Date" FORMAT="mm/dd/yyyy" DEFAULT="#default#" FieldNameSize="6">
						</CFOUTPUT>
					</TD>
					<TD><br>
						<SPAN ID="SP_To_Date"<CFIF FORM.Comp_Operator NEQ "Between"> STYLE="display:none;"</CFIF>>
						<CFOUTPUT>
							<CFSET To_default=FORM.To_date>
							<CF_EASYDATE FORMNAME="FormAttach" FIELDNAME="To_Date" FORMAT="mm/dd/yyyy" DEFAULT="#To_default#" FieldNameSize="6">
						</CFOUTPUT>
						</SPAN>
					</TD>
				</tr>
				</table>
			</TD>
		</TR>
		<TR>
			<TD NOWRAP VALIGN="bottom" align= "right" colspan=4>
			<!--- Only if the profile allows, should a user be allowed to search for documents --->
			<cfif Get_Profile_Settings.Search_Documents eq 1>
			<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
				<A HREF="#" OnClick="javascript: return validate();"><B>search documents</B></A>
				<!--- <A HREF="javascript: document.FormAttach.submit()"><B>search documents</B></A> --->
			<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
			</cfif>
			<FONT COLOR="#ff0000" SIZE="2">&nbsp;&nbsp;<B>[</B></FONT>
				<A HREF="javascript: reset_Form_Fields();"><B>reset</B></A>
			<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>

			<!--- When accessing this page from the settings panel OR from billback attachments page, do not show link for "upload document" --->
			<!--- <cfif Form.bFromSettings NEQ 1 AND FORM.Form_Name NEQ "Billback_Attachments"> --->
			<cfif Form.bFromSettings NEQ 1 and Form.disableUpload eq 0>
			<FONT COLOR="ff0000" SIZE="2"><B>&nbsp;&nbsp;[</B></FONT>
				<A HREF="/Common_Files/Documents/create_document_details.cfm?project=1" ONCLICK="javascript: return upload_doc(this);"><B>upload document</B></A><!--- FromProgram=1&CID=#URL.CID#<CFIF FORM.Uploaded_By NEQ "">&Uploaded_By=#FORM.Uploaded_By#</CFIF><CFIF FORM.Doc_Type NEQ "">&Doc_Type=#FORM.Doc_Type#</CFIF><CFIF FORM.Doc_Family NEQ "">&Doc_Family=#FORM.Doc_Family#</CFIF><CFIF FORM.Comp_Operator NEQ "">&Comp_Operator=#FORM.Comp_Operator#&From_Date=#FORM.From_Date#</CFIF><CFIF FORM.Comp_Operator EQ "Between">&To_Date=#FORM.To_Date#</CFIF> --->
			<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
			</cfif>
			</TD>
		</TR>
	</TABLE>
	</FIELDSET>
	<!------</FORM>----->


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

	<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
	<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>

	<CFOUTPUT>
<!---
	Dev Notes: D23320/Anand Rao/17-May-10
	  User profile setting to view private documents
--->
  <!---
  SELECT * FROM Document_Details
			WHERE
			deleted = 0
			AND (	(	Public_View = 1
						AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
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
				<cfif FORM.Comp_Operator EQ "Between">
					AND DateDiff(d, '#FORM.From_Date#', Uploaded_Date) >= 0
					AND DateDiff(d, '#FORM.To_Date#', Uploaded_Date) <= 0
				<cfelse>
					AND DateDiff(d, '#FORM.From_Date#', Uploaded_Date) #FORM.Comp_Operator# 0
				</cfif>
			</CFIF>
			<CFIF FORM.Doc_Title NEQ "">
				AND DOC_Title LIKE '%#FORM.Doc_Title#%'
			</CFIF>
			<CFIF FORM.Doc_ID NEQ "">
				AND Doc_ID = '#FORM.Doc_ID#'
			</CFIF>
			ORDER BY #FORM.SORT_BY# #FORM.SORT_ORDER#

  ---->
		<CFQUERY NAME="ret_data" DATASOURCE="#Application.Datasource#">

IF OBJECT_ID('tempdb..##TMP_DOCUMENT_SEARCH') IS NOT NULL
  DROP TABLE ##TMP_DOCUMENT_SEARCH
  SELECT	Document_Details.*
  INTO	##TMP_DOCUMENT_SEARCH
  FROM    Document_Details
	<CFIF FORM.AttachedTo NEQ 0 AND  FORM.AttachedTo NEQ "">
		INNER JOIN Contract_Attachments
   		ON		Document_Details.Doc_ID  = Contract_Attachments.Doc_ID
    	AND   	(<cfif FORM.AttachedTo EQ "Billback">
					Contract_Attachments.billback_ID is not NULL
				<cfelseif FORM.AttachedTo EQ "Program">
					Contract_Attachments.Program_ID is not NULL
				<cfelseif FORM.AttachedTo EQ "Deduction">
					Contract_Attachments.deduction_ID  is not NULL
				<cfelse>
					Contract_Attachments.deleted = 0
				</cfif>)
	</CFIF>
  LEFT JOIN Profiles_Settings PS
  ON		PS.Profiles_ID = #Request.AccessStructure.Profiles_ID#   AND PS.View_Private_Documents = 1
  WHERE
    <CFIF FORM.deleted EQ 1>
	Document_Details.Deleted = 1
	and Document_Details.Deleted_Permanent = 0
    <CFELSEIF FORM.deleted EQ 2>
	1=2
    <CFELSE>
    Document_Details.Deleted = 0
    </CFIF>
    <cfif Form.Public_View EQ 1>
	and ( Public_View = 1   AND User_Position_ID IN (#Preservesinglequotes(Access_Position_List)#) )
    <cfelseif Form.Public_View EQ 0>
	and	Public_View = 0
    <cfelse>
    AND (
          ( Public_View = 1
  		    AND User_Position_ID IN (#Preservesinglequotes(Access_Position_List)#)
  				)
         OR Public_View = 0
        )
        AND
      (Document_Details.Uploaded_By = '#Request.AccessStructure.User_ID#' OR  Public_View =0)
    </cfif>
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
				<cfif FORM.Comp_Operator EQ "Between">
					AND DateDiff(d, '#FORM.From_Date#', Uploaded_Date) >= 0
					AND DateDiff(d, '#FORM.To_Date#', Uploaded_Date) <= 0
				<cfelse>
					AND DateDiff(d, '#FORM.From_Date#', Uploaded_Date) #FORM.Comp_Operator# 0
				</cfif>
			</CFIF>
			<CFIF FORM.Doc_Title NEQ "">
				AND DOC_Title LIKE '%#FORM.Doc_Title#%'
			</CFIF>
			<CFIF FORM.Doc_Description NEQ "">
				AND Doc_Description LIKE '%#FORM.Doc_Description#%'
			</CFIF>
			<CFIF FORM.Doc_File_Name NEQ "">
				AND Doc_File_Name LIKE '%#FORM.Doc_File_Name#%'
			</CFIF>
			<CFIF FORM.Doc_ID NEQ "">
				AND Doc_ID = '#FORM.Doc_ID#'
			</CFIF>

<cfif  Form.Public_View  NEQ 1  AND Form.Public_View  NEQ 0>
    INSERT INTO ##TMP_DOCUMENT_SEARCH
    SELECT	Document_Details.*
    FROM    Document_Details
	<CFIF FORM.AttachedTo NEQ 0 AND  FORM.AttachedTo NEQ "">
		INNER JOIN Contract_Attachments
    	ON		Document_Details.Doc_ID  = Contract_Attachments.Doc_ID
    	AND   (	<cfif FORM.AttachedTo EQ "Billback">
					Contract_Attachments.billback_ID is not NULL
				<cfelseif FORM.AttachedTo EQ "Program">
					Contract_Attachments.Program_ID is not NULL
				<cfelseif FORM.AttachedTo EQ "Deduction">
					Contract_Attachments.deduction_ID  is not NULL
				<cfelse>
					Contract_Attachments.deleted = 0
				</cfif>)
	</CFIF>
    INNER JOIN Profiles_Settings PS
    ON		PS.Profiles_ID = #request.accessStructure.Profiles_ID#  AND PS.View_Private_Documents = 1
    WHERE
	<CFIF FORM.deleted EQ 1>
		Document_Details.Deleted = 1
		and Document_Details.Deleted_Permanent = 0
	<CFELSEIF FORM.deleted EQ 2>
		1=2
	<CFELSE>
    	Document_Details.Deleted = 0
	</CFIF>
	<cfif Form.Public_View EQ 1>
		and ( Public_View = 1   AND User_Position_ID IN (#Preservesinglequotes(Access_Position_List)#) )
	<cfelseif Form.Public_View EQ 0>
		and	Public_View = 0
	<cfelse>
   AND
    ((Public_View = 1
         AND User_Position_ID IN (#Preservesinglequotes(Access_Position_List)#)
         )OR Public_View = 0
        )
	</cfif>
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
				<cfif FORM.Comp_Operator EQ "Between">
					AND DateDiff(d, '#FORM.From_Date#', Uploaded_Date) >= 0
					AND DateDiff(d, '#FORM.To_Date#', Uploaded_Date) <= 0
				<cfelse>
					AND DateDiff(d, '#FORM.From_Date#', Uploaded_Date) #FORM.Comp_Operator# 0
				</cfif>
			</CFIF>
			<CFIF FORM.Doc_Title NEQ "">
				AND DOC_Title LIKE '%#FORM.Doc_Title#%'
			</CFIF>
			<CFIF FORM.Doc_Description NEQ "">
				AND Doc_Description LIKE '%#FORM.Doc_Description#%'
			</CFIF>
			<CFIF FORM.Doc_File_Name NEQ "">
				AND Doc_File_Name LIKE '%#FORM.Doc_File_Name#%'
			</CFIF>
			<CFIF FORM.Doc_ID NEQ "">
				AND Doc_ID = '#FORM.Doc_ID#'
			</CFIF>
 </cfif>
     <cfif URL.BillbackList EQ "" AND Form.BillbackList eq "">
	 SELECT DISTINCT * FROM ##TMP_DOCUMENT_SEARCH ORDER BY #FORM.SORT_BY# #FORM.SORT_ORDER#
     <cfelse>
         <!--- If the request is for multiple billbacks or programs, then do not show a list of already selected billbacks or programs.
	Do TOP 0 here to retrun no records. --->
	 SELECT DISTINCT TOP 0 * FROM ##TMP_DOCUMENT_SEARCH ORDER BY #FORM.SORT_BY# #FORM.SORT_ORDER#
     </cfif>
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


	<FIELDSET STYLE="padding:8px; width: 780px; border: 1px solid Blue;">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There<CFIF ret_data.recordcount EQ 0> Are No Documents <CFELSEIF ret_data.recordcount EQ 1> Is A Document<CFELSE> Are <CFOUTPUT>#ret_data.recordcount#</CFOUTPUT> Documents</CFIF>  That Match This Criteria</LEGEND>
	<!------<FORM ACTION="contract_attachments.cfm?CID=<CFOUTPUT>#EncryptedCID#</CFOUTPUT>" METHOD="post" NAME="Attachsearch">
	<INPUT TYPE="hidden" NAME="formcheck" VALUE="1">----->
	<INPUT TYPE="hidden" NAME="formcheck" VALUE="0">
	<!--- <CFINCLUDE TEMPLATE="PM_Attachments_search.cfm"> --->
	<!--- Display the search result --->
	<!-----
	<CFSET A_Header_Value_List = "Uploaded_Date,Uploaded_By,Doc_File_Name,Doc_Title,Doc_Description,Doc_Type"><!---Doc_Description,Uploaded_By,Doc_Family  --->
<CFSET A_Header_Name_List = "Date,Name,File,Title,Description,Type">>

<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">
	<TR ID="header" BGCOLOR="ffce84" VALIGN="top">
		<TD ID="header">
			<input TYPE="checkbox" NAME="allbox" onclick="javaScript: selectAll(this);">
		</TD>
		<CFOUTPUT>
		<CFSET Counter = 1>
		<CFLOOP LIST="#A_Header_Value_List#" INDEX="ThisHeaderItem">
			<CFSET thisSortOrder = "ASC">
			<CFSET Image_Name = "/Images/down_1.gif">
			<CFSET ThisHeaderItemName = ListGetAt(A_Header_Name_List, Counter, ",")>
			<CFIF ThisHeaderItem EQ FORM.SORT_BY>
				<CFIF FORM.SORT_ORDER EQ "ASC">
					<CFSET thisSortOrder = "DESC">
					<CFSET Image_Name = "/Images/up_1.gif">
				</CFIF>
			</CFIF>
			<TD ID="header"><A HREF="##" onClick="javaSCript: return sort_by_this_order('#ThisHeaderItem#', '#thisSortOrder#');"><B>#ThisHeaderItemName#</B></A><CFIF ThisHeaderItem EQ FORM.SORT_BY>&nbsp;<IMG SRC="#Image_Name#" BORDER="0"></CFIF></TD>
			<CFSET Counter = Counter + 1>
		</CFLOOP>
		</CFOUTPUT>
	</TR>

	<CFSET This_Page_List = "">
	<CFSET disabled = "">
	<CFSET FORM.AlreadySelectedItems = "">
	<CFOUTPUT QUERY="ret_data" startrow="#StartRow#" maxrows="#MaxRows#">
 		<CFSET This_Page_List = ListAppend(This_Page_List, Doc_ID, ",")>

	<!--- <CFLOOP QUERY="ret_data"> --->

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<CFSET comp_doc_ID = #doc_ID#>
			<TD>
			<input TYPE="Checkbox" NAME="SelectedITEMS" VALUE="#Doc_ID#" <CFIF ListFindNoCase(FORM.FinalItemList, Doc_ID, ",")>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(Doc_ID), ",")></CFIF>>
			</TD>
			<CFQUERY NAME="sel_Name" DATASOURCE="#Application.Datasource#">
				SELECT Name_First, Name_Last FROM _Users
				RIGHT JOIN Document_Details ON Document_Details.Uploaded_By = _users.User_ID
				WHERE DOC_ID = '#Doc_ID#'
			</CFQUERY>
			<TD NOWRAP>#dateformat(Uploaded_Date,"mm/dd/yyyy")#<br>#Sel_Name.Name_First# #Sel_Name.Name_Last#&nbsp;</TD>
			<CFSET SIZEinMB = #Doc_size#/1024>
			<TD><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">#Doc_File_Name#</A><BR>#numberformat(SIZEinMB,"_.___")# KB&nbsp;</TD>
			<TD>#Doc_Title#<br>Description: #Doc_Description#&nbsp;</TD>
			<TD>#Doc_Type#&nbsp;</TD>
		</TR>
	</CFOUTPUT>


</TABLE>
	<INPUT TYPE="Hidden" NAME="This_Page_List" VALUE="<CFOUTPUT>#This_Page_List#</CFOUTPUT>">

-------------->

<CFSET A_Header_Value_List = "Uploaded_Date,Uploaded_By,Doc_File_Name,Doc_Title,Doc_Description,Doc_Type,Public_View"><!---Doc_Description,Uploaded_By,Doc_Family  --->
<CFSET A_Header_Name_List = "Date,Name,File,Title,Description,Type,Privacy">

<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">
	<TR ID="header" BGCOLOR="ffce84" VALIGN="top">
		<TD ID="header">
			<input TYPE="checkbox" NAME="allbox" onclick="javaScript: selectAll(this);">
		</TD>
		<CFOUTPUT>
		<CFSET Counter = 1>
		<CFLOOP LIST="#A_Header_Value_List#" INDEX="ThisHeaderItem">
			<CFSET thisSortOrder = "ASC">
			<CFSET Image_Name = "/Images/down_1.gif">
			<CFSET ThisHeaderItemName = ListGetAt(A_Header_Name_List, Counter, ",")>
			<CFIF ThisHeaderItem EQ FORM.SORT_BY>
				<CFIF FORM.SORT_ORDER EQ "ASC">
					<CFSET thisSortOrder = "DESC">
					<CFSET Image_Name = "/Images/up_1.gif">
				</CFIF>
			</CFIF>
			<CFIF LCase(ThisHeaderItemName) NEQ "name" AND LCase(ThisHeaderItemName) NEQ "description" AND LCase(ThisHeaderItemName) NEQ "privacy">
			<TD ID="header">
			<CFELSE>
			<BR>
			</CFIF>
			<A HREF="##" onClick="javaSCript: return sort_by_this_order('#ThisHeaderItem#', '#thisSortOrder#');"><B>#ThisHeaderItemName#</B></A><CFIF ThisHeaderItem EQ FORM.SORT_BY>&nbsp;<IMG SRC="#Image_Name#" BORDER="0"></CFIF>
			<CFIF LCase(ThisHeaderItemName) NEQ "date" AND LCase(ThisHeaderItemName) NEQ "title" AND LCase(ThisHeaderItemName) NEQ "type">
			</TD>
			</CFIF>
			<CFSET Counter = Counter + 1>
		</CFLOOP>
		</CFOUTPUT>
		<CFIF Form.bFromSettings EQ 1>
			<TD ID="header">&nbsp;</TD>
			<TD ID="header">&nbsp;</TD>
		</CFIF>
	</TR>

	<CFSET This_Page_List = "">
	<CFSET disabled = "">

	<CFOUTPUT QUERY="ret_data" startrow="#StartRow#" maxrows="#MaxRows#">
 		<CFSET This_Page_List = ListAppend(This_Page_List, Doc_ID, ",")>

	<!--- <CFLOOP QUERY="ret_data"> --->

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<CFSET comp_doc_ID = #doc_ID#>
			<TD WIDTH="3%">
			<!------<span ID="chkBoxCol"><input TYPE="Checkbox" NAME="Doc_ID" VALUE="#Doc_ID#" <CFLOOP query = "Current_sel"><CFIF comp_Doc_ID EQ doc_iD>checked</CFIF></CFLOOP>></span>----->
			<!----<input TYPE="Checkbox" NAME="Doc_ID" VALUE="#Doc_ID#" <CFIF ListFindNoCase(Current_Selection_List, comp_Doc_ID, ",")>CHECKED</CFIF>>--->
			<input TYPE="Checkbox" NAME="SelectedITEMS" VALUE="#Doc_ID#" <CFIF ListFindNoCase(FORM.FinalItemList, Doc_ID, ",")>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(Doc_ID), ",")></CFIF>>
			</TD>
			<CFSET SIZEinMB = #Doc_size#/1024>
			<CFQUERY NAME="sel_Name" DATASOURCE="#Application.Datasource#">
				SELECT Name_First, Name_Last FROM _Users
				RIGHT JOIN Document_Details ON Document_Details.Uploaded_By = _users.User_ID
				WHERE DOC_ID = '#Doc_ID#'
			</CFQUERY>
			<TD WIDTH="13%">#dateformat(Uploaded_Date,"mm/dd/yyyy")#<br>#Sel_Name.Name_First# #Sel_Name.Name_Last#&nbsp;</TD>
			<TD NOWRAP TITLE="File Name: #Doc_File_Name#"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
				<CFSET Display_Name=Left(Doc_File_Name,20)>
				<CFIF len(trim(Doc_File_Name)) GT 20>
					#LCASE(Display_Name)#...
				<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
					&nbsp;
				<CFELSE>
					#LCASE(Display_Name)#
				</CFIF>
				</A><BR>#numberformat(SIZEinMB,"_.___")# KB&nbsp;</TD>
			<TD WIDTH="58%">#Doc_Title#<br>Description: #Doc_Description#&nbsp;</TD>
			<TD WIDTH="12%">#Doc_Type#<br><cfif #Public_View# EQ 1> Yes <cfelse> No</cfif>&nbsp;</TD>
			<CFIF Form.bFromSettings EQ 1>
				<TD WIDTH="5%" NOWRAP aglin="center"  valign="middle">
					<FONT SIZE="1" COLOR="##FF0000"><B>[</B></FONT><A HREF="create_Document_Details.cfm?EditFromAdmin=1&RID=#Doc_ID#"  onclick="NewWindow(this.href,'help','700','550','Yes', 'No');return false;">edit</A><FONT SIZE="1" COLOR="##FF0000"><B>]</B></FONT>
				</TD>
				<cfset useLakebaseForShowDeleteLink = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
				<cfif useLakebaseForShowDeleteLink>
					<cftry>
						<cfset ShowDeleteLink = application.oLakebase.toQuery(
							application.oLakebase.selectRows("contract_attachments", { "doc_id" = "eq.#Doc_ID#", "select" = "doc_id" })
						, "Doc_ID")>
						<cfcatch type="any">
							<cfset useLakebaseForShowDeleteLink = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForShowDeleteLink>
					<CFQUERY NAME="ShowDeleteLink" DATASOURCE="#Application.Datasource#">
						SELECT Doc_ID
						FROM Contract_Attachments
						WHERE DOC_ID = '#Doc_ID#'
					</CFQUERY>
				</cfif>
				<cfif ShowDeleteLink.recordcount EQ 0>
					<TD  NOWRAP aglin="center" valign="middle">
						<a href="" onClick="JavaScript: return deleteDoc('#Doc_ID#');"><img src="/images/no_small.gif" TITLE="Delete Document" BORDER="0"></a>
					</TD>
				<cfelse>
					<TD>&nbsp;</TD>
				</cfif>
			</CFIF>
		</TR>
	</CFOUTPUT>
</TABLE>
<INPUT TYPE="Hidden" NAME="This_Page_List" VALUE="<CFOUTPUT>#This_Page_List#</CFOUTPUT>">


	<!--- ############################# --->
	<CFIF Form.bFromSettings NEQ 1>
	<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
		<A HREF="javascript: save_Documents();"><B>attach selected documents</B></A>
	<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
	</CFIF>
	<!--- <CFOUTPUT>
	<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
		<A HREF="/Common_Files/Documents/create_document_details.cfm" ONCLICK="javascript: return upload_doc(this);"><B>upload documents</B></A><!--- FromProgram=1&CID=#URL.CID#<CFIF FORM.Uploaded_By NEQ "">&Uploaded_By=#FORM.Uploaded_By#</CFIF><CFIF FORM.Doc_Type NEQ "">&Doc_Type=#FORM.Doc_Type#</CFIF><CFIF FORM.Doc_Family NEQ "">&Doc_Family=#FORM.Doc_Family#</CFIF><CFIF FORM.Comp_Operator NEQ "">&Comp_Operator=#FORM.Comp_Operator#&From_Date=#FORM.From_Date#</CFIF><CFIF FORM.Comp_Operator EQ "Between">&To_Date=#FORM.To_Date#</CFIF> --->
	<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
	</CFOUTPUT>  --->
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
	</FIELDSET>
	</CFIF>

	<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="Form_Name" 			VALUE="#FORM.Form_Name#">
	<INPUT TYPE="hidden" NAME="FinalItemList" 			VALUE="#Form.FinalItemList#">
	<INPUT TYPE="hidden" NAME="AlreadySelectedItems" 	VALUE="#Form.AlreadySelectedItems#">
	<INPUT TYPE="hidden" NAME="finishedselectingitems" 	VALUE="0">
	<INPUT TYPE="hidden" NAME="from_common_attachment" 	VALUE="1">
	<INPUT TYPE="hidden" NAME="BillbackList" 		VALUE="#BillbackList#">
	<INPUT TYPE="hidden" NAME="ProgramList" 		VALUE="#Form.ProgramList#">
	<INPUT TYPE="hidden" NAME="FlexAppName" 		VALUE="#FlexAppName#">
	</CFOUTPUT>
	</FORM>
</cfmodule>
