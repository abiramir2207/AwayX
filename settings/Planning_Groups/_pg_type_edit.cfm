<!-----------------------------------------------------------------------------

FILE NAME:		_pg_type_edit.cfm
DESCRIPTION:	This is the details file that is used to Edit the Type record.
CREATED BY:		23-Nov-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

      			Anand Rao	  23-Nov-2010	Created the file
------------------------------------------------------------------------------>

<style>
.Orangline
{
	border-right: 2px solid orange;
	/* width:400 px; */
}
.topLine
{
	border-top: 2px solid a85400;
	/* width:400 px; */
}
</style>
<cfif FORM.tmpltSearchKeyword NEQ "">
	<cfset vSearchKeyword = FORM.tmpltSearchKeyword />
<cfelse>
	<cfset vSearchKeyword = "" />
</cfif>

<cfset qryGetPGTypeByID = PGManager.fnGetPGTypeByID('#FORM.PGTypeID#') />
<cfif qryGetPGTypeByID.RecordCount EQ 0>
  <strong>  <font color="red">This Type Record could not be found!!</font></strong>
  <cfabort>
</cfif>
<cfset qryGetGroupTemplateByPGTypeID = PGManager.fnGetGroupTemplateByPGTypeID('#FORM.PGTypeID#') />
 <!--- <cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplates() />   --->
<cfif (vSearchKeyword EQ "")>
	<cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplatesForPGWithFilters('#New_Sort_Order#') />
<cfelse>
	<cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplatesForPGWithFilters(Sort_Order='#New_Sort_Order#',SearchKW = '#vSearchKeyword#') />
</cfif>

<cfoutput>
 <cfif qryGetPGTypeByID.Updated_Date NEQ "">
    <table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="0"  align="center" width="600">
      <tr>
        <td>
          <cfoutput>
    	      <font size="2"><b>The settings were last updated on #dateformat(qryGetPGTypeByID.Updated_Date, 'mm/dd/yyyy')# #timeformat(qryGetPGTypeByID.Updated_Date, 'hh:mm:ss TT')# by #qryGetPGTypeByID.Name_First# #qryGetPGTypeByID.Name_Last#</b></font>
          </cfoutput>
        </td>
      </tr>
    </table>
 </cfif>

<input type="hidden" name="iTemplateCount" value="#qryTemplateList.RecordCount#" />

<cfif NOT isDefined("FORM.pageAction2")>
	<input type="hidden" name="pageAction2" value="TypeEditSave" />
</cfif>


