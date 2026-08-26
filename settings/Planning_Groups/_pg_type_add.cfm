<!-----------------------------------------------------------------------------

FILE NAME:		_pg_type_add.cfm
DESCRIPTION:	This is the details file that is used to Add the Type record.
CREATED BY:		05-Oct-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

      			Anand Rao	  05-Oct-2010	Created the file
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

<!--- <cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplates() /> --->
 <cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplatesForPGWithFilters('#New_Sort_Order#') />

<cfoutput>

<!--- <input type="hidden" name="PGClassificationID" value="" /> --->
<input type="hidden" name="iTemplateCount" value="#qryTemplateList.RecordCount#" />


 <FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Planning Group Type Information</LEGEND>

    <table  border="1" width="782"  cellpadding="5" cellspacing="0"  rules="groups" bordercolor="800000" style="border-radius:5px;">
		<!------ external id ----->
		<tr>
		<td colspan="2">	<font color="red" size="4">*</font> - Required Field</td>
		</tr>
  		<tr>
  			<td align="right" width="30%"><b>Type ID:</b></td>
  			<td><input name="TypeID" type="text" size="12" maxlength="50" <cfif (isDefined("FORM.TypeID") AND FORM.TypeID NEQ "")>value="#FORM.TypeID#"<cfelse>value=""</cfif>></td><!--- #FORM.MarginItemExclusionCode# --->
  		</tr>
  		<tr>
  			<td align="right"<!---  class="Orangline" ---> width="30%"><B>Type Name<font color="red" size="2">*</font>:</B></td>
  			<td><input name="TypeName" type="text" maxlength="100"  style="width:220px" <cfif (isDefined("FORM.TypeName") AND FORM.TypeName NEQ "")>value="#FORM.TypeName#"<cfelse>value=""</cfif>></td>
  		</tr>
  		<tr>
  			<td align="right"   width="30%"><B>Type Category<font color="red" size="2">*</font>:</B></td>
  			<td>
          <input type="radio" name="rdoTypeCategory" value="1" <cfif (isDefined("FORM.rdoTypeCategory") AND FORM.rdoTypeCategory EQ "1")>checked</cfif>> #application.returned_customer_setting.Item_Label#
          <input type="radio" name="rdoTypeCategory" value="2" <cfif (isDefined("FORM.rdoTypeCategory") AND FORM.rdoTypeCategory EQ "2")>checked</cfif>> #application.returned_customer_setting.distributor_label_singular#
          <input type="radio" name="rdoTypeCategory" value="3" <cfif (isDefined("FORM.rdoTypeCategory") AND FORM.rdoTypeCategory EQ "3")>checked</cfif>> #application.returned_customer_setting.Operator_Label_Singular#
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
                 <center> <INPUT Name="allboxSearch"  id="allboxSearch" TYPE="Checkbox" onClick="selectAllLike(this,'chkBoxSearch_')" TITLE="Click here to select all Templates"></center>
                </td>
                <td width="7%">
                  <strong>In Group Search</strong>
                  <center><INPUT Name="allboxGroup" id="allboxGroup" TYPE="Checkbox" onClick="selectAllLike(this,'chkBoxGroup_')" TITLE="Click here to select all Templates"></center>
                </td>
              </tr>

              <cfloop query="qryTemplateList" startRow = 1 endRow="#RecCountVal#">
               <tr>
               <!---  <td> <INPUT Name="allbox" TYPE="Checkbox"></td> --->
                <td width="25" height="34" align="center">
                  #iCount#
                </td>
                <td>
                  &nbsp;#qryTemplateList.Created_Type#
                </td>
                <td width="7%" align="center">
                  <input type="Checkbox" name="chkBoxSearch_#qryTemplateList.First_Parent_ID#_" ID="chkBoxSearch_#qryTemplateList.First_Parent_ID#_" value="#qryTemplateList.First_Parent_ID#" />
                </td>
                <td width="7%" align="center">
                  <input type="Checkbox" name="chkBoxGroup_#qryTemplateList.First_Parent_ID#_" ID="chkBoxGroup_#qryTemplateList.First_Parent_ID#_" value="#qryTemplateList.First_Parent_ID#" />
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
                      <center><INPUT Name="allboxSearch"  id="allboxSearch" TYPE="Checkbox" onClick="selectAllLike(this,'chkBoxSearch_')" TITLE="Click here to select all Templates"></center>
                  </td>
                  <td width="7%">
                    <strong>In Group Search</strong>
                      <center><INPUT Name="allboxGroup" id="allboxGroup" TYPE="Checkbox" onClick="selectAllLike(this,'chkBoxGroup_')" TITLE="Click here to select all Templates"></center>
                  </td>
              </tr>
              <cfloop query="qryTemplateList" startRow = "#ReccountVal+1#" endRow="#RecCount#">
               <tr>
                <td width="25" height="34" align="center">
                  #iCount#
                </td>
                <td>
                  &nbsp;#qryTemplateList.Created_Type#
                </td>
                <td width="7%" align="center">
                  <input type="Checkbox" name="chkBoxSearch_#qryTemplateList.First_Parent_ID#_"  ID="chkBoxSearch_#qryTemplateList.First_Parent_ID#_" value="#qryTemplateList.First_Parent_ID#"  />
                </td>
                <td width="7%" align="center">
                  <input type="Checkbox" name="chkBoxGroup_#qryTemplateList.First_Parent_ID#_" ID="chkBoxGroup_#qryTemplateList.First_Parent_ID#_" value="#qryTemplateList.First_Parent_ID#" />
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
               <CF_smallLink
  			title = "Save"
  			url = "##"
  			parameters = "onClick=""javascript: return fnChkPGType();"""
  		>
              </td>
            </tr>
    </table>   <br>


 <br>
 	<input type="hidden" name="bSubmit" value="0" />
  <input type="hidden" name="typepageAction2" value="" /><!--- TypeAddSave --->

<cfif NOT isDefined("FORM.pageAction2")>
	<input type="hidden" name="pageAction2" value="TypeAddSave" />
</cfif>

<input type="hidden" name="TypeRefresh" value="0" />

  <cfif FORM.display EQ "add">
      <input type="hidden" name="productRefresh" value = "0" />
  </cfif>
	<script>
	///////////////////////////////////   Update Component //////////////////////////////////////////

  function fnChkPGType()
  {

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

    document.DataForm.display.value = 'active';
    document.DataForm.pageAction2.value= "TypeAddSave";
    document.DataForm.typepageAction2.value= "TypeAddSave";

   //  alert(document.DataForm.pageAction2.value);
	  document.DataForm.submit();
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
  </script>

</cfoutput>