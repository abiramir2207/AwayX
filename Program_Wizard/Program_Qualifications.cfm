<!---
  Copyright (c)2013 Blacksmith Applications, Inc.
  Filename:   C:\Work\base\AwayX\Program_Wizard\Program_Qualifications.cfm
  Created:    4/24/2013
  Developer:    drachala
  Usage:      this file provide an option to user to create/delete/inactive a qualification which later used in program left hand side link page "qualifications"
--->
<cfparam name="url.rid" default="0">
<cfparam name="blnsubmit" default="0">
<cfparam name="url.edit" default="0"><!--- --->
<CFSET URL.PageTitle="Qualifications">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif blnSubmit IS 1>

<cfparam name="form.Store_Operator_Type" default="0" />

<!---trim off extra characters due to limits defined in database schema--->
<cfset form.requirement_name = application.util.string.fullLeft(form.requirement_name, application.util.query.columnMaxLength( "Program_Qualifications.qualification_name" ))>

<cfif form.program_qualification_id eq "">
    <cfset value ="">
    <cfif form.totaloptions>
      <cfloop from="1" to="#form.totaloptions#" index="i">
        <cfif len(form["option" & i])>
          <cfset value = listappend(value, #form["option" & i]#)>
        </cfif>
      </cfloop>
    <cfelse>
      <cfset value = #form.option1#>
    </cfif>

        <cfset useLakebaseForcheckname = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_qualifications")>
<cfif useLakebaseForcheckname>
	<cftry>
		<cfset checkname = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_qualifications", {
				"qualification_name" = "eq.#form.requirement_name#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckname = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckname>
<cfquery name="checkname" datasource="#application.datasource#">
          SELECT *
          FROM Program_Qualifications
          WHERE qualification_name = '#form.requirement_name#'
        </cfquery>
</cfif>
        <cfif checkname.recordcount EQ 0>
          <!--- insert the record --->
          <cfquery name="save_data" datasource="#application.datasource#">
            INSERT INTO Program_Qualifications(
                      qualification_name
                      ,type
                      ,value
                      ,isactive
                      ,Updated_By
					  ,Store_Operator_Type
                      )
            VALUES  ('#form.requirement_name#'
                    ,#form.type#
                    ,'#value#'
                    ,#form.active#
                    ,'#request.AccessStructure.User_ID#'
					,'#form.Store_Operator_Type#'
                    )
          </cfquery>
        <cfelse>
          <table bgcolor="white" bordercolor="red" border="1" cellpadding="3" cellspacing="0">
            <tr>
              <td>
              <font size="2"><b><cfoutput>#form.requirement_name#</cfoutput> already exists</font></b>
              </td>
            </tr>
          </table>
        <br>
        </cfif>

<cfelseif form.deleterecord AND form.program_qualification_id neq "">
    <cfquery name="delete_data" datasource="#application.datasource#">
      UPDATE Program_Qualifications
      SET deleted = 1
      WHERE Program_Qualification_id = '#form.program_qualification_id#'
    </cfquery>

<cfelseif ! form.deleterecord AND form.program_qualification_id neq "">
    <cfset value ="">
    <cfloop from="1" to="#form.totaloptions#" index="i">
      <cfif #len(form["option" & i])#>
        <cfset value = listappend(value, #form["option" & i]#)>
      </cfif>
    </cfloop>

    <cfset useLakebaseForupdate_data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_qualifications")>
<cfif useLakebaseForupdate_data>
	<cftry>
		<cfset application.oLakebase.updateRows("program_qualifications",
			{
				"program_qualification_id" = "eq.#form.program_qualification_id#"
			},
			{
				"qualification_name" = "#form.requirement_name#",
				"type" = "#form.type#",
				"value" = "#value#",
				"isactive" = "#form.active#",
				"updated_by" = "#request.AccessStructure.User_ID#",
				"store_operator_type" = "#form.Store_Operator_Type#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdate_data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdate_data>
<cfquery name="update_data" datasource="#application.datasource#">
      UPDATE Program_Qualifications
      SET qualification_name = '#form.requirement_name#',
      type = #form.type#,
      value ='#value#',
      isactive = #form.active#,
      Updated_By = '#request.AccessStructure.User_ID#',
	  Store_Operator_Type = '#form.Store_Operator_Type#'
      WHERE Program_Qualification_id = '#form.program_qualification_id#'
    </cfquery>
</cfif>
    </cfif>
</cfif>


<CFQUERY NAME="Get_LastUpdated_Details" datasource="#application.datasource#">
  Select    TOP 1 *
  From    Program_Qualifications
  <CFIF URL.RID NEQ 0>
  Where   Program_Qualification_ID = '#URL.RID#'
  </CFIF>
  Order by  Date_Updated Desc
</CFQUERY>

<CFIF Get_LastUpdated_Details.Recordcount GT 0>
  <CFQUERY NAME="getUserName" datasource="#application.datasource#">
    SELECT  _Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
    FROM  _Users
    WHERE   User_ID = '#Get_LastUpdated_Details.Updated_By#'
  </CFQUERY>
</CFIF>

    <CFIF Get_LastUpdated_Details.RecordCount GT 0>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<tr>
  <td>
        <FONT SIZE="2"><B>This <cfif url.RID NEQ 0>file <cfelse> setting</cfif> was last updated on <CFOUTPUT>#dateformat(Get_LastUpdated_Details.Date_Updated, 'm/d/yyy')# #timeformat(Get_LastUpdated_Details.Date_Updated, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B></FONT>
  </td>
</tr>
</table>
    </CFIF>

<cfset useLakebaseForvariables_qRows = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_qualifications")>
<cfif useLakebaseForvariables_qRows>
	<cftry>
		<cfset variables.qRows = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_qualifications", {
				"deleted" = "eq.0",
				"order" = "program_qualification_id.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qRows = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qRows>
<cfquery name="variables.qRows" datasource="#application.datasource#">
  select    *
  from    Program_Qualifications
  where deleted = 0
  order by Program_Qualification_ID
</cfquery>
</cfif>

<table border="0" cellspacing="10" cellpadding="0" width="100%" style="table-layout:fixed;">
<col width="50%">
<col width="50%">
  <tr>
    <td valign="top">
      <span class="title2">Existing Qualifications Requirements</span>
      <hr color="blue" size="1">

        <table border="0" cellspacing="0" cellpadding="2" width="100%" class="maintable">
          <col width="80%">
          <col width="20%">
            <tr>
                <td nowrap width="100%"><span style="font-size: 12px;"><b>Description</b></span></td>
                <td nowrap><span style="font-size: 12px;"><b>Status</b></span></td>
            </tr>
            <cfoutput query="variables.qRows">
            <tr>
                <td wrap><a href="program_qualifications.cfm?rid=#program_qualification_id#&edit=1">#variables.qRows.qualification_Name#</a></td>
                <td nowrap style="text-align:center;">
                  <cfif variables.qRows.isactive eq 1>
                    <img src="/images/yes_small.gif" title="active record...">
                  <cfelse>
                    <img src="/images/no_small.gif" title="inactive record...">
                  </cfif>
                </td>
            </tr>
            </cfoutput>
        </table>
      <br>
      <img src="/images/yes_small.gif" border="0" alt="" align="middle"> - Active record<br>
      <img src="/images/no_small.gif"   border="0" alt="" align="middle"> - Inactive record
    </td>
<td>
      <span class="title2">edit record</span>
      <hr color="blue" size="1">
      <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
      <!--- retrieve the data for the id of the item passed --->
      <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

      <cfparam name="dd_type_name" default="">
      <cfparam name="dd_reminder_type_id" default="">
      <cfparam name="get_item.deleted" default="0">

      <cfquery name="get_item" datasource="#application.datasource#">
        select    *
        from    program_qualifications
        where   program_qualification_id  like  '#url.rid#'
        and deleted = 0
      </cfquery>
        <form action="program_qualifications.cfm" method="post" name="MyForm" style="width:100%;margin:0;padding:0;">
            <table cellpadding="4 width="100%" border="0">
              <cfoutput>
              <tr>
                <td valign="top"><b>Description:</b></td>
                <td>
                  <!---<input size="62" name="requirement_name" value="#get_item.qualification_name#" maxlength="70">--->
                  <textarea name="requirement_name" maxlength="140" rows="3" cols="70">#get_item.qualification_name#</textarea>
                  <input type="hidden" name="program_qualification_id" value="#get_item.program_qualification_id#">
                </td>
              </tr>
			<!--- Tim Ford - 01/13/2015: WR 47770 - QUALIFICATIONS -- WHEN EDIT/CREATE OPTION TO SAVE VALUE IN OPERATOR MASTER FIELDS
			If operator type is selected then the value selected from the program qualifications page will get stored in the Operator_Type column in BSA_Operator --->
			<tr>
				<td><b>Operator Type:</b></td>
				<td>
					<input name="Store_Operator_Type" type="checkbox" value="1" <cfif get_item.Store_Operator_Type eq 1>checked</cfif> />
				</td>
			</tr>
	
              <tr>
                <td><b>Type:</b></td>
                <td>
                    <!---<select name="type" onchange="displayoptions(this.value)">--->
                    <select name="type">
                      <option value="0">Select a type</option>
                      <option value="1" <cfif get_item.type EQ 1>SELECTED</cfif>>Text</option>
                      <option value="2" <cfif get_item.type EQ 2>SELECTED</cfif>>Options</option>
                    </select>
                </td>
              </tr>

              <!--- OPTIONS --->
              <cfif get_item.recordcount EQ 0  OR (get_item.recordcount GT 0 AND get_item.type EQ 1)>
                <tr id="options" style="display:none;">
                  <td><b>Option 1</b></td>
                  <td><input type="textbox"  name= "option1" id='textbox1' value="" >
                      <input type="hidden" name="totaloptions" value="1">
                      <input type='button' value='Add Options' id='buttonadd' onclick='addtext();'>
                  </td>
                </tr>
              </cfif>

              <tr id="storedoptions">
                <td colspan="2">
                <cfif get_item.recordcount GT 0 AND get_item.type EQ 2>
                  <cfset optionslist = #trim(get_item.value)#>

                  <table>
                          <cfloop from="1" to="#listlen(optionslist)#" index="i">
                                <tr>
                                  <td><b>Option #i#</b></td>
                                  <td>
                                    <input type="textbox"  name= "option#i#" value="#listgetat(optionslist, i)#">
                                  </td>
                                </tr>
                          </cfloop>
                          <cfif i LT 50>
                                <tr>
                                  <td><b>Option #i#</b></td>
                                  <td><input type="textbox"  name= "option#i#" id='textbox1' value=""><input type='button' value='Add Options' onclick='addtext();'></td>
                                </tr>
                          <cfelse>
                            <cfset i = i -1>
                          </cfif>
                  </table>
                  <input type="hidden" name="totaloptions" value="#i#">

                </cfif>
                </td>
              </tr>

              <tr>
                <td colspan="2"><div id="buttondiv">  <!-- this is where options will appear --> </div> </td>
              </tr>

              <tr>
                <td><b>Availability:</b></td>
                <td>
                  <cfif get_item.isactive eq 1 or get_item.isactive eq "" >
                    <cfset active=" checked">
                    <cfset inactive="">
                  <cfelse>
                    <cfset active="">
                    <cfset inactive=" checked">
                  </cfif>

                  <input type="radio" value="1" name="active"#active#>active&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" value="0" name="active"#inactive#>inactive

                </td>
              </tr>
              <input type="hidden" name="deleterecord" value="0">
              <tr>

                <td>
                          <cf_button
                            button_name = ""
                            button_caption  = "save data"
                            button_action = "return SubmitForm();"
                            button_type = "javascript_link"
                            button_width  = "75"
                            button_color  = "navy"
                            button_tip  = ""
                            font_color  = "white"
                            font_size   = "12"
                            font_weight = "bold"
                          >
                </td>
                <td>
                    <cfif get_item.recordcount>
                          <cf_button
                            button_name = ""
                            button_caption  = "delete"
                            button_action = "return deactivate();"
                            button_type = "javascript_link"
                            button_width  = "75"
                            button_color  = "navy"
                            button_tip  = ""
                            font_color  = "white"
                            font_size   = "12"
                            font_weight = "bold"
                          >
                    </cfif>
                  </td>
                </td>
              </tr>
            </table>
            </cfoutput>
      <input type="hidden" name="blnsubmit" value="1">
      </form>
    </td>
  </tr>
</table>
<b>
<font color="#ff0000" size="2"><b>[</b></font>
  <a href="program_qualifications.cfm"><b>create new entry</b></a>
<font color="#ff0000" size="2"><b>]</b></font>
</b>

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript">
 function addtext(){
         var counter = document.MyForm.totaloptions.value;
             if (counter < 50)
             {
                 counter++;
                 $('#buttondiv').append('<div style="margin-bottom:5px;"><label><b>Option '+counter+'</b></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="option'+counter+'" class="textbox" value="" /></div>');
                document.MyForm.totaloptions.value = counter;
       }else{
                 alert('You cannot add more than 50 options');
             }
     }


function displayoptions(id){
    if(id == 2){
<cfif get_item.recordcount GT 0 AND get_item.type EQ 2>
      document.getElementById('storedoptions').style.display = 'block';
<cfelse>
      document.getElementById('options').style.display = 'block';
</cfif>
    }
    else{
<cfif get_item.recordcount GT 0 AND get_item.type EQ 2>
      document.getElementById('storedoptions').style.display = 'none';
<cfelse>
      document.getElementById('options').style.display = 'none';
</cfif>
    }
  }

function SubmitForm()
        {
          var isError = 0;
          var re = /\s/g;
          var msg = '';
          var strRequirement_Name = document.MyForm.requirement_name.value.replace(re, "");
          if (strRequirement_Name.length == 0)
          {
            var msg = msg.concat("Please enter a description.\n");
            isError = 1;
          }
          if (document.MyForm.type.value == 0)
          {
            var msg = msg.concat("Please select a type.\n");
            isError = 1;
          }
          if (document.MyForm.type.value == 2 && document.MyForm.option1.value.length ==0)
          {
            var msg = msg.concat("options cannot be empty.\n");
            isError = 1;
          }
          if (isError == 0)
          {
            MyForm.submit();
          }
          else{
            alert(msg);
          }
          return false;
  }

function deactivate(){
var remove = confirm("Do you want to delete this qualification?")
if (remove == true) {
  document.MyForm.deleterecord.value = 1;
  MyForm.submit();
  }
  return false;
}

$("select[name=type]").change(function() {
  if ($(this).val() == 1) {
    $('#storedoptions, #options').hide();
    $('#txt119').show();
  }
  else {
    $('#txt119').hide();
    $('#storedoptions, #options').show();
  }
});
</script>