<input type="hidden" name="TypeRefresh" value="0" />

 <FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Planning Group Type Information</LEGEND><br>

    <table  border="1" width="782"  cellpadding="5" cellspacing="0"  rules="groups" bordercolor="800000" style="border-radius:5px;">

		<tr>
			<td colspan="2"> <font color="red" size="5">*</font> - Required Field</td>
		</tr>
  		<tr>
  			<td align="right" width="30%"><b>Type ID:</b></td>
  			<td><input name="TypeID" type="text" value="#qryGetPGTypeByID.PG_Type_Code#" size="12" maxlength="50" ></td><!--- #FORM.MarginItemExclusionCode# --->
  		</tr>
  		<tr>
  			<td align="right"<!---  class="Orangline" ---> width="30%"><B>Type Name<font color="red" size="2">*</font>:</B></td>
  			<td><input name="TypeName" type="text" maxlength="100" value="#qryGetPGTypeByID.PG_Type_Name#" style="width:220px" ></td>
  		</tr>
  		<tr>
  			<td align="right"   width="30%"><B>Type Category :</B></td>
  			<td>

        <input type="radio" name="rdoTypeCategory" value="1" <cfif qryGetPGTypeByID.PG_Group_Type EQ "1">checked</cfif>  style="display:none;">
        <input type="radio" name="rdoTypeCategory" value="2" <cfif qryGetPGTypeByID.PG_Group_Type EQ "2" >checked</cfif> style="display:none;">
  			<input type="radio" name="rdoTypeCategory" value="3" <cfif qryGetPGTypeByID.PG_Group_Type EQ "3" >checked</cfif> style="display:none;">

        <input type="radio" name="rdoTypeCategorydummy" value="1" <cfif qryGetPGTypeByID.PG_Group_Type EQ "1">checked</cfif> disabled> #application.returned_customer_setting.Item_Label# <input type="radio" name="rdoTypeCategorydummy" value="2" disabled <cfif qryGetPGTypeByID.PG_Group_Type EQ "2" >checked</cfif> > #application.returned_customer_setting.distributor_label_singular#
				<input type="radio" name="rdoTypeCategorydummy" value="3" disabled <cfif qryGetPGTypeByID.PG_Group_Type EQ "3">checked</cfif> > #application.returned_customer_setting.Operator_Label_Singular#
				</td>

  		</tr>

      <tr>
        <td colspan="2">
        <!--- TEMPLATE SECTION STARTS --->

 <fieldset id="border_4" style="border-width:0; border-color:; border-style:solid; width:760">
     <legend>
      <span>
        <img id="image_4" src="/images/plus2.gif" onclick="switchlayer(4,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy');toggleTemplate();" border="0" title="" style="cursor:pointer">
       <font face="Arial">
        <b style="font-size:9pt">
         <span id="title_4" onclick="switchlayer(4,'Hide Planning Group','Show Planning Group',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy');toggleTemplate();" style="color:00773c;cursor:pointer">
          <span title="Click here to toggle the view">
			      Templates
          </span>
         </span>
        </b>
       </font>
     </legend>
	<cfif FORM.templateExpanded EQ "1">
		<cfset dispVal = "block" />
	<cfelse>
		<cfset dispVal = "none" />
	</cfif>
    <div id="lyrgroup_4" style="display:<cfoutput>#dispVal#</cfoutput>; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;">
	<table width="100%" cellpadding="2"><tr><td align="left">
 		<input type="text" name="tmpltSearchKW" id="tmpltSearchKW" value="#vSearchKeyword#" >
		 <CF_smallLink
		  			title = "Search"
		  			url = "##"
		  			parameters = "onClick=""javascript:getSearchURL('1');return false;"""
				mouseovernotes = "Searches the Template Name"
		  		>
		 <CF_smallLink
		  			title = "Clear"
		  			url = "##"
		  			parameters = "onClick=""javascript:getSearchURL('2');return false;"""
				mouseovernotes = "Clears the Template Name"
		  		>
		</td></tr></table>
      <div id="masterContainer" style="position:relative;overflow:scroll;height:430px;">
 	  <!--- Contents go here STARTS --->
      <cfset RecCount =  qryTemplateList.RecordCount />
      <cfset Remaining = RecCount MOD 2 />
      <cfif Remaining EQ 1>
        <cfset RecCountVal = ((RecCount -1)/2)+1 />
      <cfelseif  Remaining EQ 0>
        <cfset RecCountVal = (RecCount)/2 />
      </cfif>
      <cfset iCount = 1 />
