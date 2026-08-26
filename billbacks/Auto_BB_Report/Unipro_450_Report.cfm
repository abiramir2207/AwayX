<cfparam name="url.ReportID" type="integer" default="0">
<cfparam name="FORM.BB_Auto_Report_id" default='#URL.ReportId#' type="integer">
<cfparam name="url.ReportLevel" type="integer" default="0">
<cfparam name="FORM.ReportLevel" default='#URL.ReportLevel#' type="integer">
<cfparam name="url.Billback_ID"  default="" type="String">
<cfparam name="FORM.Billback_ID" default='#URL.Billback_ID#' type="String">
<cfparam name="FORM.Supplier_Number" default="" type="String">

<html>
	<head>
	<title>Create Unipro 450 Report</title>
	<style type="text/css">
	.colHead {
		font-family: Arial, Helvetica, sans-serif;
		font-size: 12px;
		font-weight: bold;
		
	}
	.rowHead {
		font-family: Geneva, Arial, Helvetica, sans-serif;
		font-size: 12px;
		font-weight: bold;
		color: #000099;
		text-align: left;
		border-bottom-width: thin;
		border-bottom-style: solid;
		border-bottom-color: #990000;
		background-color: #ffce84;
	}
	 td {
		border-top-width: 1px;
		border-right-width: 1px;
		border-bottom-width: 1px;
		border-left-width: 1px;
		border-top-style: none;
		border-right-style: solid;
		border-bottom-style: solid;
		border-left-style: none;
	}
	table {
		border-top-width: 1px;
		border-right-width: 1px;
		border-bottom-width: 1px;
		border-left-width: 1px;
		border-top-style: solid;
		border-right-style: none;
		border-bottom-style: none;
		border-left-style: solid; 
	}
	
	.NoBorder {
		border-top-style: none;
		border-right-style: none;
		border-bottom-style: none;
		border-left-style: none;
	}
	.Grayed
		{
			color: 				gray;
			font-family:		Arial;
			font-size :			11px;
		}
	</style>
	</head>
	<body>

	<p>&nbsp</p>
	<cfoutput>
    <form name="frmCreateUniproReport" action="Unipro_450_Report.cfm" method="post" format="html">
        <input type="hidden" name="BB_Auto_Report_id" value="#FORM.BB_Auto_Report_id#">
        <input type="hidden" name="Billback_ID" value="#FORM.Billback_ID#">
        <input type="hidden" name="ReportLevel" value="#FORM.ReportLevel#">
            
        <table width="300" border="0" cellpadding="3" cellspacing="0">
            <tr>
                <td class="rowHead" colspan="2">
                    Enter Supplier Number information:
                </td>
            </tr>
            <tr>
                <td class="colHead">
                    Supplier Number
                </td>
                <td class="colHead">
                    <input type="text" name="Supplier_Number" size="35" maxlength="50" value="#Supplier_Number#">
                </td>
            </tr>
                
            <tr><td  class="colHead" colspan="2"><input type="button" name="Create" label="Create Unipro 450 Report" value="Create Unipro 450 Report" Onclick="createReport();" ></td></tr>
        </table>
    </form>
	</cfoutput>

    <cfinclude template="/common_files/jQuery.cfm">

	<script>	
        function trim(sStr) {
            return sStr.replace(/^\s*/ig, "").replace(/\s*$/ig, "");
        }
        
        function createReport() {
            var actionFrm = document.frmCreateUniproReport;
            if (trim(actionFrm.Supplier_Number.value) == "")
            {
                alert("Please provide a Supplier Number");
                return;
            }
            <cfoutput>generate_export( '/billbacks/Auto_BB_Report/Unipro_450_Report_Download.cfm'
                                        + '?BB_Auto_Report_id=#FORM.BB_Auto_Report_id#'
                                        + '&Supplier_Number=#FORM.Supplier_Number#'
                                        + '&ReportLevel=#FORM.ReportLevel#'
                                        + '&Billback_ID=#FORM.Billback_ID#'
                                        );</cfoutput>
            return false;
        }	
	</script>
</body>
</html>