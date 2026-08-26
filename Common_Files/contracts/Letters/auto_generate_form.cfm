<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Auto Generate Form</title>
<cfsilent>
<!--- 
FILE: 		/common_files/contracts/letters/auto_generate_form.cfm	
FILENAME: auto_generate_form.cfm
CREATED: 	03/31/2008 - RBL
EDITED:		08/14/2008 - RBL

FUNCTIONALITY:
- This form template allows the caller to submit all vars OR partial vars for one or more program IDs at a time and then - utilize the intelligent form to make final global changes prior to actually creating program deal letters.
--->

</cfsilent>
</head>
<body bgcolor="#ffffff" text="#000000" leftmargin="0" topmargin="0" rightmargin="0" bottommargin="0" marginwidth="0" marginheight="0">

  	<!--- These parameters are required for this template to process correctly --->

		<!--- TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
		TTTTTTTTTTTTTTTTT Let's set our initial timeout in seconds TTTTTTTTTTTTTTTTTTTT
		TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT --->
    <cfset variables.timeout_seconds = 3600>

<!--- Generate Letters [begin] --->
<cfoutput>

		<!--- we're gonna need a bigger boat... request timeout in seconds 3600=1hr wow!---->
		<cfsetting requesttimeout="#variables.timeout_seconds#">
    
    <cfparam name="form.bAddCustomerProductNumbers"	type="boolean" 	default="0">
    <!--- legend: 1=for auto generated letters via scheduled tasks, 0=manually by contract main id [bAuto] --->
    <cfparam name="form.bAuto" 											type="boolean" 	default="1">
    <!--- legend: 1=when using this exact form 0=when not --->
    <cfparam name="form.bFormSubmitted"							type="boolean" 	default="0">
    <cfparam name="form.bLetterDisplayFreight"				type="boolean" 	default="0">
    <cfparam name="form.bIncludeVolumePage"					type="boolean" 	default="0">
    <cfparam name="form.bInsertWatermark"						type="boolean" 	default="0">
    <cfparam name="form.contract_main_id" 					type="string" 	default="">
    <!--- legend: lb=pounds, cs=cases [customerFreightUom] --->
    <cfparam name="form.customerFreightUom"					type="string"		default="lb">
    <!--- legend: 1=one distributor per distributor letter, 2=multiple distributors per distributor letter [distributor_letter_type] --->
    <cfparam name="form.distributor_letter_type"		type="numeric"	default="2">
    <!--- legend: 1=one operator per distributor letter, 2=all operators per distributor letter [dis_letter_settings] --->
    <cfparam name="form.dis_letter_settings"				type="numeric"	default="2">
    <!--- legend: 1=operator, 2=distributor, 3=both [letter_type] --->
    <cfparam name="form.letter_type"								type="numeric"	default="3">
    <!--- legend: 2=generate letters WITHOUT email notification [notification_type] (NOTE: notification_type MUST always be 2 here) --->
    <cfparam name="form.notification_type"					type="numeric"	default="2">
    <!--- legend: 1=one operator per operator letter, 2=multiple operators per operator letter [operator_letter_type] --->
    <cfparam name="form.operator_letter_type"				type="numeric"	default="2">
    <!--- legend: 1=one distributor per operator letter, 2=all distributors per operator letter [opr_letter_settings] --->
    <cfparam name="form.opr_letter_settings"				type="numeric"	default="2">
    <!--- legend: default setting for timeout in seconds for the custom tag - this affects each iteration of the ct (module) but we really care about the caller --->
    <cfparam name="form.timeout_seconds"						type="numeric"	default="#variables.timeout_seconds#">
		<!--- legend: returning confirmation of ALL letters running if employed in the caller... --->
    <cfparam name="url.lettersGenerated"						type="boolean" 	default="0">
    <!--- legend: we identify our contract_main_id list's last id BELOW... --->
    <cfparam name="variables.bListLast"							type="boolean"	default="0">

    <!--- legend: user_id required for full functionality. A valid user ID MUST be passed in... [begin] --->
    <cfparam name="form.user_id"						type="string"	default="">
    <!--- IF we did NOT Explicitly pass a user_id... --->
    <cfif NOT len(trim(form.user_id))>
		<!--- do we have a human... --->
        <cfif isDefined("request") AND isStruct(request) AND structKeyExists(request,"accessStructure") AND isStruct(request.accessStructure) AND structKeyExists(request.accessStructure,"User_ID") AND len(trim(request.accessStructure.User_ID))>
            <cfset form.user_id = trim(request.accessStructure.User_ID)>
        </cfif>
    </cfif>
    <!--- legend: user_id required for full functionality. A valid user ID MUST be passed in... [end] --->
    
    <!--- legend: first name... [begin] --->
    <cfparam name="form.first_name"						type="string"	default="">
	<!--- do we have a human... --->
    <cfif isDefined("request") AND isStruct(request) AND structKeyExists(request,"accessStructure") AND isStruct(request.accessStructure) AND structKeyExists(request.accessStructure,"Name_First") AND len(trim(request.accessStructure.Name_First))>
        <cfset form.first_name = trim(request.accessStructure.Name_First)>
    </cfif>
    <!--- legend: first name... [end] --->
    
    <!--- legend: last name... [begin] --->
    <cfparam name="form.last_name"						type="string"	default="">
	<!--- do we have a human... --->
    <cfif isDefined("request") AND isStruct(request) AND structKeyExists(request,"accessStructure") AND isStruct(request.accessStructure) AND structKeyExists(request.accessStructure,"Name_Last") AND len(trim(request.accessStructure.Name_Last))>
        <cfset form.last_name = trim(request.accessStructure.Name_Last)>
    </cfif>
    <!--- legend: first name... [end] ---> 

