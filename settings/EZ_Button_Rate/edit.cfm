<!DOCTYPE HTML>
<!---------------------------------------------------------------------------------------------------------------------
            Template: \settings\EZ_Button_Rate\edit.cfm
            Date:     13-Nov-2015
            Author:   Anand Rao
            Purpose:  Add/Edit EZ Button Rate Setting

            Parameter:

----------------------------------------------------------------------------------------------------------------------->
<html lang="en">
<head>
  <meta charset="utf-8" />
  <cfset jQueryUI.version = "1.8.23">
  <cfinclude template="/common_files/jQuery.cfm">
  <script type="text/javascript" src="/Script/javascript/jQueryUI_18/jquery.multiselect.min.js"></script>
  <cfmodule template="/customTags/include.cfm" file_to_include="/common_files/datatable.css, /common_files/select2.css, /styles/jQueryUI_18/jquery-ui-1.8.10.custom.css, /styles/jQueryUI_18/jquery.multiselect.css"/>
  <style>
    fieldset { margin:0 5px; padding: 7px; border: 1px solid blue; }
    legend { font: bold 14px sans-serif; color: red; }
    form, p { margin: 7px 0; }

    label { font-size: 1em; font-weight: bold; margin-right: 7px; }
    p { font-size: 1.0em; color: #006400; }

    #sortable { list-style-type: none; margin: 0 auto; padding: 0; }
    #sortable td { margin: 0 3px 3px 3px; padding-left: 1.1em; height: 24px; }
    #sortable tr span.ui-displayRow { position: absolute; margin-left: -1.2em; }
    #sortable th { text-align: left; padding-left: 0.5em; font-family: Verdana, sans-serif; }
    #sortable input[type=text] { padding-left: 3px;}

    select[name=templates] { width: 450px; }
    .actions { margin-top:10px }
  </style>
  <script language="javascript">
   function switchlayer(lyrid, title, titleclosed, borderwidth, imagea,imageb, colora,colorb) {
       if (document.all.length) {
        // determine if the layer is currently expanded or collapsed:
        var tmpstatus;
        eval("tmpstatus = document.all.lyrgroup_"+ lyrid +".style.display");
        // ok, then now expand or collapse it...
        if (tmpstatus == 'none') {
         eval("document.all.lyrgroup_"+ lyrid +".style.display='block';");
         eval("document.all.border_"+ lyrid +".style.borderwidth='"+borderwidth+"px';");
         eval("document.all.title_"+ lyrid +".innerhtml='"+title+"';");
         tmpimage = imagea;
         tmpcolor = colora;
        }
        else {
         eval("document.all.lyrgroup_"+ lyrid +".style.display='none'");
         eval("document.all.border_"+ lyrid +".style.borderwidth='0px';");
         eval("document.all.title_"+ lyrid +".innerhtml='"+titleclosed+"';");
         tmpimage = imageb;
         tmpcolor = colorb;
        }
        // if an image is used as the click-control, switch it...
        if ((tmpimage != null) && (imagea != imageb)) {
         eval("document.all.image_"+ lyrid +".src='"+tmpimage+"'");
        }
        // if different title-colors are used, switch them...
        if (tmpcolor != '') {
         eval("document.all.title_"+ lyrid +".style.color='"+tmpcolor+"'");
        }
       }
      }

    function toggleTemplate()
    {
        var actionFrm = document.editEZButtonRate;
        if (actionFrm.templateExpanded.value == "1")
        {
            actionFrm.templateExpanded.value = 0;
        }
        else
        {
            actionFrm.templateExpanded.value = 1;
        }

    }

    function sortByThisItem(thisObj, thisSortItem, thisSortOrder)
    {
        isSearching = 1;
        var formObj;
        formObj = document.all.DataForm;
        formObj.sort_by.value = thisSortItem;
        formObj.New_Sort_Order.value = thisSortOrder;
        if (thisSortItem == "TYPE")
        {
            formObj.pageAction2.value = "";
            formObj.TypeRefresh.value = '1';
        //alert(formObj.pageAction2.value)
        }
        formObj.submit();
        return false;
    }

function selectAllLike(thisObj, objToChk)
{
    //var chObjs = eval("document.all." + objToChk);
    var bCheck = thisObj.checked;
    var i;
    for (i=0;i<document.editEZButtonRate.elements.length;i++)
    {
        if ( document.editEZButtonRate.elements[i].name != undefined ||  document.editEZButtonRate.elements[i].name != null)
        {
            if (document.editEZButtonRate.elements[i].name != "undefined" || document.editEZButtonRate.elements[i].name != "")
            {
                if ((document.editEZButtonRate.elements[i].name).indexOf(objToChk,0) != -1)
                {
                     document.editEZButtonRate.elements[i].checked = bCheck;
                }
            }
        }
    }
}
  </script>
</head>
<cfparam name="FORM.EZ_Button_Rate_ID" default="-1">
<cfparam name="FORM.templateExpanded" default="0" />
<cfparam name="FORM.TmpltSearchKeyword" default="">
<cfparam name="FORM.New_Sort_Order" default="DESC" />
<cfparam name="FORM.sort_by" default="DESC" />
<cfparam name="FORM.templateExpanded" default="0" />
<cfparam name="chkboxIncludeChecked" default="0" />
<!--- <cfset ASC_IMG="/images/down_1.gif">
<cfset DESC_IMG="/images/up_1.gif"> --->

<cfif isDefined("FORM.New_Sort_Order") AND FORM.New_Sort_Order EQ "ASC">
      <cfset New_Sort_Order="DESC">
        <cfset sortImage="down_1.gif">
<cfelse>
        <cfset New_Sort_Order="ASC">
        <cfset sortImage="up_1.gif">
</cfif>

<cfif FORM.tmpltSearchKeyword NEQ "">
    <cfset vSearchKeyword = FORM.tmpltSearchKeyword />
<cfelse>
    <cfset vSearchKeyword = "" />
</cfif>
<!--------------------------------------------------------------------------------------------------------------------->

<body>
<fieldset>
<legend><cfif url.EZ_Button_Rate_ID eq "-1" AND FORM.EZ_Button_Rate_ID EQ "-1">
                    Create New
                    <cfset pageAction = "create" />
                    <cfelseif (isDefined("URL.actType") AND URL.actType EQ "edit")>
                    Edit
                    <cfset pageAction = "edit" />
                    <cfelseif (isDefined("URL.actType") AND URL.actType EQ "copy")>
                    Copy
                    <cfset pageAction = "copy" />
                    </cfif>
                    EZ Button Rates Setting</legend>
<cfoutput>
<cfset NewEZButtonRateID = url.EZ_Button_Rate_ID />
<cfif pageAction eq "create">
    <cfquery name="local.query" datasource="#application.datasource#">
        INSERT INTO [EZ_Button_Rate_Setting]
            (Created_Date, Created_By )
        VALUES
            ( getDate()
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#"> )

            SELECT SCOPE_IDENTITY() AS EZ_Button_Rate_ID
    </cfquery>
    <cfset NewEZButtonRateID = local.query.EZ_Button_Rate_ID />

    <cfset useLakebaseForEzTemplateExists = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForEzTemplateExists>
	<cftry>
		<cfset EzTemplateExists = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"program_description" = "eq.EZ Button Rate Template",
				"isdominant" = "eq.0",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForEzTemplateExists = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForEzTemplateExists>
<cfquery name="EzTemplateExists" datasource="#application.datasource#">
        SELECT
            *
        FROM
            Program_Control_Panel_Options
        WHERE
            Program_Control_Panel_Options.Program_Description = 'EZ Button Rate Template'
            AND Program_Control_Panel_Options.IsDominant = 0
            AND Program_Control_Panel_Options.Deleted = 0
    </cfquery>
</cfif>

    <cfif (EzTemplateExists.RecordCount EQ 0)>
        <!--- EZ Button Rate Template does not exist, Insert a new row in the table. --->
        <cfquery name="EzTemplateExists" datasource="#application.datasource#">
            INSERT INTO Program_Control_Panel_Options
            (
                Company_Main_ID,
                Generic_Type,
                Created_Type,
                Program_Description,
                RateTypeOption_1,
                RateTypeOption_2,
                Groups_UOM_Default,
                Groups_UOM_1,
                Groups_UOM_2,
                IsDominant,
                Discount_Rebates_Group_Level,
                Discount_Rebates_Item_Level,
                Group_Deal,
				Discount_Rebates
            )
            VALUES
            (
                '#request.AccessStructure.Company_Main_ID#',
                'Operator-Deviated Pricing',
                'Operator OI',
                'EZ Button Rate Template',
                1,
                1,
                1,
                1,
                1,
                0,
                1,
                1,
                1,
                1
            )

            SELECT SCOPE_IDENTITY() AS ProgramControl_Panel_Options_ID

        </cfquery>
    </cfif>

    <cfinclude template="/common_files/contracts/contract_number_generator.cfm">

    <cfquery name="CreateEZButtonProgram" datasource="#application.datasource#">
        SET NOCOUNT ON
        DECLARE  @EZContractID INT

        UPDATE Program_Control_Panel_Options SET  First_Parent_ID = <cfqueryparam value="#EzTemplateExists.ProgramControl_Panel_Options_ID#" cfsqltype="cf_sql_integer">
        WHERE ProgramControl_Panel_Options_ID = <cfqueryparam value="#EzTemplateExists.ProgramControl_Panel_Options_ID#" cfsqltype="cf_sql_integer">

        INSERT INTO Contract_Main
        (
            Contract_Number,
            ProgramType,
            ProgramType_ID,
            Contract_Start_Date,
            Contract_End_Date,
            contract_EZButton_On,
            Deleted
        )
        VALUES
        (
            <cfqueryparam value="TMP_#generator_contract_number#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="EZ Button Program" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#EzTemplateExists.ProgramControl_Panel_Options_ID#" cfsqltype="cf_sql_integer">,
            CAST(CONVERT(CHAR(10), GETDATE(), 101) as datetime),
            CAST(CONVERT(CHAR(10), GETDATE(), 101) as datetime),
            1,
            1
        )



        /*
        update Program_Control_Panel_Options
        set EZ_Contract_Id = (SELECT MAX(Contract_Main_ID) AS Contract_Main_ID FROM Contract_Main)
        where ProgramControl_Panel_Options_ID = 0

        SET NOCOUNT O
        */

        SELECT * FROM Contract_Main where contract_number = 'TMP_#generator_contract_number#'
        SELECT @EZContractID = SCOPE_IDENTITY()
        UPDATE [EZ_Button_Rate_Setting] SET EZ_Contract_Id = @EZContractID  WHERE EZ_Button_Rate_ID = #NewEZButtonRateID#
        INSERT INTO Program_Rebates_Component(Program_ID, Program_Rebates_Component_Name_ID, Component_Paid_To, Claim_Mechanics, GL_Account_ID)
        VALUES (@EZContractID, 0, 0, -1, 0)
      </cfquery>
      <cfset contractMainID = CreateEZButtonProgram.Contract_main_ID />
</cfif>
</cfoutput>
    <cfset useLakebaseForqGetDiscountType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("discount_type")>
<cfif useLakebaseForqGetDiscountType>
	<cftry>
		<cfset qGetDiscountType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("discount_type", {
				"discount_type_id" = "eq.2",
				"select" = "discount_type_id,discount_type_desc"
			}), "discount_type_id,discount_type_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDiscountType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDiscountType>
<cfquery name="qGetDiscountType" datasource="#application.datasource#">
        SELECT
            Discount_Type_ID, Discount_Type_Desc
        FROM
            Discount_Type WHERE Discount_Type_ID = 2
    </cfquery>
</cfif>

<cfif cgi.request_method eq "post">
    <cfset saveSettings()>
    <cflocation url="list.cfm" addtoken="false">
</cfif>

<cfscript>
    vars = {};
    vars.EZButtonRateCFC = createObject("component", "components.programs.EZButton_ProgramManager");
    vars.ezButtonRateSetting = vars.EZButtonRateCFC.getEZButtonRates( NewEZButtonRateID );
</cfscript>

<cfif pageAction EQ "create"> <!--- EDIT Part --->
    <cfset qryTemplateList = vars.EZButtonRateCFC.getEZTemplates(pageAction="create")>
</cfif>

<cfif pageAction EQ "edit"> <!--- EDIT Part --->
       <cfset contractMainID = vars.ezButtonRateSetting.EZ_Contract_ID />
       <cfset qryTemplateList = vars.EZButtonRateCFC.getEZTemplates()>
</cfif>

<cfif pageAction EQ "copy">
<cfset copiedEZButtonRateID = URL.EZ_Button_Rate_ID />
    <cfoutput>
        <cfscript>
            vars = {};
            vars.EZButtonRateCFC = createObject("component", "components.programs.EZButton_ProgramManager");
            vars.CopyCreatedID = vars.EZButtonRateCFC.copyEZButtonRate( copiedEZButtonRateID );
            NewEZButtonRateID = vars.CopyCreatedID;
            vars.ezButtonRateSetting = vars.EZButtonRateCFC.getEZButtonRates( vars.CopyCreatedID );
            contractMainID = vars.ezButtonRateSetting.EZ_Contract_ID;
            qryTemplateList = vars.EZButtonRateCFC.getEZTemplates();
        </cfscript>
    </cfoutput>
</cfif>


<form name="editEZButtonRate" method="post">
<cfoutput>
<input name="EZ_Button_Rate_ID" type="hidden" value="#NewEZButtonRateID#">
<input name="pageAction" type="hidden" value="#pageAction#">

<table style='table-layout:fixed;width:100%;'>
<tr>
    <td>
        <label for="EZ_Button_Rate_Title">EZ Button Rate Title:</label><br>
        <input name="EZ_Button_Rate_Title" type="text" size="50" <cfif URL.EZ_Button_Rate_ID neq "-1" AND pageAction EQ "edit">value="#vars.ezButtonRateSetting.EZ_Button_Rate_Title#" <cfelseif URL.EZ_Button_Rate_ID neq "-1" AND pageAction EQ "copy">value="#vars.ezButtonRateSetting.EZ_Button_Rate_Title#"</cfif>>
    </td>
</tr>
<tr>
    <td>
        <label for="EZ_Button_Rates">Add the product and Rate by clicking on the link below:</label><br>

        <CF_CRYP type="en" string="#contractMainID#" key="#request.key#" return="Enc">
        <CFSET EncryptedCID = Enc.value>
        <cfset filepath = "/Common_Files/contracts/EZ_Button_Template_Rates.cfm?EZ_Button_Rate_ID=#NewEZButtonRateID#&CID=#EncryptedCID#">
            <!---
            <cfset filepath = "/Common_Files/contracts/Contract_Discount_Rebates.cfm?EZ_Button_Rate_ID=#NewEZButtonRateID#&CID=#EncryptedCID#">
            --->
        <a onClick="javaScript: NewWindow(this.href , 'EZ_Button_Settings' , '830' , '650' , 'no' , 'no'); return false;" href="#filepath#&EZTemplate=1" target="_blank">
            <strong>#qGetDiscountType.Discount_Type_Desc#</strong>
        </a>
    </td>
</tr>
</table>
</cfoutput>

    <!--- TEMPLATE SECTION STARTS --->
<cfscript>
    genericTypes = [ 'Distributor Trade/Shelter' ];
    labels = {};
    labels.select_generic_type = 'Select Generic Type';
    templateManager = CreateObject("component", "components.programs.template.TemplateManager").init();
    Lock_Release = templateManager.ReleaseLocks(request.AccessStructure.User_ID);
    appSettings = application.appSettingsGet;

    if ( appSettings.getDisplayProposal() )
        arrayAppend(genericTypes, 'Bid Request');

    if ( application.appSettingsGet.getBrokerage_Functionality_On() )
        arrayAppend(genericTypes, 'Brokerage');

    if ( application.appSettingsGet.getdirectpricingon() )
        arrayAppend(genericTypes, 'Direct Pricing');

    if ( appSettings.getDisplayDistributorOffInvoice() )
        arrayAppend(genericTypes, 'Distributor Off-Invoice');

    arrayAppend(genericTypes, 'Field Execution');
    arrayAppend(genericTypes, 'LSAutoPay');
    arrayAppend(genericTypes, 'Operator Direct or HQ Programs');
    arrayAppend(genericTypes, 'Operator-Deviated Pricing');

    if ( appSettings.getDisplayUSDANOI() )
        arrayAppend(genericTypes, 'USDA NOI');
</cfscript>
<cfoutput>
 <fieldset id="border_4" style="border-width:0; border-color:; border-style:solid; width:760">
     <legend>
      <span>
        <img id="image_4" src="/images/plus2.gif" onclick="switchlayer(4,'Hide Templates','Show Templates',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy');toggleTemplate();" border="0" title="" style="cursor:pointer">
       <font face="Arial">
        <b style="font-size:9pt">
         <span id="title_4" onclick="switchlayer(4,'Hide Templates','Show Templates',0,'/images/minus2.gif','/images/plus2.gif','Navy','Navy');toggleTemplate();" style="color:00773c;cursor:pointer">
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

    <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
    <table class="datagrid" id="datagrid">
        <thead>
            <tr>
                <th class="columnfilter" align="left">
                    <select id="generictypefilter"><option value=''>Filter On Generic Type</option><cfloop array="#genericTypes#" index="genericType"><option>#genericType#</option></cfloop></select>
                    <br><INPUT Name="allboxInclude"  id="allboxInclude" TYPE="Checkbox" onClick="selectAllLike(this,'chkBoxInclude_')" TITLE="Click here to select all Templates">&nbsp;Template Name
                </th>
                <th>&nbsp;</th>
                <th>&nbsp;</th>
                <th>&nbsp;</th>
            </tr>
        </thead>
    <tbody>
        <cfset i = 1>
        <cfset tdcount = 0>
        <cfloop query="qryTemplateList">
			<cfif (i EQ 1) OR ((i-1) MOD 4) EQ 0>
				<tr>
			</cfif>
			<cfset tdcount = tdcount+1>
			<td>
				<span style="display:none;">(#genericType#)</span><!---THIS IS NEED TO FILTER BASED ON GENERIC TYPE --->
				<input type="Checkbox"
							name="chkBoxInclude_#qryTemplateList.First_Parent_ID#_"
							ID="chkBoxInclude_#qryTemplateList.First_Parent_ID#_"
							value="#qryTemplateList.First_Parent_ID#"
					   		<cfif EZ_Button_Rate_ID EQ NewEZButtonRateID>checked</cfif> />&nbsp;&nbsp;#Created_Type#
			</td>
            <!--- THIS BLOCK CODE IS ADDED TO SEE IF WE HAVE ALL TD'S AND CLOSING TR'S IF NOT IT WILL ADD EMPTY TD'S AND CLOSING TR SO JQUERY WONT THROW ERROR --->
                <cfif (i eq qryTemplateList.recordcount)>
                    <cfset cspan = 4 - tdcount>
                    <cfloop from="1" to="#cspan#" index="tdc" >
                        <td>&nbsp;</td>
                    </cfloop>
                    <cfset i = 4>
                </cfif>

            <cfif (i MOD 4) EQ 0>
                <cfset tdcount = 0>
                </tr>
            </cfif>
        <cfset i = i+1>
        </cfloop>
    </tbody>
</table>
</cfoutput>

<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables2.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.highlight.js"/>
<script>
var oTable = $('table#datagrid').DataTable({
     "bAutoWidth": false
    ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'ft'
    ,'searchHighlight': true
    ,"aoColumns": [
                                 {"sWidth": "24%", "bSortable":false, "bSearchable":true }
                                ,{"sWidth": "24%", "bSortable":false, "bSearchable":true }
                                ,{"sWidth": "24%", "bSortable":false, "bSearchable":true }
                                ,{"sWidth": "24%", "bSortable":false, "bSearchable":true }
                            ]
  });
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

$("thead th").each( function ( i ) {
    if ( $(this).hasClass("columnfilter") ) {
      // build select tag dynamically if "addselect" class is found
          if ( $(this).hasClass("addselect") ) {
                 $(this).html( $(this).html() + '<br/>' + fnCreateSelect( oTable.fnGetColumnData(i) ) );
          }
      $('select', this).change( function () {
          oTable.columns(i).search( this.value ).draw();
          if ( $(this).val() )
            $('#newgenerictype').val( $(this).val() );
          else
            $('#newgenerictype').val( <cfoutput>'#labels.select_generic_type#'</cfoutput> );
      } );
  }
} );
</script>
</div>

<!--- TEMPLATE SECTION ENDS  --->

<div class="actions">
    <cfoutput><a href="##" class="save" style="margin-right:30px;">#application.util.string.actionLinkFormat("save")#</a></cfoutput>
    <cfoutput><a href="##" class="cancel">#application.util.string.actionLinkFormat("cancel")#</a></cfoutput>
</div>
<cfoutput>
<input type="hidden" name="templateExpanded" value="#FORM.templateExpanded#">
</cfoutput>
</form>
</fieldset>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="saveSettings" output="false">
    <cfscript>
        vars = {};
        vars.EZButtonRateCFC = createObject("component", "components.programs.EZButton_ProgramManager");
        vars.EZButtonRateSettings = vars.EZButtonRateCFC.saveEZButtonRate( form );
    </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<script type="text/javascript" src="/script/javascript/select2.min.js"></script>
<script>
  $(function() {
   // $("##sortable tbody" ).sortable();
    $("select[name=templates]").multiselect({
             noneSelectedText: "Select program templates.."
            ,selectedText: "## program template(s) selected"
        });
    $(".cancel").on("click", function() { window.location.href="list.cfm"; });
    $(".save").on("click", function() {
        var errors = [];
        var name = $("input[name=EZ_Button_Rate_Title]").val();

    /*  if ( name == "" ) {
            errors.push( "You forgot to enter the setting name." );
        } */
        var EZ_Button_Rate_Title = $("input[name=EZ_Button_Rate_Title]");
        if ( EZ_Button_Rate_Title.attr('disabled') !== "disabled" && EZ_Button_Rate_Title.val() == "Default" ) {
            errors.push( "Default is a reserved name and it cannot be used." );
        }

        var duplicateExists = false;
        $.ajax({ url: "/components/programs/EZButton_ProgramManager.cfc"
                ,type: "post"
                ,timeout:60000
                ,data:  {   method: "duplicateExists"
                            ,EZ_Button_Rate_ID: $("input[name=EZ_Button_Rate_ID]").val()
                            ,EZ_Button_Rate_Title: $("input[name=EZ_Button_Rate_Title]").val()
                        }
                ,dataType: "json"
                ,async: false
                ,success: function(json) { duplicateExists = json.DUPLICATEEXISTS; }
        });
        if (duplicateExists) {
            errors.push("The selected name already exists, please select another Title");
        }

        if ( errors.length == 0 ) {
            var seq = 100;
            $(".seq").each(function() { seq = seq + 10;
                    /*assign sequence value based on position*/
                    $(this).val( seq );
            });
            $("form[name=editEZButtonRate]").submit();
        }
        else {
            alert( errors.join("\n") + "\n\nPlease make the corrections and try again." );
        }
    });

    $('##clause').select2( { width:"300", placeholder:"Choose..." } );
  });
</script>
</body>
</html>