<!---         <table width="100%" border="1" cellpadding="5" cellspacing="0" cols="groups" rules="groups" bordercolor="a85400">        --->
        <table cellpadding="2" cellspacing="0" width="100%" border="1" bordercolor="##dd6f00" rules="groups">
          <tr>
            <td width="50%"  valign="top">
              <!--- 1st TD table STARTS --->
              <table cellpadding="2" cellspacing="1" width="100%" border="1" bordercolor="##979797">
              <tr>
                <td width="5">
                  <strong>No.</strong>
                </td>
                <td>
                   <strong><a href="##" OnClick="javaScript: return sortByThisItem(this,'TYPE','#New_Sort_Order#');">&nbsp;Template Name<img border="0" src="/Images/#sortImage#"></A></strong>
                </td>
                <td width="7%">
                  <strong>Field in <!--- #application.returned_customer_setting.distributor_label_singular# ---> Search </strong><br>
                 <center> <INPUT Name="allbox" TYPE="Checkbox" onClick="selectAllLike(this,'chkBoxSearch_')" TITLE="Click here to select all Templates"></center>
                </td>
                <td width="7%">
                  <strong>In Group Search</strong>
                  <center><INPUT Name="allbox" TYPE="Checkbox" onClick="selectAllLike(this,'chkBoxGroup_')" TITLE="Click here to select all Templates"></center>
                </td>
              </tr>

              <cfloop query="qryTemplateList" startRow = 1 endRow="#RecCountVal#">
                <cfset chkboxSearchChecked = 0 />
                <cfset chkboxGroupChecked = 0 />
                <cfloop query="qryGetGroupTemplateByPGTypeID">
                  <cfif (qryGetGroupTemplateByPGTypeID.Template_ID EQ qryTemplateList.First_Parent_ID)>
                    <cfset chkboxSearchChecked = qryGetGroupTemplateByPGTypeID.Allow_In_Search />
                    <cfset chkboxGroupChecked = qryGetGroupTemplateByPGTypeID.Allow_In_Group_Search />
                  </cfif>
                </cfloop>

               <tr>
                <!--- <td> <INPUT Name="allbox" TYPE="Checkbox"></td> --->
                <td width="25" height="34" align="center">
                  #iCount#
                </td>
                <td>
                  &nbsp;#qryTemplateList.Created_Type#
                </td>
                <td width="7%" align="center">
                  <input type="Checkbox" name="chkBoxSearch_#qryTemplateList.First_Parent_ID#_" ID="chkBoxSearch_#qryTemplateList.First_Parent_ID#_" <cfif (chkboxSearchChecked EQ 1)>checked</cfif> value="#qryTemplateList.First_Parent_ID#" />
                </td>
                <td width="7%" align="center">
                  <input type="Checkbox" name="chkBoxGroup_#qryTemplateList.First_Parent_ID#_" ID="chkBoxGroup_#qryTemplateList.First_Parent_ID#_" <cfif (chkboxGroupChecked EQ 1)>checked</cfif> value="#qryTemplateList.First_Parent_ID#" />
                </td>
              </tr>
              <cfset iCount++ />
              </cfloop>

              </table>
              <!--- 1st TD table ENDS --->
              </td>
              <td width="50%" valign="top">
              <!--- 2nd TD table STARTS --->
              <table cellpadding="2" cellspacing="1" width="100%" border="1" bordercolor="##979797">
                <tr>
                  <td width="5">
                    <strong>No.</strong>
                  </td>
                  <td>
                   <strong><a href="##" OnClick="javaScript: return sortByThisItem(this,'TYPE','#New_Sort_Order#');">&nbsp;Template Name<img border="0" src="/Images/#sortImage#"></A></strong>
                  </td>
                  <td width="7%">
                    <strong>Field in <!--- #application.returned_customer_setting.distributor_label_singular# ---> Search </strong>
                      <center><INPUT Name="allbox" TYPE="Checkbox" onClick="selectAllLike(this,'chkBoxSearch_')" TITLE="Click here to select all Templates"></center>
                  </td>
                  <td width="7%">
                    <strong>In Group Search</strong>
                      <center><INPUT Name="allbox" TYPE="Checkbox" onClick="selectAllLike(this,'chkBoxGroup_')" TITLE="Click here to select all Templates"></center>
                  </td>
              </tr>
              <cfloop query="qryTemplateList" startRow = "#ReccountVal+1#" endRow="#RecCount#">
                <cfset chkboxSearchChecked = 0 />
                <cfset chkboxGroupChecked = 0 />
                <cfloop query="qryGetGroupTemplateByPGTypeID">
                  <cfif (qryGetGroupTemplateByPGTypeID.Template_ID EQ qryTemplateList.First_Parent_ID)>
                    <cfset chkboxSearchChecked = qryGetGroupTemplateByPGTypeID.Allow_In_Search />
                    <cfset chkboxGroupChecked = qryGetGroupTemplateByPGTypeID.Allow_In_Group_Search />
                  </cfif>
                </cfloop>
               <tr>
                <!--- <td> <INPUT Name="allbox" TYPE="Checkbox"></td> --->
                <td width="25" height="34" align="center">
                  #iCount#
                </td>
                <td>
                  &nbsp;#qryTemplateList.Created_Type#
                </td>
                <td width="7%" align="center">
                  <input type="Checkbox" name="chkBoxSearch_#qryTemplateList.First_Parent_ID#_" ID="chkBoxSearch_#qryTemplateList.First_Parent_ID#_" <cfif (chkboxSearchChecked EQ 1)>checked</cfif> value="#qryTemplateList.First_Parent_ID#" />
                </td>
                <td width="7%" align="center">
                  <input type="Checkbox" name="chkBoxGroup_#qryTemplateList.First_Parent_ID#_" ID="chkBoxGroup_#qryTemplateList.First_Parent_ID#_" <cfif (chkboxGroupChecked EQ 1)>checked</cfif> value="#qryTemplateList.First_Parent_ID#" />
                </td>
              </tr>
                 <cfset iCount++ />
              </cfloop>


             </table>
            <!--- 2nd TD table ENDS --->
            </td>
            </tr>
          </table>


      <!--- Contents go here ENDS --->
      </div>
    </div>