<cfif form.bFormSubmitted>

	<!--- TESTING --->
	<cftimer label="Elapsed Time To Create #listLen(form.contract_main_id)# Letters" type="debug">

    <cfloop list="#form.contract_main_id#" delimiters="," index="variables.current_contract_main_id">
    
        <!--- legend: we identify our contract_main_id list's last id HERE... --->
        <cfif listLen(form.contract_main_id,',') EQ listFind(form.contract_main_id,variables.current_contract_main_id,',')>
          <cfset variables.bListLast = 1>
        </cfif>
    
        <!--- THINKING ABOUT THIS - decided to leave out at the moment 4/1. Settings in CFAdmin concerns. There is merit here,
        to thoroughly investigate the use of this in the future. RBL
        <cfthread name="letters_#variables.current_contract_main_id#" action="run" priority="low" timeout="1000"> --->
    
          <cfmodule
            template="/common_files/contracts/letters/auto_generate_gateway.cfm"
            bAddCustomerProductNumbers="#form.bAddCustomerProductNumbers#"
            bAuto="#form.bAuto#"
            bFormSubmitted="#form.bFormSubmitted#"
            bLetterDisplayFreight="#form.bLetterDisplayFreight#"
            bIncludeVolumePage="#form.bIncludeVolumePage#"
            bInsertWatermark="#form.bInsertWatermark#"
            bListLast="#variables.bListLast#"
            contract_main_id="#trim(variables.current_contract_main_id)#"
            customerFreightUom="#form.customerFreightUom#"
            distributor_letter_type="#form.distributor_letter_type#"
            dis_letter_settings="#form.dis_letter_settings#"
            letter_type="#form.letter_type#"
            notification_type="#form.notification_type#"
            operator_letter_type="#form.operator_letter_type#"
            opr_letter_settings="#form.opr_letter_settings#"
            timeout_seconds="#trim(form.timeout_seconds)#"
            user_id = "#trim(form.user_id)#" />

        <!--- THINKING ABOUT THIS </cfthread> --->
      
    </cfloop>

	</cftimer>

<cfelse>

  <cfsavecontent variable="requireInfo">
    if(contract_main_id.text == '' || user_id.text == '')
    {
      generateLetters.enabled = false;
    }
    else
    {
      generateLetters.enabled = true;
    }
  </cfsavecontent>
  
  <cfset form.formHeight 	= 320>
  <cfset form.formWidth 	= 600>
  
  <table name="outerTable" width="100%" height="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="##000000">
    <tr>
      <td align="center" valign="middle">
        <table name="innerTable" height="#evaluate(form.formHeight+20)#" width="#form.formWidth#" cellpadding="0" cellspacing="0" bgcolor="##ffffff">
          <tr>
            <td height="20" width="#form.formWidth#" align="center" valign="top">
              <cfif url.lettersGenerated><font size="1" color="red">Program Letters - Automatic Generation Successful!</font><cfelse>&nbsp;</cfif>
            </td>
          </tr>
          <tr>  
            <td height="#form.formHeight#" width="#form.formWidth#">
              <cfform action="#cgi.script_name#" method="post" name="letterGenerationForm" format="flash" skin="haloorange" height="#form.formHeight#" width="#form.formWidth#">
                <cfformgroup type="panel" label="Generate Program Letters Interface" tooltip="Generate Program Letters Interface" height="#evaluate(form.formHeight-20)#" width="#evaluate(form.formWidth-20)#">
                  <cfinput type="hidden" name="bAuto" 					value="#form.bAuto#">
                  <cfinput type="hidden" name="bFormSubmitted" 	value="1">
                  <cfformitem type="script">
                    public function hideShow() {
                      if(letter_type.selectedItem.data == 1)
                      {
                        distributor_letter_type.enabled = false;
                        dis_letter_settings.enabled = false; 
                        operator_letter_type.enabled = true;
                        opr_letter_settings.enabled = true;
                        
                        //if (opr_letter_settings.selectedItem.data == 1)
                        //{
                          //bAddCustomerProductNumbers.enabled = true;
                        //}
                        //else
                        //{
                        
                          bAddCustomerProductNumbers.enabled = false;
                          
                        //} 
                      }
                      else if (letter_type.selectedItem.data == 2)
                      {
                        distributor_letter_type.enabled = true;
                        dis_letter_settings.enabled = true; 
                        operator_letter_type.enabled =false;
                        opr_letter_settings.enabled = false;
  
                        if (distributor_letter_type.selectedItem.data == 1)
                        {
                          bAddCustomerProductNumbers.enabled = true;
                        }
                        else
                        {
                          bAddCustomerProductNumbers.enabled = false;
                        }
                      }
                      else if (letter_type.selectedItem.data == 3)
                      {
                        distributor_letter_type.enabled = true;
                        dis_letter_settings.enabled = true; 
                        operator_letter_type.enabled =true;
                        opr_letter_settings.enabled = true;
                        
                        //opr_letter_settings.selectedItem.data == 1 && 
                        if (distributor_letter_type.selectedItem.data == 1)
                        {
                          bAddCustomerProductNumbers.enabled = true;
                        }
                        else
                        {
                          bAddCustomerProductNumbers.enabled = false;
                        }
                      }
                      
                      if(bLetterDisplayFreight.selectedItem.data == 1)
                      {
                        customerFreightUom.enabled = true; 
                      }
                      else
                      {
                        customerFreightUom.enabled = false; 
                      }
                    }
                    
                  </cfformitem>
                  <cfformgroup type="tabnavigator">
                    <cfformgroup type="page" label="General Info">
                      <cfinput type="text" name="contract_main_id" label="Contract Main ID" width="200" required="yes" validateat="onsubmit" validate="noblanks" message="Please enter one or more valid Contract Main ID's (separate with commas)" onChange="#requireInfo#" value="#form.contract_main_id#">
                      <cfselect name="bAddCustomerProductNumbers" label="Add Customer Product Numbers?" width="200" enabled="false">
                        <option value="0" <cfif NOT form.bAddCustomerProductNumbers>selected</cfif>>No</option>
                        <option value="1" <cfif form.bAddCustomerProductNumbers>selected</cfif>>Yes</option>
                      </cfselect>
                      <cfselect name="bLetterDisplayFreight" label="Include Freight Page Summary?" width="200" onChange="hideShow()">
                        <option value="0" <cfif NOT form.bLetterDisplayFreight>selected</cfif>>No</option>
                        <option value="1" <cfif form.bLetterDisplayFreight>selected</cfif>>Yes</option>
                      </cfselect>
                      <cfselect name="customerFreightUom" label="Freight UOM?" width="200" enabled="false">
                        <option value="cs" <cfif form.customerFreightUom EQ 'cs'>selected</cfif>>Cs</option>
                        <option value="lb" <cfif form.customerFreightUom EQ 'lb'>selected</cfif>>Lb</option>
                      </cfselect>
                      <cfselect name="bIncludeVolumePage" label="Include Volume Page Summary?" width="200">
                        <option value="0" <cfif NOT form.bIncludeVolumePage>selected</cfif>>No</option>
                        <option value="1" <cfif form.bIncludeVolumePage>selected</cfif>>Yes</option>
                      </cfselect>
                      <cfselect name="bInsertWatermark" label="Insert Watermark?" width="200">
                        <option value="0" <cfif NOT form.bInsertWatermark>selected</cfif>>No</option>
                        <option value="1" <cfif form.bInsertWatermark>selected</cfif>>Yes</option>
                      </cfselect>
                      <cfformgroup type="horizontal" label="Generate Letters">
                        <cfinput type="reset" name="reset" value="Reset Form" width="150">
                        <cfinput type="submit" name="generateLetters" enabled="false" value="Generate Letters NOW" width="150" onClick="generateLetters.enabled=false">
                      </cfformgroup>
                    </cfformgroup>  
                    <cfformgroup type="page" label="Letter Type">
                      <cfformitem type="text">
                        Create Operator OR Distributor OR Both - Letters
                      </cfformitem>
                      <cfselect name="letter_type" label="Letter Type" width="200" onChange="hideShow()">
                        <option value="1" <cfif form.letter_type EQ '1'>selected</cfif>>Operator</option>
                        <option value="2" <cfif form.letter_type EQ '2'>selected</cfif>>Distributor</option>
                        <option value="3" <cfif form.letter_type EQ '3'>selected</cfif>>Both</option>
                      </cfselect>
                      <cfselect name="timeout_seconds" label="Timeout Seconds [120s/ltr avg]" width="200">
                      	<option value="1200" <cfif form.timeout_seconds EQ '1200'>selected</cfif>>1200 Seconds [10 letters] 20m</option>
                        <option value="2400" <cfif form.timeout_seconds EQ '2400'>selected</cfif>>2400 Seconds [20 letters] 40m</option>
                        <option value="3600" <cfif form.timeout_seconds EQ '3600'>selected</cfif>>3600 Seconds [30 letters] 1h</option>
                        <option value="4800" <cfif form.timeout_seconds EQ '4800'>selected</cfif>>4800 Seconds [40 letters] 1h20m</option>
                        <option value="6000" <cfif form.timeout_seconds EQ '6000'>selected</cfif>>6000 Seconds [50 letters] 1h40m</option>
                        <option value="7200" <cfif form.timeout_seconds EQ '7200'>selected</cfif>>7200 Seconds [60 letters] 2h</option>
                      </cfselect>
                      <!--- <cfinput type="text" name="user_id" label="User ID" width="200" required="yes" validateat="onsubmit" validate="noblanks" message="Please enter your valid User ID" onChange="#requireInfo#" value="#form.user_id#" style="font-size:8px;"> --->
                      <!--- notification_type MUST be 2 --->
                      <cfquery name="variables.qGetUserOptions" datasource="#application.datasource#">
                        SELECT *
                        FROM _Users
                        WHERE Deleted = 0
                        AND Profiles_ID IS NULL
                      </cfquery>
                      <cfselect name="user_id" label="User ID" width="200" required="yes" onChange="#requireInfo#" validateat="onsubmit" validate="noblanks" message="Please select a valid User ID">
                      		<option value="#form.user_id#">#form.first_name# #form.last_name#</option>
                      	<cfloop query="variables.qGetUserOptions">
                        	<option value="#variables.qGetUserOptions.User_ID#">#variables.qGetUserOptions.Name_First# #variables.qGetUserOptions.Name_Last#</option>
                        </cfloop>
                      </cfselect>
                      <cfinput name="notification_type" value="2" label="Generate Letters WITHOUT Email Notification" readonly="true" width="200"> 
                    </cfformgroup>
                    <cfformgroup type="page" label="OPERATOR Letters" enabled="{operator_letter_type.enabled}">
                      <cfselect name="operator_letter_type" label="Operator Letter Type - 1 OR Multiple Operators Each?" width="200">
                        <option value="1" <cfif form.operator_letter_type EQ '1'>selected</cfif>>One Operator Per Letter</option>
                        <option value="2" <cfif form.operator_letter_type EQ '2'>selected</cfif>>Multiple Operators Per Letter</option>
                      </cfselect>
                      <cfselect name="opr_letter_settings" label="Operator Letter Type - 1 OR All OR No Distributors Each?" width="200" onChange="hideShow()">
                        <option value="1" <cfif form.opr_letter_settings EQ '1'>selected</cfif>>One Distributor Per Letter</option>
                        <option value="2" <cfif form.opr_letter_settings EQ '2'>selected</cfif>>All Distributors Per Letter</option>
						<option value="3" <cfif form.opr_letter_settings EQ '3'>selected</cfif>>No Distributors Per Letter</option>
                      </cfselect>
                    </cfformgroup>
                     <cfformgroup type="page" label="DISTRIBUTOR Letters" enabled="{distributor_letter_type.enabled}">
                      <cfselect name="distributor_letter_type" label="Distributor Letter Type - 1 OR Multiple Distributors Each?" width="200" onChange="hideShow()">
                        <option value="1" <cfif form.distributor_letter_type EQ '1'>selected</cfif>>One Distributor Per Letter</option>
                        <option value="2" <cfif form.distributor_letter_type EQ '2'>selected</cfif>>Multiple Distributors Per Letter</option>
                      </cfselect>
                      <cfselect name="dis_letter_settings" label="Distributor Letter Type - 1 OR All Operators Each?" width="200">
                        <option value="1" <cfif form.dis_letter_settings EQ '1'>selected</cfif>>One Operator Per Letter</option>
                        <option value="2" <cfif form.dis_letter_settings EQ '2'>selected</cfif>>All Operators Per Letter</option>
                      </cfselect>
                    </cfformgroup>
                  </cfformgroup>
                </cfformgroup>
              </cfform>
            </td>
          </tr>
        </table>
      </td>  
    </tr>
  </table>
  
</cfif>  
  
</cfoutput>
<!--- Generate Letters [end] --->
</body>
</html>