<!--- TEMPLATE SECTION ENDS  --->

        </td>
      </tr>
 <tr>
              <td colspan="2" align="center">
				<cfif Get_Profile_Settings.Planning_Groups_Create EQ 2>
	               	<CF_smallLink
	  					title = "Save"
	  					url = "##"
	  					parameters = "onClick=""javascript: return fnChkPGTypeEdit();""">
				<cfelse>
					<CF_smallLink
						title="Back"
						url = "##"
	  					parameters = "onClick=""javascript: history.back();""">
				</cfif>
				
              </td>
            </tr>
    </table>   <br>


 <br>



 	<input type="hidden" name="bSubmit" value="0" />
  <cfif FORM.display EQ "add">
      <input type="hidden" name="productRefresh" value = "0" />
  </cfif>
	<script>
	///////////////////////////////////   Update Component //////////////////////////////////////////

  function fnChkPGTypeEdit()
  {

		//var varREX = new RegExp("[`'~!@##$%^:;&*(){}?+-=_|/.,�����<>0-9a-zA-Z \r]", "g");
		var varREX = new RegExp("[~!$%^:;&*(){}?+-=_|/.,<>0-9a-zA-Z \r]", "g");
		var error = 0;
		var v1 = '"';
		var v2='\\';
		var v3='[';
		var v4=']';

    if (trim(DataForm.TypeName.value) == "")
		{
			alert("Please provide a Type Name");
			return false;
		}
     m = trim(DataForm.TypeName.value);
    // alert(document.getElementById('rdoTypeCategory'));
    if ((eval("DataForm.rdoTypeCategory[0].checked") == false) && (eval("DataForm.rdoTypeCategory[1].checked") == false) && (eval("DataForm.rdoTypeCategory[2].checked") == false))
    {
      alert("Select a Type Category!");
      return false;
    }
		for (i = 0; i < m.length; i++)
    {
      if ((m.substring(i,i+1)).match(varREX) == null)
      {
            // since the regular expression  was not working right for the chars ",\ a separate we are doing a check for those
            // characters here
						// (m.substring(i,i+1)== v1) ||
      	if (!((m.substring(i,i+1)== v2) || (m.substring(i,i+1)== v3) || (m.substring(i,i+1)== v4)))
        {
        	error = error +  1;
          break;
         }
       }
		}
 		if (error > 0)
    {
			alert("Some of the special characters entered in Type Name are not supported, please change them!");
      return false;
    }
    DataForm.display.value = 'active';
    DataForm.pageAction2.value = 'TypeEditSave'
	  DataForm.submit();
		return false;
  }



  function deleteThisProduct(FieldNameRe, prodID, bgCol, GroupID)//,realGroupLevelId
	{
			var srcObj = event.srcElement;
			var trObj = getParentObject(srcObj, "tr");
			var trIndex = trObj.rowIndex;
			var FINALITEMLIST = document.DataForm.Product_List.value;
      var FINALGROUPLIST = document.DataForm.Allow_Approval_group.value;
			var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
      var grpResultString = ListDeleteItem(FINALGROUPLIST, ",", GroupID);
			var bDelete = true;
			var objGroupLevel;
 			var itemCount = FINALITEMLIST.split(",");
      var groupCount = FINALGROUPLIST.split(",");

      if (prodID != "")
      {
        if (resultString == FINALITEMLIST)
        {
          resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
          bDelete = false;
        }
      }
      if (GroupID != "")
      {
        if (grpResultString == FINALGROUPLIST)
        {
          grpResultString = ListAppendItem(FINALGROUPLIST, ",", GroupID);
          bDelete = false;
        }
      }
		 	document.DataForm.Product_List.value = resultString;
		  document.DataForm.Allow_Approval_group.value = grpResultString;
			var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
			if(trObj)
			{
			  if(bDelete)
				{
					trObj.height = trObj.offsetHeight;
					//trObj.cells[trObj.cells.length-1].innerHTML = empty_String;
					propogateProperty(trObj, "style.backgroundColor", "##DDDDDD", false);
					propogateProperty(trObj, "style.textDecoration", "line-through", true);
					srcObj.title = "Deleted";
					srcObj.src = undodeleteImg.src;
				}
 				else
				{
					propogateProperty(trObj, "style.backgroundColor", "##eeeeee", false);
					propogateProperty(trObj, "style.textDecoration", "none", false);
					// unDeleteProduct(prodCompId);//prodCompId=contract_product_id
					srcObj.title = "delete this product";
					srcObj.src = deleteImg.src;
					propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);
			 	}
				srcObj.bDelete = !bDelete;
				trObj.bDelete = (bDelete?1:0);
				}
		}

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

	function getSearchURL(searchMode)
	{
		if (searchMode == "1")
		{
			var txtSearch = document.getElementById('tmpltSearchKW').value;
		}
		else
		{
			document.getElementById('tmpltSearchKW').value = "";
			var txtSearch = document.getElementById('tmpltSearchKW').value;
		}
		location.href="index.cfm?type=type&subtype=edit&ID=#FORM.PGTypeID#&TemplateExpanded=true&tmpltSearchKeyword=" + txtSearch;
	}
  </script> <!--- // &OrderByField=#vOrderByField#&OrderBy=#newOrderBy# --->

</cfoutput>