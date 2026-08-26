<cfsetting requestTimeout = "#val(application.util.query.get_setting('program_change_history_timeout', 0))#">
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Program Change History</title>
</head>
<body>
    
<!---Gets application settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset labelnotes = appSettings.getLabelNotes()>
<cfset qGetChangeLog = CreateObject("component", "components.programs.program_history").init() />

<cfset paymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager").init() />
<cfset viewProgramManager = CreateObject("component", "components.programs.Display_Program.ViewProgramtemplateManager") />
<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>

<cfset ColorBackground = "FFCE84">

<!--- pull in time tracking functions --->
<cfinclude template="\developer\timeTracking.cfm">
<cfset timeBegin("program_change_history")>



<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~ Add entry for approved programs ~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cfset timeBegin("approved")>
<cfset qGetApprovedPrograms = qGetChangeLog.getApprovedPrograms() />
<cfloop query="qGetApprovedPrograms">
	<cfset qGetAgreedUsers = qGetChangeLog.getAgreedUsers(Contract_Main_ID) />
	<cfsavecontent variable="programApproveReportContent">
	<TABLE cellpadding="3" align="center" cellspacing="0" border="0" width="80%" class="ChangeLog">
	<cfoutput>
		<TR>
			<TD  valign="top" class="Heading" style="background-color:#ColorBackground#">Version</TD>
			<TD valign="top"  class="heading" style="background-color:#ColorBackground#">Created By</TD>
			<TD valign="top"  class="heading" style="background-color:#ColorBackground#">RFA By</TD>
			<cfif qGetAgreedUsers.Recordcount neq 0>
			<TD valign="top"  class="heading" style="background-color:#ColorBackground#">Agreed By</TD>
			</cfif>
			<TD valign="top"  class="heading" style="background-color:#ColorBackground#">Approved By</TD>
			<TD valign="top"  class="heading" style="background-color:#ColorBackground#">Contract Span</TD>
		</TR>
		
		<TR>
			<TD valign="top"><cfif len(revision_version) eq 4>#right("#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif>&nbsp;</TD>
			<TD valign="top">#Creator#&nbsp;(#DateFormat(Contract_Created_Date,"M/D/YYYY")# #TimeFormat(Contract_Created_Date, "short")#)&nbsp;</TD>
			<TD valign="top"><cfif RFA_User neq "">#RFA_User#&nbsp;(#DateFormat(Broker_Approved_Date,"M/D/YYYY")# #TimeFormat(Broker_Approved_Date, "short")#)</cfif>&nbsp;</TD>
			<cfif qGetAgreedUsers.Recordcount neq 0>
			<TD valign="top"><cfloop query="qGetAgreedUsers">#Name_First#&nbsp;#Name_Last#&nbsp;(#DateFormat(Agree_DateTime,"M/D/YYYY")# #TimeFormat(Agree_DateTime, "short")#)<br/></cfloop>&nbsp;</TD>
			</cfif>
			<TD valign="top"><cfif Approver neq "">#Approver#&nbsp;(#DateFormat(Approval_Date,"M/D/YYYY")# #TimeFormat(Approval_Date, "short")#)</cfif>&nbsp;</TD>
			<TD valign="top">#DateFormat(Contract_Start_Date,"MM/DD/YYYY")#-#DateFormat(Contract_End_Date,"M/D/YYYY")#&nbsp;</TD>
		</TR>
	</cfoutput>
	</TABLE>
	</cfsavecontent>
	<cfset qGetChangeLog.addProgramHistory(
			programId = Contract_Main_ID, 
			contractNumber = Contract_Number,
			content = programApproveReportContent,
			historyAction = 50,
			deletePreviousEntry = 1) />
</cfloop>
<cfset timeEnd("approved")>



<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~ Add entry for cancelled programs ~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cfset timeBegin("cancelled")>
<cfset qGetCancelledPrograms = qGetChangeLog.getCancelledPrograms() />
<cfloop query="qGetCancelledPrograms">
	<cfsavecontent variable="programCancelReportContent">
	<TABLE cellpadding="3" align="center" cellspacing="0" border="0" width="80%" class="ChangeLog">
	<cfoutput>
		<TR>
			<TD  valign="top" class="Heading" style="background-color:#ColorBackground#">Version</TD>
			<TD valign="top"  class="heading" style="background-color:#ColorBackground#">Cancelled By</TD>
			<TD valign="top"  class="heading" style="background-color:#ColorBackground#">Contract Span</TD>
		</TR>
		
		<TR>
			<TD valign="top"><cfif len(revision_version) eq 4>#right("#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif>&nbsp;</TD>
			<TD valign="top">#Cancelled_By_User#&nbsp;(#DateFormat(Cancelled_Date,"M/D/YYYY")# #TimeFormat(Cancelled_Date, "short")#)&nbsp;</TD>
			<TD valign="top">#DateFormat(Contract_Start_Date,"MM/DD/YYYY")#-#DateFormat(Contract_End_Date,"M/D/YYYY")#&nbsp;</TD>
		</TR>
	</cfoutput>
	</TABLE>
	</cfsavecontent>
	<cfset qGetChangeLog.addProgramHistory(
			programId = Contract_Main_ID, 
			contractNumber = Contract_Number,
			content = programCancelReportContent,
			historyAction = 500,
			deletePreviousEntry = 1) />
</cfloop>
<cfset timeEnd("cancelled")>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~ Add entry for changed programs ~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cfset timeBegin("changed")>
<cfset qGetChangedPrograms = qGetChangeLog.GetChangedPrograms() />
<cfif qGetChangedPrograms.RecordCount neq 0>

	<cfloop query="qGetChangedPrograms">
		<cfset timeBegin(qGetChangedPrograms.Child_Contract_Main_ID)>
        
        <cfset useLakebaseForCheckParent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForCheckParent>
	<cftry>
		<cfset CheckParent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main_aux_data", {
				"contract_main_id" = "eq.#qGetChangedPrograms.Parent_Revised_Contract_Main_ID#",
				"select" = "run_program_history"
			}), "run_program_history"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckParent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckParent>
<cfquery name="CheckParent" datasource="#application.datasource#">
            SELECT Run_Program_History
            FROM Contract_Main_Aux_Data
            WHERE Contract_Main_ID = '#qGetChangedPrograms.Parent_Revised_Contract_Main_ID#'
        </cfquery>
</cfif>

        <cfif CheckParent.Run_Program_History eq 0 or CheckParent.Run_Program_History eq 2>
            <cfset changed_program()>
        </cfif>

	    <cfset timeEnd(qGetChangedPrograms.Child_Contract_Main_ID)>
	</cfloop>

</cfif>
<cfset timeEnd("changed")>
<cfset timeEnd("program_change_history")>

</body>
</html>

<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~ DONE ~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->





<cffunction name="changed_program">
    <cfset ProgramGenericType = qGetChangedPrograms.generic_type>

    <!--- Initialize Query variables from component--->
    <!--- "Child" is the revision of the parent, which could be the original program or a revision --->

    <!--- The person who created the revised program --->
    <cfset Child_Creator_Name = qGetChangeLog.getUserName(qGetChangedPrograms.Child_Creator_ID)>

    <!--- The person/s who agreed to the revised program --->
    <cfset Child_Who_Agreed = qGetChangeLog.getProgramAgreed(Child_Contract_Main_ID)>

    <!--- How is the program amount claimed --->
    <cfset Parent_Claim_Mechanics = qGetChangeLog.getPaymentTypes(Parent_Claim_Mechanics)>
    <cfset Child_Claim_Mechanics = qGetChangeLog.getPaymentTypes(Child_Claim_Mechanics)>

    <!--- What is the frequency of the amount claimed --->
    <cfset Parent_Payment_Cycle = qGetChangeLog.getPaymentCycle(Parent_Payment_Cycle)>
    <cfset Child_Payment_Cycle = qGetChangeLog.getPaymentCycle(Child_Payment_Cycle)>

    <cfset ContractNumber = qGetChangeLog.getContractNumber(Parent_Contract_Main_ID)>

    <!--- The number of existing revisions for a program in the "Program_History" table --->
    <cfset History_Count = qGetChangeLog.getHistoryCount(ContractNumber.Contract_Number)>

    <!--- Sales person responsible for the revision --->
    <cfset Child_Responsible_Sales_Person_ID = qGetChangeLog.getResponsibleUser(Child_Contract_Number,Child_Approval_Date)>
    <cfset Child_Responsible_Sales_Person = qGetChangeLog.getUserName(Child_Responsible_Sales_Person_ID.Responsible_User_ID)>

    <!--- User position of the person who created the revision --->
    <cfset Child_User_Position = qGetChangeLog.getUserPosition(Child_Responsible_Sales_Person_ID.Creating_User_Position_ID)>

    <!--- Parent person responsible for the revision --->
    <cfset Parent_Responsible_Sales_Person_ID = qGetChangeLog.getResponsibleUser(Parent_Contract_Number,Parent_Approval_Date)>
    <cfset Parent_Responsible_Sales_Person = qGetChangeLog.getUserName(Parent_Responsible_Sales_Person_ID.Responsible_User_ID)>

    <!--- User position of the person who created the parent program --->
    <cfset Parent_User_Position = qGetChangeLog.getUserPosition(Parent_Responsible_Sales_Person_ID.Creating_User_Position_ID)>

    <!--- To have a alternating color format for the revisions of the program. (If you make a color change here, a change may have to
        be made in "common_files/contracts/view_contract_history.cfm" --->
    <cfif History_Count.ProgramCount Mod 2 eq 1>
        <cfset ColorBackground = "FFCE84">
    <cfelse>
        <cfset ColorBackground = "FFDE84">
    </cfif>

    <!--- ngt --->
    <cfsavecontent variable="programChangeReport">
        <html>
        <head>
            <title>Scheduled Change Log</title>
            <style>
            TABLE.ChangeLog
            {
                font-size:10px;
                font-family:Arial;
            }
            TABLE.ChangeLog TD
            {
                border: 1px solid black;
                font-family:Arial;
            }
            TD.Heading
            {		
                font-weight:bold;
                font-family:Arial;
            }
            TD.ItemHeading
            {		
                font-weight:bold;
                font-size:12px;
                font-family:Arial;
            }
            TABLE.ChangeLogNoBorder
            {
                font-size:10px;
                font-family:Arial;
            }
            TABLE.ChangeLogNoBorder TD
            {
                border: none;
            }
            .sp_0
            {
                color:red;
            }
            .sp_1
            {
                color:blue;
            }
            .sp_2
            {
                color:green;
            }
            </style>
        </head>
    
        <body>
        <cfscript>
            //0=delete, 1=add, 2=change (color code)
    
            function displayChange(sStr, iCount, color_code)
            {
                if(iCount GT 0)
                {
                    WriteOutput("<br>");
                }
                WriteOutput("<span class=sp_" & color_code & ">" & sStr & "</span>");
                return (iCount  + 1);
            }
    
            function displayLumpSum(qLumpSum1, qLumpSum2,ParentLumpSumPaymentCycle, ChildLumpSumPaymentCycle)
            {
                var currentRow = 1;
                var deleteFromSecond = 0;
                var sAction = 0;
                var iCount = 0;
                var secondIndex = 1;
                
                Parent_LumpSum_Claim_Mechanics = qGetChangeLog.getPaymentTypes(qGetThisLumpSum2.Claim_Mechanics);
                Child_LumpSum_Claim_Mechanics = qGetChangeLog.getPaymentTypes(qGetThisLumpSum1.Claim_Mechanics);
        
                for (; currentRow lte qLumpSum1.RecordCount;currentRow = currentRow + 1)
                {
                    secondRecordCount = (qLumpSum2.RecordCount - secondIndex) + 1;
        
                    deleteFromSecond = 0;
                    if(secondRecordCount EQ 0)
                    {
                        sAction = "add";
                    }
                    else if(qLumpSum1["Lump_Sum_Amount"][currentRow] EQ qLumpSum2["Lump_Sum_Amount"][secondIndex] AND qLumpSum1["Lump_Sum_Volume"][currentRow] EQ qLumpSum2["Lump_Sum_Volume"][secondIndex]
                            AND ParentLumpSumPaymentCycle eq  ChildLumpSumPaymentCycle AND Parent_LumpSum_Claim_Mechanics.Payment_Type_Name EQ Child_LumpSum_Claim_Mechanics.Payment_Type_Name)
                    {
                        sAction = "nochange";
                        deleteFromSecond = 1;
                    }
                    else if((qLumpSum1.RecordCount - currentRow) LT secondRecordCount)
                    {
                        sAction = "change";
                        deleteFromSecond = 1;
                    }
                    else
                    {
                        sAction = "add";
                    }
                    
                    displayLumpChnage(qLumpSum1, qLumpSum2, currentRow, secondIndex, sAction, ParentLumpSumPaymentCycle, ChildLumpSumPaymentCycle);
                    
                    if(deleteFromSecond)
                    {
                        secondIndex = secondIndex + 1;
                    }	
                }

                // Display deleted
                for (; secondIndex lte qLumpSum2.RecordCount;secondIndex = secondIndex + 1)
                {
                    displayLumpChnage(qLumpSum1, qLumpSum2, currentRow, secondIndex, "delete", ParentLumpSumPaymentCycle, ChildLumpSumPaymentCycle);
                }
            }

            // To Differentiate between Groups and Items.Also,we cannot use "var" outside a function.
            GrouporItem = "";
            ShowLabel = 0;
            function displayLumpChnage(qLumpSum1, qLumpSum2, currentRow, secondIndex, sAction, ParentLumpSumPaymentCycle, ChildLumpSumPaymentCycle)
            {	
                var iCount = 0;
                var Amount = 0;
                var Volume = 0;
                var PaymentCycle = 0;
                var ClaimMechanism = 0;
                var pAction ="";
                var HideRecord = 1;
                var TotalRecords="";
                var	PaymentCycleDiff = 0;
                    
                Parent_LumpSum_Claim_Mechanics = qGetChangeLog.getPaymentTypes(qGetThisLumpSum2.Claim_Mechanics);
                Child_LumpSum_Claim_Mechanics = qGetChangeLog.getPaymentTypes(qGetThisLumpSum1.Claim_Mechanics);
                
                if(ParentLumpSumPaymentCycle neq ChildLumpSumPaymentCycle)
                {
                    PaymentCycleDiff = 1;
                }
        
                Second_Product_List = "";
                if(sAction NEQ "add")
                {
                    qGetLumpProducts1 = qGetChangeLog.getLumpProducts(qLumpSum2["Program_Lump_Sum_ID"][secondIndex]);
                    Second_Product_List = ValueList(qGetLumpProducts1.MaterialID);
                }
            
                First_Product_List = "";
                if(sAction NEQ "delete")
                {
                    qGetLumpProducts2 = qGetChangeLog.getLumpProducts(qLumpSum1["Program_Lump_Sum_ID"][currentRow]);
                    First_Product_List = ValueList(qGetLumpProducts2.MaterialID);
                }
            
    
                ProductChanged = 0;
                if(Second_Product_List NEQ First_Product_List AND sAction NEQ "add" AND sAction NEQ "delete")
                {
                    productChanged = 1;
                }
            
                if(ShowLabel eq 0)
                {
                    if(ProductChanged EQ 1 OR saction eq "add" OR saction eq "delete" OR qLumpSum1.Lump_Sum_Amount[secondIndex] neq qLumpSum2.Lump_Sum_Amount[secondIndex] OR qLumpSum1.Lump_Sum_Volume[secondIndex] neq qLumpSum2.Lump_Sum_Volume[secondIndex] 
                    OR qLumpSum1.Claim_Mechanics[secondIndex] neq qLumpSum2.Claim_Mechanics[secondIndex] OR PaymentCycleDiff eq 1)
                    {
                        writeoutput("<TR valign='top'><TD colspan='100%' class='itemHeading'>"&Application.LumpsumLabel&"</TD></TR>");
                        ShowLabel = 1;
                    }
                }
                
                if(sAction NEQ "delete")
                {
                    if(ProductChanged EQ 1 OR saction eq "add" OR qLumpSum1.Lump_Sum_Amount[secondIndex] neq qLumpSum2.Lump_Sum_Amount[secondIndex] OR qLumpSum1.Lump_Sum_Volume[secondIndex] neq qLumpSum2.Lump_Sum_Volume[secondIndex] 
                        OR qLumpSum1.Claim_Mechanics[secondIndex] neq qLumpSum2.Claim_Mechanics[secondIndex] OR PaymentCycleDiff eq 1)
                    {
                        // Only if product was added, get the added products
                        if(ProductChanged EQ 1)
                        { 
                            for(i=1; i lte qGetLumpProducts2.RecordCount; i = i+1)
                            {
                                if(ListFind(Second_Product_List,qGetLumpProducts2.MaterialID[i]) neq 0)
                                {
                                    QuerySetCell(qGetLumpProducts2,"Item","", i);
                                    QuerySetCell(qGetLumpProducts2,"Description","", i);
                                }
                                
                            }
                            // If there added  products, set HideRecord to zero, as we want to display those products
                            HideRecord = displayLumpProducts(qGetLumpProducts2,qGetLumpProducts2.Is_Group,0);
                            
                        }
                
                        /* We get data from the query Ordered by groups and then Items and so When we change from one to other,
                            show the appropriate category (groups or items) */
                        if(IsDefined("qGetLumpProducts2"))
                        {
                            if(qGetLumpProducts2.Is_Group neq "" AND GrouporItem neq qGetLumpProducts2.Is_Group AND HideRecord eq 0)
                            {
                                WriteOutput("<TR valign=""top"">");
                                WriteOutput("<TD>");
                                GrouporItem = qGetLumpProducts2.Is_Group;
                                WriteOutput(qGetLumpProducts2.Is_Group);
                                WriteOutput("&nbsp;</TD>");
                                WriteOutput("<TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD>");
                                WriteOutput("</TR>");
                            }
                        }
        
            
                        // If there are products added or Amount/Volume changed or a new component is added
                        if ((saction neq "nochange" AND (qLumpSum1.Lump_Sum_Amount[secondIndex] neq qLumpSum2.Lump_Sum_Amount[secondIndex] OR qLumpSum1.Lump_Sum_Volume[secondIndex] neq qLumpSum2.Lump_Sum_Volume[secondIndex]  
                            OR qLumpSum1.Claim_Mechanics[secondIndex] neq qLumpSum2.Claim_Mechanics[secondIndex] OR PaymentCycleDiff eq 1))
                            OR HideRecord EQ 0 OR saction eq "add")
                        {

                            WriteOutput("<TR valign=""top"">");
                    
                            //If a new component is added OR Amount/Volume changed
                            if(saction eq "add" OR qLumpSum1.Lump_Sum_Amount[secondIndex] eq qLumpSum2.Lump_Sum_Amount[secondIndex] AND qLumpSum1.Lump_Sum_Volume[secondIndex] eq qLumpSum2.Lump_Sum_Volume[secondIndex] 
                            AND qLumpSum1.Claim_Mechanics[secondIndex] eq qLumpSum2.Claim_Mechanics[secondIndex] AND PaymentCycleDiff eq 0)
                            {
                                WriteOutput("<TD>&nbsp;</TD>");
                            }
                            WriteOutput("<TD>&nbsp;</TD>");
                            WriteOutput("<TD>");
                        
                            //If a new component is added	
                            if(saction eq "add")
                            {
                                WriteOutput(qLumpSum1["Program_Lump_Sum_Name"][secondIndex]);
                            }
                            else
                            {
                                WriteOutput(qLumpSum2["Program_Lump_Sum_Name"][secondIndex]);
                            }
                            
                            //If the Amount changes and a new component is not added
                            if(qLumpSum1.Lump_Sum_Amount[secondIndex] neq qLumpSum2.Lump_Sum_Amount[secondIndex] and saction neq "add")
                            {
                                Amount = 1;
                                WriteOutput(" (" & qLumpSum2["Lump_Sum_Amount"][secondIndex] & ")");
                            }
                            
                            //If the volume changes and a new component is not added
                            if(qLumpSum1.Lump_Sum_Volume[secondIndex] neq qLumpSum2.Lump_Sum_Volume[secondIndex] and saction neq "add")
                            {
                                Volume = 1;
                                WriteOutput(" (" & qLumpSum2["Lump_Sum_Volume"][secondIndex] & ")");
                            }
                            
                            //If the claim mechanism changes and a new component is not added
                            if(Parent_LumpSum_Claim_Mechanics.Payment_Type_Name neq Child_LumpSum_Claim_Mechanics.Payment_Type_Name and saction neq "add")
                            {
                                ClaimMechanism = 1;
                                WriteOutput(" (" & Parent_LumpSum_Claim_Mechanics.Payment_Type_Name & ")");
                            }
                            
                            //If the payment cycle changes and a new component is not added
                            if(PaymentCycleDiff eq 1 and saction neq "add")
                            {
                                PaymentCycle = 1;					
                                WriteOutput(" (" &ParentLumpSumPaymentCycle& ")");
                            }
                            
                            //  If there are products added, set pAction to Add
                            if(HideRecord EQ 0)
                            {
                    
                                if(Volume eq 1 OR Amount eq 1 OR ClaimMechanism eq 1 OR PaymentCycle eq 1)
                                {
                                    for(i=1; i lte qGetLumpProducts1.RecordCount; i = i+1)
                                    {
                                        if(ListFind(First_Product_List,qGetLumpProducts1.MaterialID[i]) neq 0)
                                        {
                                            QuerySetCell(qGetLumpProducts1,"Item","", i);
                                            QuerySetCell(qGetLumpProducts1,"Description","", i);	
                                        }
                                    }
                                    if(qGetLumpProducts1.Recordcount GT 1)
                                    {
                                        displayLumpProducts(qGetLumpProducts1,qGetLumpProducts1.Is_Group,1);
                                    }
                                    else
                                    {
                                        displayLumpProducts(qGetLumpProducts2,qGetLumpProducts2.Is_Group,1);
                                    }
                                }
                                else
                                {
                                    // If we pass "1" in the function, Do not Display products
                                    displayLumpProducts(qGetLumpProducts2,qGetLumpProducts2.Is_Group,1);
                                }
                                pAction = "add";
                            }			

                            WriteOutput("&nbsp;</TD>");
                        
                            //  If there are products added	
                            if(HideRecord EQ 0)
                            {
                                if(pAction eq "add" AND sAction neq "change")
                                {
                                    WriteOutput("<TD>");
                                    iCount = displayChange("Added", iCount, 1);
                                    WriteOutput("</TD>");
                                    WriteOutput("</TR>");
                                }
                            }
                        }
                                
                    }
                }

                Volume = 0;
                Amount = 0;
                ClaimMechanism = 0;
                PaymentCycle = 0;
        
                if(sAction NEQ "add")
                {
                
                    if(ProductChanged EQ 1 OR saction eq "delete" OR qLumpSum1.Lump_Sum_Amount[secondIndex] neq qLumpSum2.Lump_Sum_Amount[secondIndex] OR qLumpSum1.Lump_Sum_Volume[secondIndex] neq qLumpSum2.Lump_Sum_Volume[secondIndex] 
                        OR qLumpSum1.Claim_Mechanics[secondIndex] neq qLumpSum2.Claim_Mechanics[secondIndex] OR PaymentCycleDiff eq 1)
                    {
                        HideRecord = 1;
                        // Only if product was deleted, get the deleted products
                        if(ProductChanged EQ 1) 
                        {
                            for(i=1; i lte qGetLumpProducts1.RecordCount; i = i+1)
                            {
                                if(ListFind(First_Product_List,qGetLumpProducts1.MaterialID[i]) neq 0)
                                {
                                    QuerySetCell(qGetLumpProducts1,"Item","", i);
                                    QuerySetCell(qGetLumpProducts1,"Description","", i);	
                                }
                        
                            }
                            // If there deleted  products, set HideRecord to zero, as we want to display those products
                            HideRecord = displayLumpProducts(qGetLumpProducts1,qGetLumpProducts1.Is_Group,0);
                
                        }
                        /* We get data from the query Ordered by groups and then Items and so When we change from one to other,
                            show the appropriate category (groups or products) */
                        if(IsDefined("qGetLumpProducts1"))
                        {		
                            if(saction neq "change" and qGetLumpProducts1.Is_Group neq "" AND GrouporItem neq qGetLumpProducts1.Is_Group AND HideRecord eq 0)
                            {					
                                WriteOutput("<TR valign=""top"">");
                                WriteOutput("<TD>");
                                GrouporItem = qGetLumpProducts1.Is_Group;
                                WriteOutput(qGetLumpProducts1.Is_Group);
                                WriteOutput("&nbsp;</TD>");
                                WriteOutput("<TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD>");
                                WriteOutput("</TR>");
                            }
                        }
                    
                        //If there are products deleted or Amount/Volume changed or a component is delete
                        if((saction neq "nochange" AND (qLumpSum1.Lump_Sum_Amount[secondIndex] neq qLumpSum2.Lump_Sum_Amount[secondIndex] OR qLumpSum1.Lump_Sum_Volume[secondIndex] neq qLumpSum2.Lump_Sum_Volume[secondIndex]  
                        OR qLumpSum1.Claim_Mechanics[secondIndex] neq qLumpSum2.Claim_Mechanics[secondIndex] OR PaymentCycleDiff eq 1))
                        OR HideRecord EQ 0 OR saction eq "delete")
                        {
                            //If a component is deleted OR Amount/Volume changed
                            if(saction eq "delete" OR qLumpSum1.Lump_Sum_Amount[secondIndex] eq qLumpSum2.Lump_Sum_Amount[secondIndex] AND qLumpSum1.Lump_Sum_Volume[secondIndex] eq qLumpSum2.Lump_Sum_Volume[secondIndex]  
                                AND qLumpSum1.Claim_Mechanics[secondIndex] eq qLumpSum2.Claim_Mechanics[secondIndex] AND PaymentCycleDiff eq 0)
                            {					
                                WriteOutput("<TR valign=""top"">");
                                WriteOutput("<TD>&nbsp;</TD>");	
                            }
        
                            WriteOutput("<TD>");
                        
                            //If a component is deleted
                            if (saction eq "delete")
                            {
                                WriteOutput(qLumpSum2["Program_Lump_Sum_Name"][secondIndex]);
                            }
                            else
                            {
                                WriteOutput(qLumpSum1["Program_Lump_Sum_Name"][secondIndex]);
                            }
                    
                            //If the Amount changes and a component is not deleted
                            if(qLumpSum1.Lump_Sum_Amount[secondIndex] neq qLumpSum2.Lump_Sum_Amount[secondIndex] and saction neq "delete")
                            {
                                Amount = 1;
                                WriteOutput(" (" & qLumpSum1["Lump_Sum_Amount"][secondIndex] & ")");
                            }
                    
                            //If the volume changes and a component is not deleted
                            if(qLumpSum1.Lump_Sum_Volume[secondIndex] neq qLumpSum2.Lump_Sum_Volume[secondIndex] and saction neq "delete")
                            {
                                Volume = 1;
                                WriteOutput(" (" & qLumpSum1["Lump_Sum_Volume"][secondIndex] & ")");
                            }
                    
                            //If the claim mechanism changes and a component is not deleted
                            if(Parent_LumpSum_Claim_Mechanics.Payment_Type_Name neq Child_LumpSum_Claim_Mechanics.Payment_Type_Name and saction neq "delete")
                            {
                                ClaimMechanism = 1;
                                WriteOutput(" (" & Child_LumpSum_Claim_Mechanics.Payment_Type_Name & ")");
                            }
                    
                            //If the payment cycle changes and a component is not deleted
                            if(PaymentCycleDiff eq 1 and saction neq "delete")
                            {
                                PaymentCycle = 1;
                                WriteOutput(" (" & ChildLumpSumPaymentCycle & ")");
                            }
                    
                            //  If there are products added, set pAction to Delete			
                            if(HideRecord EQ 0) 
                            {
                    
                                if(Volume eq 1 OR Amount eq 1 OR PaymentCycle eq 1 OR ClaimMechanism eq 1)
                                {
                                    /*
                                    for(i=1; i lte qGetLumpProducts2.RecordCount; i = i+1)
                                    {
                                        if(ListFind(Second_Product_List,qGetLumpProducts2.MaterialID[i]) neq 0)
                                        {
                                            QuerySetCell(qGetLumpProducts2,"Item","", i);
                                            QuerySetCell(qGetLumpProducts2,"Description","", i);	
                                        }
                                        
                                    }
                                    */
                                    if(qGetLumpProducts2.Recordcount GT 1)
                                    {
                                        displayLumpProducts(qGetLumpProducts2,qGetLumpProducts2.Is_Group,1);
                                    }
                                    else
                                    {
                                        displayLumpProducts(qGetLumpProducts1,qGetLumpProducts1.Is_Group,1);
                                    }
                                }
                                else
                                {
                                    // If we pass "1" in the function, Do not Display products
                                    displayLumpProducts(qGetLumpProducts1,qGetLumpProducts1.Is_Group,1);
                                }
                                pAction = pAction & "Delete";
                            }
                                                
                            WriteOutput("&nbsp;</TD>");
                        
                            //  If there are products deleted and a component is not deleted	
                            if(HideRecord EQ 0 OR saction eq "delete") 
                            {
                                if(saction eq "delete"  OR  qLumpSum1.Lump_Sum_Amount[secondIndex] eq qLumpSum2.Lump_Sum_Amount[secondIndex] AND qLumpSum1.Lump_Sum_Volume[secondIndex] eq qLumpSum2.Lump_Sum_Volume[secondIndex] 
                                    AND qLumpSum1.Claim_Mechanics[secondIndex] eq qLumpSum2.Claim_Mechanics[secondIndex] AND PaymentCycleDiff eq 0)
                                {
                                    WriteOutput("<TD>&nbsp;</TD>");
                                }
                                if(HideRecord EQ 0  AND sAction neq "change")
                                { 
                                    WriteOutput("<TD>");
                                    iCount = displayChange("Deleted", iCount, 0);
                                }
                            }
                        }
                    }	
                }
    

                // If a product is added/deleted or amount/volume changes
                if((ProductChanged EQ 1 OR qLumpSum1.Lump_Sum_Amount[secondIndex] neq qLumpSum2.Lump_Sum_Amount[secondIndex] OR qLumpSum1.Lump_Sum_Volume[secondIndex] neq qLumpSum2.Lump_Sum_Volume[secondIndex] 
                    OR qLumpSum1.Claim_Mechanics[secondIndex] neq qLumpSum2.Claim_Mechanics[secondIndex] OR PaymentCycle eq 1))	
                {
    
                    // If products are not added or deleted
                    if((saction neq "nochange"))
                    {
                        WriteOutput("<TD>");
                    }
        
                    // If a new component is added
                    if(sAction EQ "add")
                    {	
                        iCount = displayChange("Added", iCount, 1);
                    }
                    // If amount/volume changes
                    else if(sAction EQ "change")
                    {
                        if(Amount eq 1 AND Volume eq 1 AND PaymentCycle eq 1 AND ClaimMechanism eq 1)
                        {
                            iCount = displayChange("(Amount) (Volume) (Payment Cycle) (Claim Mechanism) Changed", iCount, 2);
                        }
                        else if(Amount eq 1 AND Volume eq 1 AND ClaimMechanism eq 1)
                        {
                            iCount = displayChange("(Amount) (Volume) (Claim Mechanism) Changed", iCount, 2);
                        }
                        else if(Volume eq 1 AND PaymentCycle eq 1 AND ClaimMechanism eq 1)
                        {
                            iCount = displayChange("(Volume) (Payment Cycle) (Claim Mechanism) Changed", iCount, 2);
                        }
                        else if(Amount eq 1 AND Volume eq 1 AND PaymentCycle eq 1)
                        {
                            iCount = displayChange("(Amount) (Volume) (Payment Cycle) Changed", iCount, 2);
                        }
                        else if(Amount eq 1 AND Volume eq 1)
                        {
                            iCount = displayChange("(Amount) (Volume) Changed", iCount, 2);
                        }
                        else if(Amount eq 1 AND PaymentCycle eq 1)
                        {
                            iCount = displayChange("(Amount) (Payment Cycle) Changed", iCount, 2);
                        }
                        else if(volume eq 1 AND PaymentCycle eq 1)
                        {
                            iCount = displayChange("(Volume) (Payment Cycle) Changed", iCount, 2);
                        }
                        else if(Amount eq 1 AND ClaimMechanism eq 1)
                        {
                            iCount = displayChange("(Amount) (Claim Mechanism) Changed", iCount, 2);
                        }
                        else if(volume eq 1 AND ClaimMechanism eq 1)
                        {
                            iCount = displayChange("(Volume) (Claim Mechanism) Changed", iCount, 2);
                        }
                        else if(PaymentCycle eq 1 AND ClaimMechanism eq 1)
                        {
                            iCount = displayChange("(Payment Cycle) (Claim Mechanism) Changed", iCount, 2);
                        }
                        else if(Amount eq 1)
                        {
                            iCount = displayChange("(Amount) Changed", iCount, 2);
                        }
                        else if(Volume eq 1)
                        {
                            iCount = displayChange("(Volume) Changed", iCount, 2);
                        }
                        else if(PaymentCycle eq 1)
                        {
                            iCount = displayChange("(Payment Cycle) Changed", iCount, 2);
                        }
                        else if(ClaimMechanism eq 1)
                        {
                            iCount = displayChange("(Claim Mechanism) Changed", iCount, 2);
                        }
                    }

                    // If a component is deleted
                    else if(sAction EQ "delete")
                    {
                        iCount = displayChange("Deleted", iCount, 0);
                    }
        
                    if(pAction eq "adddelete" AND sAction eq "change")
                    {
                        iCount = displayChange("Added", iCount, 1);
                        iCount = displayChange("Deleted", iCount, 0);
                        WriteOutput("&nbsp;</TD>");
                        WriteOutput("</TR>");
                    }
                    else if(pAction eq "add" AND sAction eq "change")
                    {
                        iCount = displayChange("Added", iCount, 1);
                        WriteOutput("&nbsp;</TD>");
                        WriteOutput("</TR>");
                    }
                    else if(pAction eq "delete" AND sAction eq "change")
                    {
                        iCount = displayChange("Deleted", iCount, 0);
                        WriteOutput("&nbsp;</TD>");
                        WriteOutput("</TR>");
                    }
        

                    if((saction neq "nochange" AND saction neq "change") OR (pAction eq "Delete"  AND sAction neq "change"))
                    {
                        WriteOutput("&nbsp;</TD>");
                        WriteOutput("</TR>");
                    }
        
                }
            }

            function displayLumpProducts(qLumpProducts,Is_Group,ShowProduct)
            {
                var EmptyRecordset = 1;
                var currentRow = 1;
                
                for (; currentRow lte qLumpProducts.RecordCount;currentRow = currentRow + 1)
                {
                    if(qLumpProducts["Description"][currentRow] neq "")
                    {
                        if(ShowProduct eq 1)
                        {
                        WriteOutput("<br>" &  qLumpProducts["Item"][currentRow]  & " " & qLumpProducts["Description"][currentRow]);
                        }
                    EmptyRecordset = 0;
                    }
                }
                
                return EmptyRecordset;
            }


            function ReturnRate(productItemId, productName, rebateId)
            {
                var currentRow = 1;
                var rateArray = ArrayNew(1);
                ArrayAppend(rateArray, 0);
                ArrayAppend(rateArray, 0);
                ArrayAppend(rateArray, 0);
                ArrayAppend(rateArray, 0);
                
                qGetRebateRates = qGetChangeLog.getRebateRates(rebateId);
                
                if(qGetRebateRates.recordCount)
                {                                
                    for (; currentRow lte qGetRebateRates.RecordCount;	currentRow = currentRow + 1)
                    {					
                        thisRate = StructNew();
                        rateArray[qGetRebateRates["Unit_Of_Measure_ID"][currentRow]] = val(rateArray[qGetRebateRates["Unit_Of_Measure_ID"][currentRow]]) + val(qGetRebateRates["Rate"][currentRow]);			
                    }
                }
                return rateArray;
            }


            function DisplayProduct(productItemId, productName)
            {
                WriteOutput(productItemId & " " & productName);
            }


            function DisplayRebate(FirstRebateID, SecondRebateID,rateArray1,rateArray2, CurrentOrPrevious)
            {
                var currentRow = 1;
                qGetRebateRates1 = qGetChangeLog.getRebateRates(FirstRebateID);
                qGetRebateRates2 = qGetChangeLog.getRebateRates(SecondRebateID);
                
                if(qGetRebateRates1.recordCount)
                {
                    for (; currentRow lte qGetRebateRates1.RecordCount;	currentRow = currentRow + 1)
                    {
                        if(qGetRebateRates1["Program_Rebates_Component_Name"][currentRow] eq qGetRebateRates2["Program_Rebates_Component_Name"][currentRow] AND qGetRebateRates1["Rate"][currentRow] neq qGetRebateRates2["Rate"][currentRow])
                        {
                            if(CurrentOrPrevious eq 1)
                            {
                                WriteOutput("<br>" & qGetRebateRates1["Program_Rebates_Component_Name"][currentRow] & "-"); 
                                WriteOutput(qGetRebateRates1["Rate"][currentRow] & " " & qGetRebateRates1["UOM"][currentRow]);
                            }
                            else if(CurrentOrPrevious eq 2)
                            {
                                WriteOutput("<br>" & qGetRebateRates2["Program_Rebates_Component_Name"][currentRow] & "-"); 
                                WriteOutput(qGetRebateRates2["Rate"][currentRow] & " " & qGetRebateRates2["UOM"][currentRow]);
                            }
                        }
                    }
                }                   
            }

            function checkRateDifference(FirstRebateID, SecondRebateID, rateArray1, rateArray2)
            {
                var IsRateDifferent = 0;
                var ComponentName = "";
                var currentRow = 1;
                qGetRebateRates1 = qGetChangeLog.getRebateRates(FirstRebateID);
                qGetRebateRates2 = qGetChangeLog.getRebateRates(SecondRebateID);
                
                if(qGetRebateRates1.recordCount)
                {
                    for (; currentRow lte qGetRebateRates1.RecordCount;	currentRow = currentRow + 1)
                    {
                        if(qGetRebateRates1["Program_Rebates_Component_Name"][currentRow] eq qGetRebateRates2["Program_Rebates_Component_Name"][currentRow] AND qGetRebateRates1["Rate"][currentRow] neq qGetRebateRates2["Rate"][currentRow])
                        {
                            ComponentName = qGetRebateRates1["Program_Rebates_Component_Name"][currentRow];
                        }
                    }
                }	
                    
                If(ComponentName neq "")
                {
                    IsRateDifferent = 1;
                }
                
                return IsRateDifferent;
            }

            function getComponent(rateArray1, rateArray2)
            {
                var ComponentName = "";
                var thisArrayLen = ArrayLen(rateArray1);
                if(thisArrayLen EQ ArrayLen(rateArray2))
                {
                    for(i=1; i LTE thisArrayLen;i=i+1)
                    {
                        if(rateArray1[i] NEQ rateArray2[i])
                        {
                        ComponentName = qGetRebateRates["Program_Rebates_Component_Name"][i];		
                        }
                    }
                }
                return ComponentName;
            }


            function checkGrowthDifference(rateQuery1, rateQuery2, currentRow, diffArray)
            {
                if(rateQuery1.recordCount)
                {
                    if(NOT diffArray[1]) //no need to check difference if already different
                    {
                        if(rateQuery1["Range_Start"][currentRow] NEQ rateQuery2["Range_Start"][currentRow]
                                OR
                                rateQuery1["Range_End"][currentRow] NEQ rateQuery2["Range_End"][currentRow])
                        {
                            diffArray[1] = diffArray[1] OR 1;
                        }
                    }
                    if(NOT diffArray[2]) //no need to check difference if already different
                    {
                        if(rateQuery1["First_Rate"][currentRow] NEQ rateQuery2["First_Rate"][currentRow]
                                OR
                                rateQuery1["First_UOM"][currentRow] NEQ rateQuery2["First_UOM"][currentRow])
                        {
                            diffArray[2] = 1;
                        }
                    }
                }	
                return diffArray;
            }
        </cfscript>

        <cfoutput>
        <br />

        <!--- (Change start) If there is a code change made here(table below), a corresponding code change may have to be made in "common_files/contracts/view_contract_history.cfm" --->
        <TABLE cellpadding="3" align="center" cellspacing="0" border="0" width="80%" class="ChangeLog">
            <TR>
                <TD  valign="top" class="Heading" style="background-color:#ColorBackground#">Version</TD>
                <TD  valign="top" class="heading" style="background-color:#ColorBackground#">Created By</TD>
                <cfif Child_Who_Agreed.Recordcount neq 0>
                <TD  valign="top" class="heading" style="background-color:#ColorBackground#">Agreed By</TD>
                </cfif>
                <TD  valign="top" class="heading" style="background-color:#ColorBackground#">Approved By</TD>
                <TD  valign="top" class="heading" style="background-color:#ColorBackground#">Contract Span</TD>
            </TR>
            <TR>
                <TD valign="top"><cfif len(qGetChangedPrograms.Child_Revision_Version) eq 4>#right("#qGetChangedPrograms.Child_Revision_Version#", 4)#<cfelseif len(qGetChangedPrograms.Child_Revision_Version) eq 5>#right("#qGetChangedPrograms.Child_Revision_Version#", 5)#<cfelse>#right("000#qGetChangedPrograms.Child_Revision_Version#", 3)#</cfif>&nbsp;</TD>
                <TD valign="top">#Child_Creator_Name.Name#&nbsp;(#DateFormat(Child_Contract_Created_Date,"M/D/YYYY")# #TimeFormat(Child_Contract_Created_Date, "h:mm tt")#)&nbsp;</TD>
                <cfif Child_Who_Agreed.Recordcount neq 0>
                <TD valign="top"><cfloop query="Child_Who_Agreed">#Name_First#&nbsp;#Name_Last#&nbsp;(#DateFormat(Agree_DateTime,"M/D/YYYY")# #TimeFormat(Agree_DateTime,"h:mm tt")#)<br/></cfloop>&nbsp;</TD>
                </cfif>
                <TD valign="top">#Child_Approver#&nbsp;(#DateFormat(Child_Approval_Date,"M/D/YYYY")# #TimeFormat(Child_Approval_Date, "h:mm tt")#)&nbsp;</TD>
                <TD valign="top">#DateFormat(Child_Contract_Start_Date,"M/D/YYYY")# - #DateFormat(Child_Contract_End_Date,"M/D/YYYY")#&nbsp;</TD>
            </TR>
        </TABLE>

        <!--- (Change end) If there is a code change made here(table above), a corresponding code change may have to be made in "common_files/contracts/view_contract_history.cfm" --->
        <br />

        <TABLE cellpadding="3" align="center" cellspacing="0" width="80%" border="0" class="ChangeLog">
            <TR>
                <TD  class="heading" style="background-color:#ColorBackground#">WHAT</TD>
                <TD  class="heading" style="background-color:#ColorBackground#">FROM</TD>
                <TD  class="heading" style="background-color:#ColorBackground#">TO</TD>
                <TD  class="heading" style="background-color:#ColorBackground#">ACTION</TD>
            </TR>

            <!------ Show Program Title ----->
            <cfif Contract_Title NEQ Parent_Contract_Title>
                <TR valign="top">
                    <TD><B>Title</B></TD>
                    <TD>#Parent_Contract_Title#&nbsp;</TD>
                    <TD>#Contract_Title#&nbsp;</TD>
                    <TD>
                    <cfset iCount = displayChange("Changed", 0, 2) />
                    &nbsp;</TD>
                </TR>
            </cfif>
    
            <!------ Show Program Notes ----->
            <cfif Notes NEQ Parent_Notes>
                <TR valign="top">
                    <TD><B>#labelnotes#</B>&nbsp;</TD>
                    <TD>#Parent_Notes#&nbsp;</TD>
                    <TD>#Notes#&nbsp;</TD>
                    <TD>
                    <cfset iCount = displayChange("Changed", 0, 2) />
                    &nbsp;</TD>
                </TR>
            </cfif>
    
            <!------ Show Program Dates ----->
            <cfif DateFormat(Child_Contract_Start_Date, "M/D/YYYY") neq DateFormat(Parent_Contract_Start_Date, "M/D/YYYY")  OR DateFormat(Child_Contract_End_Date, "M/D/YYYY") neq DateFormat(Parent_Contract_End_Date, "M/D/YYYY")>
                <TR valign="top">
                    <TD><B>Span</B></TD>
                    <TD>#DateFormat(Parent_Contract_Start_Date, "M/D/YYYY")# - #DateFormat(Parent_Contract_End_Date, "M/D/YYYY")#&nbsp;</TD>
                    <TD>#DateFormat(Child_Contract_Start_Date, "M/D/YYYY")# - #DateFormat(Child_Contract_End_Date, "M/D/YYYY")#&nbsp;</TD>
                    <TD>
                    <cfset iCount = displayChange("Changed", 0, 2) />
                    &nbsp;</TD>
                </TR>
            </cfif>

            <!--- If sales person responsible changes --->
            <cfif Child_Responsible_Sales_Person_ID.Responsible_User_ID NEQ Parent_Responsible_Sales_Person_ID.Responsible_User_ID>
                <TR valign="top">
                    <TD><B>Responsible Sales Person</B></TD>
                    <TD>#Parent_Responsible_Sales_Person.Name#&nbsp;(#Parent_User_Position.Position_Label#)&nbsp;</TD>
                    <TD>#Child_Responsible_Sales_Person.Name#&nbsp;(#Child_User_Position.Position_Label#)&nbsp;</TD>
                    <TD>
                    <cfset iCount = displayChange("Changed", 0, 2) />
                    &nbsp;</TD>
                </TR>
            </cfif>

            <!------ If program volume is different ----->
            <cfif (Parent_Contract_Quantity NEQ Child_Contract_Quantity)
                OR			 
                (Parent_Contract_Quantity_UOM NEQ Child_Contract_Quantity_UOM)>
                <TR valign="top">
                    <TD><B>Program Quantity</B></TD>
                    <TD>#Parent_Contract_Quantity# #Child_Contract_Quantity_UOM#&nbsp;</TD>
                    <TD>#Child_Contract_Quantity# #Parent_Contract_Quantity_UOM#&nbsp;</TD>
                    <TD>
                        <cfset iCount = displayChange("Changed", 0, 2) />&nbsp;
                    </TD>
                </TR>
            </cfif>

            <!------ If program Claim Mechanics is different ----->
            <cfif (Parent_Claim_Mechanics NEQ Child_Claim_Mechanics)>
                <TR valign="top">
                    <TD><B>Claim Mechanics</B></TD>
                    <TD>#Parent_Claim_Mechanics.Payment_Type_Name#&nbsp;</TD>
                    <TD>#Child_Claim_Mechanics.Payment_Type_Name#&nbsp;</TD>
                    <TD>
                        <cfset iCount = displayChange("Changed", 0, 2) />&nbsp;
                    </TD>
                </TR>
            </cfif>
    
            <!------ If Payment Cycle is different ----->
            <cfif (Parent_Payment_Cycle NEQ Child_Payment_Cycle)>
                <TR valign="top">
                    <TD><B>Payment Cycle</B></TD>
                    <TD>#Parent_Payment_Cycle.Payment_Cycle#&nbsp;</TD>
                    <TD>#Child_Payment_Cycle.Payment_Cycle#&nbsp;</TD>
                    <TD>
                        <cfset iCount = displayChange("Changed", 0, 2) />&nbsp;
                    </TD>
                </TR>
            </cfif>
    
            <!--- D8409: Broker and Trade Question --->
            <cfif 	Parent_Affect_Broker_Commission NEQ Child_Affect_Broker_Commission
                OR		Parent_Affect_Broker_Commission_Type NEQ Child_Affect_Broker_Commission_Type
                OR		Parent_Affect_Shelter NEQ Child_Affect_Shelter>
                <TR valign="top">
                    <TD><B>Broker/Trade Information</B></TD>
                    <TD>
                    #application.returned_customer_setting.broker_label_singular#'s commission affected by this #LCase(Application.RebateLabel)#/billback?: #programManager.getAffectBrokerCommission(Parent_Affect_Broker_Commission)#<br>
                    <cfif Parent_Affect_Broker_Commission EQ 1>
                    The commission should be: #programManager.getAffectBrokerCommissionType(Parent_Affect_Broker_Commission_Type)#<br>
                    </cfif>
                    Shelter affected?: #programManager.getAffectShelter(Parent_Affect_Shelter)#
                    &nbsp;</TD>
                    <TD>
                    #application.returned_customer_setting.broker_label_singular#'s commission affected by this #LCase(Application.RebateLabel)#/billback?: #programManager.getAffectBrokerCommission(Child_Affect_Broker_Commission)#<br>
                    <cfif Child_Affect_Broker_Commission EQ 1>
                    The commission should be: #programManager.getAffectBrokerCommissionType(Child_Affect_Broker_Commission_Type)#<br>
                    </cfif>
                    Shelter affected?: #programManager.getAffectShelter(Child_Affect_Shelter)#
                    &nbsp;</TD>
                    <TD>
                    <cfset iCount = displayChange("Changed", 0, 2) />
                    &nbsp;</TD>
                </TR>
            </cfif>

            <!------ If operator is in template ----->
            <cfif Specify_Operators>
                <!------ Get operator info ----->		
                <cfset qGetOperator1 = qGetChangeLog.getOperatorsRemoved(Child_Contract_Main_ID, Parent_Contract_Main_ID, 0) />
                <cfset qGetOperator2 = qGetChangeLog.getOperatorsRemoved(Parent_Contract_Main_ID, Child_Contract_Main_ID, 1) />
                <cfset HeaderShow = 0>

                <cfloop from="1" to="2" index="serialNum">
                    <cfset qGetOperator = Evaluate("qGetOperator#serialNum#")>
                    <cfloop query="qGetOperator">
                        <cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added) OR (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)
                            OR Change>
                            <cfif HeaderShow eq 0>
                                <cfset HeaderShow = 1>
                                <TR valign="top">
                                    <TD colspan="100%" class="itemHeading">#application.returned_customer_setting.operator_label_singular#</TD>
                                </TR>
                            </cfif>
                            <TR valign="top">
                                <TD>&nbsp;</TD>
                                <TD>
                                <cfif serialNum EQ 1>#Parent_Name#<cfelse>#Child_Name#                                        
                                </cfif>&nbsp;
                                </TD>
                                <TD>
                                    <cfif serialNum EQ 1>#Child_Name#<cfelse>#Parent_Name#                                            
                                    </cfif>&nbsp;
                                </TD>
                                <TD>
                                    <cfset iCount = 0>
                                    <cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
                                        <cfset iCount = displayChange("Deleted", iCount, 0) />
                                    </cfif>
                                    <cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
                                        <cfset iCount = displayChange("Added", iCount, 1) />
                                    </cfif>
                                    <cfif Change>
                                        <cfset iCount = displayChange("Changed", iCount, 2) />
                                    </cfif>&nbsp;
                                </TD>
                            </TR>
                        </cfif>
                    </cfloop>
                </cfloop>            
            </cfif>
    
            <!------ If Distributor is in template ----->
            <cfif Specify_Distributors>
                <!------ Get Distributor info ----->
                <cfset qGetDistributor1 = qGetChangeLog.getDistributorsRemoved(Child_Contract_Main_ID, Parent_Contract_Main_ID, 0) />
                <cfset qGetDistributor2 = qGetChangeLog.getDistributorsRemoved(Parent_Contract_Main_ID, Child_Contract_Main_ID, 1) />
                <cfset HeaderShow = 0>

                <cfloop from="1" to="2" index="serialNum">
                    <cfset qGetDistributor = Evaluate("qGetDistributor#serialNum#")>
                    <cfloop query="qGetDistributor">
                        <cfif ((serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added) OR (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)
                            OR Change)>
                
                            <cfif HeaderShow eq 0>
                                <cfset HeaderShow = 1>
                                <TR valign="top">
                                    <TD colspan="100%" class="itemHeading">#application.returned_customer_setting.distributor_label_singular#</TD>
                                </TR>
                            </cfif>
        
                            <TR valign="top">
                                <TD>&nbsp;</TD>
                                <TD>
                                    <cfif serialNum EQ 1>
                                        <cfif Parent_ID NEQ "">#Parent_Name# (#Parent_Weight#%)

                                        </cfif>
                                    <cfelse>
                                        <cfif Child_ID NEQ "">#Child_Name# (#Child_Weight#%)
                                        </cfif>
                                    </cfif>&nbsp;
                                </TD>
                                <TD>
                                    <cfif serialNum EQ 1>
                                        <cfif Child_ID NEQ "">#Child_Name# (#Child_Weight#%)
                                        </cfif>
                                    <cfelse>
                                        <cfif Parent_ID NEQ "">#Parent_Name# (#Parent_Weight#%)
                                        </cfif>
                                    </cfif>&nbsp;
                                </TD>
                                <TD>
                                    <cfset iCount = 0>
                                    <cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
                                        <cfset iCount = displayChange("Deleted", iCount, 0) />
                                    </cfif>
                                    <cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
                                        <cfset iCount = displayChange("Added", iCount, 1) />
                                    </cfif>
                                    <cfif Change>
                                        <cfset iCount = displayChange("Weight Changed", iCount, 2) />
                                    </cfif>&nbsp;
                                </TD>
                            </TR>
                        </cfif>
                    </cfloop>
                </cfloop>
            </cfif>

            <!------ If Specify_Brokers is in template ----->
            <cfif Specify_Brokers>
    
                <!------ Get Broker info ----->		
                <cfset qGetBroker1 = qGetChangeLog.getBrokersRemoved(Child_Contract_Main_ID, Parent_Contract_Main_ID, 0) />
                <cfset qGetBroker2 = qGetChangeLog.getBrokersRemoved(Parent_Contract_Main_ID, Child_Contract_Main_ID, 1) />
                <cfset HeaderShow = 0>

                <cfloop from="1" to="2" index="serialNum">
                    <cfset qGetBroker = Evaluate("qGetBroker#serialNum#")>
                    <cfloop query="qGetBroker">
                        <cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added) OR (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)
                            OR Change>
                            <cfif HeaderShow eq 0>
                                <cfset HeaderShow = 1>
                                <TR valign="top">
                                    <TD colspan="100%" class="itemHeading">#application.returned_customer_setting.broker_label_singular#</TD>
                                </TR>
                            </cfif>
                            <TR valign="top">
                                <TD>&nbsp;</TD>
                                <TD>
                                <cfif serialNum EQ 1>#Parent_Name#<cfelse>#Child_Name#</cfif>
                                &nbsp;</TD>
                                <TD>
                                <cfif serialNum EQ 1>#Child_Name#<cfelse>#Parent_Name#</cfif>
                                &nbsp;</TD>
                                <TD>
                                    <cfset iCount = 0>
                                    <cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
                                        <cfset iCount = displayChange("Deleted", iCount, 0) />
                                    </cfif>
                                    <cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
                                        <cfset iCount = displayChange("Added", iCount, 1) />
                                    </cfif>
                                    <cfif Change>
                                        <cfset iCount = displayChange("Changed", iCount, 2) />
                                    </cfif>&nbsp;
                                </TD>
                            </TR>
                        </cfif>
                    </cfloop>
                </cfloop>
            </cfif>

            <!------ Fixed Price ----->
            <cfif Discount_Fixed_Prices>
        
                <!------ Get Fixed info ----->
                <cfset qGetFixed = qGetChangeLog.getFixedRemoved(Child_Contract_Main_ID, Parent_Contract_Main_ID) />
                <cfset List_Program_Fixed_Component_Name ="">

                <cfloop query="qGetFixed">
                    <cfif Deleted OR Added OR Change>
                        <cfif ListFind(List_Program_Fixed_Component_Name,Program_Fixed_Component_Name) eq 0>
                            <cfset List_Program_Fixed_Component_Name = ListAppend(List_Program_Fixed_Component_Name,Program_Fixed_Component_Name)>
                            <cfif ListLen(List_Program_Fixed_Component_Name) eq 1>
                                <TR valign="top">
                                    <TD colspan="100%" class="itemHeading">Fixed Price</TD>
                                </TR>
                            </cfif>
                                        
                            <TR valign="top">
                                <TD colspan="100%" class="itemHeading">#Program_Fixed_Component_Name#</TD>
                            </TR>
                        </cfif>
        
                        <TR valign="top">
                            <TD>&nbsp;</TD>
                            <TD>
                                <cfif Deleted>
                                    <cfif First_ID NEQ "">#First_Item_ID# #First_Name# (#First_Price# #First_UOM#)<cfelse>&nbsp;</cfif>
                                <cfelse>
                                    <cfif Second_ID NEQ "">#Second_Item_ID# #Second_Name# (#Second_Price# #Second_UOM#)<cfelse>&nbsp;</cfif>
                                </cfif>
                            </TD>
                            <TD>
                                <cfif Added OR Change>
                                <cfif First_ID NEQ "">#First_Item_ID# #First_Name# (#First_Price# #First_UOM#)<cfelse>&nbsp;</cfif>			
                                <cfelse>
                                    <cfif Second_ID NEQ "">#Second_Item_ID# #Second_Name# (#Second_Price# #Second_UOM#)<cfelse>&nbsp;</cfif>
                                </cfif>	
                            </TD>
            
                            <TD>
                            <cfset iCount = 0>
                            <cfif Deleted>
                                <cfset iCount = displayChange("Deleted", iCount, 0) />
                            </cfif>
                            <cfif Added>
                                <cfset iCount = displayChange("Added", iCount, 1) />
                            </cfif>
                            <cfif Change>
                                <cfset iCount = displayChange("Rate Changed", iCount, 2) />
                            </cfif>&nbsp;
                            </TD>
                        </TR>
                    </cfif>
                </cfloop>
            </cfif>
    
    
            <!------ Rebate ----->
            <cfif Discount_Rebates>
        
                <!------ Get pricing Levels ----->
                <cfset qGetPricingLevels = qGetChangeLog.getPricingLevels(Child_Contract_Main_ID, Parent_Contract_Main_ID) />
                <cfset Val_Child_Contract_Main_ID = Child_Contract_Main_ID>
                <cfset Val_Parent_Contract_Main_ID = Parent_Contract_Main_ID>
                <cfset ListShowHeading = "">
        
                <cfloop query="qGetPricingLevels">
                    <cfset Is_Group = qGetPricingLevels.Is_Group>
                    <cfset PricingLevelLabel = qGetPricingLevels.Pricing_Level_Label>

                    <cfset qGetRebate1 = qGetChangeLog.getRebateRemoved(Val_Child_Contract_Main_ID, Val_Parent_Contract_Main_ID, 0, Pricing_Level_ID) />
                    <cfset qGetRebate2 = qGetChangeLog.getRebateRemoved(Val_Parent_Contract_Main_ID, Val_Child_Contract_Main_ID, 1, Pricing_Level_ID) />

                    <cfloop from="1" to="2" index="serialNum">
                        <cfset Serial_Num = serialNum>
                        <cfset qGetRebate = Evaluate("qGetRebate#serialNum#")>
                        <cfloop query="qGetRebate">
                
                            <cfset rateArray1 = ArrayNew(1)>
                            <cfset rateArray2 = ArrayNew(1)>
                            <cfif serial_Num EQ 1>
                                <cfif Second_ID NEQ "">
                                    <cfset rateArray1 = ReturnRate(Second_Item_ID, Second_Name, Second_Rebate_ID)>
                                </cfif>
                            <cfelse>
                                <cfif First_ID NEQ "">
                                    <cfset rateArray1 = ReturnRate(First_Item_ID, First_Name, First_Rebate_ID)>						
                                </cfif>
                            </cfif>

                            <cfif serial_Num EQ 1>
                                <cfif First_ID NEQ "">
                                    <cfset rateArray2 = ReturnRate(First_Item_ID, First_Name, First_Rebate_ID)>						
                                </cfif>
                            <cfelse>
                                <cfif Second_ID NEQ "">
                                    <cfset rateArray2 = ReturnRate(Second_Item_ID, Second_Name, Second_Rebate_ID)>
                                </cfif>
                            </cfif>

                            <!------ show rates ----->										
        
                            <cfset RateChanged = checkRateDifference(First_Rebate_ID, Second_Rebate_ID,rateArray1, rateArray2)>
                            <cfset ComponentName = getComponent(rateArray1, rateArray2)>

                            <cfif ListFind(ListShowHeading,Is_Group) eq 0>					
                                <cfif ((serial_Num EQ 1 AND Deleted) OR (serial_Num EQ 2 AND Added)) OR ((serial_Num EQ 1 AND Added) OR (serial_Num EQ 2 AND Deleted))
                                        OR ((Change OR RateChanged) AND NOT Added AND NOT Deleted)>														
                                    <cfset ListShowHeading = ListAppend(ListShowHeading,Is_Group)>
                                    <TR valign="top">
                                        <TD colspan="100%" class="itemHeading"><cfif ProgramGenericType eq "Bid Request">Proposal&nbsp;</cfif>#Application.RebateLabel#
                                            <cfif qGetPricingLevels.recordCount GT 0>
                                                - #PricingLevelLabel#<!------ Pricing_Level_ID ----->
                                            </cfif>
                                        </TD>
                                    </TR>
                                    <TR valign="top">
                                        <TD colspan="100%" class="itemHeading">
                                        <cfif Is_Group eq 1>Groups<cfelse>Items</cfif>
                                        </TD>
                                    </TR>
                                </cfif>
                            </cfif>					

                            <TR valign="top">
                                <cfif (First_ID NEQ Second_ID) OR Change OR RateChanged>
                                    <TD>&nbsp;</TD>
                                    <TD>
                                        <cfif serial_Num EQ 1>
                                            <cfif Second_ID NEQ "">
                                                #DisplayProduct(Second_Item_ID, Second_Name)#
                                                #DisplayRebate(First_Rebate_ID, Second_Rebate_ID, rateArray1, rateArray2,2)#
                                            </cfif>
                                        <cfelse>
                                            <cfif First_ID NEQ "">
                                                #DisplayProduct(First_Item_ID, First_Name)#
                                                #DisplayRebate(First_Rebate_ID, Second_Rebate_ID, rateArray1, rateArray2,1)#						
                                            </cfif>
                                        </cfif>
                                        &nbsp;
                                    </TD>
                            
                                    <TD>
                                        <cfif serial_Num EQ 1>
                                            <cfif First_ID NEQ "">
                                                #DisplayProduct(First_Item_ID, First_Name)#
                                                #DisplayRebate(First_Rebate_ID, Second_Rebate_ID, rateArray1, rateArray2,1)#
                                            </cfif>
                                        <cfelse>
                                            <cfif Second_ID NEQ "">
                                                #DisplayProduct(Second_Item_ID, Second_Name)#
                                                #DisplayRebate(First_Rebate_ID, Second_Rebate_ID, rateArray1, rateArray2,2)#
                                            </cfif>
                                        </cfif>
                                        &nbsp;
                                    </TD>
                                </cfif>			

                                <cfset iCount = 0>
                                <cfif (serial_Num EQ 1 AND Deleted) OR (serial_Num EQ 2 AND Added)>
                                    <TD>
                                        <cfset iCount = displayChange("Deleted", iCount, 0) />
                                    &nbsp;</TD>
                                </cfif>
                                <cfif (serial_Num EQ 1 AND Added) OR (serial_Num EQ 2 AND Deleted)>
                                    <TD>
                                        <cfset iCount = displayChange("Added", iCount, 1) />
                                    &nbsp;</TD>
                                </cfif>
                                <cfif (Change OR RateChanged) AND NOT Added AND NOT Deleted>
                                    <TD>						
                                        <cfset iCount = displayChange("Rate Changed", iCount, 2) />
                                    &nbsp;</TD>
                                </cfif>
                            </TR>
                        </cfloop>
                    </cfloop>
                </cfloop>
            </cfif>
    

            <!------ Lump sum  ----->
            <cfif Discount_Lump_Sums>
                    
                <!------ Get lumpsum Info ----->		
                <cfset qGetAllLumpSumNames = qGetChangeLog.getAllLumpSumNames(Child_Contract_Main_ID, Parent_Contract_Main_ID) />

                <cfset Val_Child_Contract_Main_ID = Child_Contract_Main_ID>
                <cfset Val_Parent_Contract_Main_ID = Parent_Contract_Main_ID>
                
                <cfloop query="qGetAllLumpSumNames">
                    <cfset qGetThisLumpSum1 = qGetChangeLog.getThisLumpSum(Val_Child_Contract_Main_ID, Program_Lump_Sum_Name_ID) />
                    <cfset qGetThisLumpSum2 = qGetChangeLog.getThisLumpSum(Val_Parent_Contract_Main_ID, Program_Lump_Sum_Name_ID) />
                    <cfset Parent_LumpSum_Payment_Cycle = paymentCycleManager.getPaymentCycle(Val_Parent_Contract_Main_ID,3,val(qGetThisLumpSum2.Program_Lumps_Sum_Ext_ID))>
                    <cfset Child_LumpSum_Payment_Cycle = paymentCycleManager.getPaymentCycle(Val_Child_Contract_Main_ID,3,val(qGetThisLumpSum1.Program_Lumps_Sum_Ext_ID))>
                    <cfset Parent_LumpSum_Payment_Cycle_Desc = paymentCycleManager.getPaymentCycleDescription(Parent_LumpSum_Payment_Cycle)>
                    <cfset Child_LumpSum_Payment_Cycle_Desc =  paymentCycleManager.getPaymentCycleDescription(Child_LumpSum_Payment_Cycle)>
                    <cfset displayLumpSum(qGetThisLumpSum1, qGetThisLumpSum2, Parent_LumpSum_Payment_Cycle_Desc, Child_LumpSum_Payment_Cycle_Desc) />			
                </cfloop>
            </cfif>

            <!------ Growth ----->
            <cfif Discount_Growth>
    
                <!------ Get Growth Info ----->	
                <cfset ComponentList = "">
                <cfset qGetAllGrowthProducts1 = qGetChangeLog.getAllGrowthProducts(Child_Contract_Main_ID, Parent_Contract_Main_ID, 0) />
                <cfset qGetAllGrowthProducts2 = qGetChangeLog.getAllGrowthProducts(Parent_Contract_Main_ID, Child_Contract_Main_ID, 1) />

                <cfset Val_Child_Contract_Main_ID = Child_Contract_Main_ID>
                <cfset Val_Parent_Contract_Main_ID = Parent_Contract_Main_ID>
                <cfset HeaderShow = 0>
                <cfset GrouporItem = ""> 

                <cfloop from="1" to="2" index="serialNum">
        
                    <cfset qGetAllGrowthProducts = Evaluate("qGetAllGrowthProducts#serialNum#")>

                    <cfloop query="qGetAllGrowthProducts">
            
                        <cfset qGetGrowthProductRates1 = qGetChangeLog.getGrowthProductRates(BSA_Foodservice_Items_Master_ID, First_Program_ID) />
                        <cfset qGetGrowthProductRates2 = qGetChangeLog.getGrowthProductRates(BSA_Foodservice_Items_Master_ID, Second_Program_ID) />
                        <cfset changeArray = ArrayNew(1)>
                        <cfset ArrayAppend(changeArray, 0)>
                        <cfset ArrayAppend(changeArray, 0)>
            
                        <cfif serialNum EQ 1>
                            <cfset qGetProductRates1 = Evaluate("qGetGrowthProductRates2")>
                            <cfset qGetProductRates2 = Evaluate("qGetGrowthProductRates1")>
                        <cfelse>		
                            <cfset qGetProductRates1 = Evaluate("qGetGrowthProductRates1")>
                            <cfset qGetProductRates2 = Evaluate("qGetGrowthProductRates2")>
                        </cfif>
            
                        <cfset useLoop = 2>
                        <cfif qGetProductRates1.recordCount GT qGetProductRates2.recordCount>
                            <cfset useLoop = 1>
                        </cfif>
            
                        <cfloop query="qGetProductRates1">
                                <cfif useLoop EQ 1>
                                    <cfset changeArray = checkGrowthDifference(qGetProductRates2, qGetProductRates1, currentRow, changeArray) />
                                </cfif>						
                        </cfloop>
                        <cfloop query="qGetProductRates2">
                                <cfif useLoop EQ 2>
                                    <cfset changeArray = checkGrowthDifference(qGetProductRates1, qGetProductRates2, currentRow, changeArray) />
                                </cfif>
                        </cfloop>
                
                        <cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added) OR (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)
                            OR changeArray[1] OR changeArray[2]>
                            <cfif HeaderShow eq 0>
                                <cfset HeaderShow = 1>				
                                <TR valign="top">
                                    <TD colspan="100%" class="itemHeading">Growth</TD>
                                </TR>
                            </cfif>

                            <cfif ListFind(ComponentList,Component_Name) eq 0>
                                <cfset ComponentList = ListAppend(ComponentList,Component_Name)>
                                <TR valign="top">
                                    <TD colspan="100%" class="itemHeading">#Component_Name#</TD>
                                </TR>
                            </cfif>
                                            
                            <cfif GrouporItem neq Is_Group>
                                <cfset GrouporItem = Is_Group>
                                <TR valign="top">
                                    <TD colspan="100%" class="itemHeading">#Is_Group#</TD>
                                </TR>
                            </cfif>
                                    
                            <TR valign="top">
                                <TD>&nbsp;</TD>
                                <TD>
                                    <cfif serialNum EQ 1>
                                        <cfif Second_ID NEQ "">#Second_Item_ID# #Second_Name#</cfif>
                                    <cfelse>
                                        <cfif First_ID NEQ "">#First_Item_ID# #First_Name#</cfif>
                                    </cfif>
                                    &nbsp;
                                </TD>
                                <TD>
                                    <cfif serialNum EQ 1>
                                        <cfif First_ID NEQ "">#First_Item_ID# #First_Name#</cfif>
                                    <cfelse>
                                        <cfif Second_ID NEQ "">#Second_Item_ID# #Second_Name#</cfif>
                                    </cfif>
                                    &nbsp;
                                </TD>
                                <TD>
                                    <cfset iCount = 0>					
                                    <cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
                                        <cfset iCount = displayChange("Deleted", iCount, 0) />
                                    </cfif>
                                    <cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
                                        <cfset iCount = displayChange("Added", iCount, 1) />
                                    </cfif>
                                    &nbsp;
                                </TD>
                            </TR>
        
                            <cfif changeArray[1] OR changeArray[2]>
                                <TR valign="top">
                                    <TD>&nbsp;</TD>
                
                                    <TD>
                                        <table class="ChangeLogNoBorder" border="0" cellpadding="2" cellspacing="0">
                                            <cfloop query="qGetProductRates1">
                                                <cfif (NOT (changeArray[1]) AND(qGetProductRates1.Tier_Number[currentrow] eq qGetProductRates2.Tier_Number[currentrow]) AND (qGetProductRates1.First_Rate[currentrow] neq qGetProductRates2.First_Rate[currentrow] OR qGetProductRates1.First_UOM[currentrow] neq qGetProductRates2.First_UOM[currentrow])) OR changeArray[1]>
                                                    <tr>
                                                        <td align="right">#Range_Start#</td>
                                                        <td> - </td>
                                                        <td align="right">#Range_End#</td>
                                                        <td>(#First_Rate# #First_UOM#)</td>
                                                    </tr>								
                                                </cfif>														
                                            </cfloop>							
                                        </table>
                                    </TD>
                    
                                    <TD>
                                        <table class="ChangeLogNoBorder" border="0" cellpadding="2" cellspacing="0">
                                            <cfloop query="qGetProductRates2">
                                                <cfif (NOT (changeArray[1]) AND (qGetProductRates1.Tier_Number[currentrow] eq qGetProductRates2.Tier_Number[currentrow]) AND (qGetProductRates1.First_Rate[currentrow] neq qGetProductRates2.First_Rate[currentrow] OR qGetProductRates1.First_UOM[currentrow] neq qGetProductRates2.First_UOM[currentrow]))  OR changeArray[1]>							
                                                    <tr>
                                                        <td align="right">#Range_Start#</td>
                                                        <td> - </td>
                                                        <td align="right">#Range_End#</td>
                                                        <td>(#First_Rate# #First_UOM#)</td>
                                                    </tr>								
                                                </cfif>							
                                            </cfloop>
                                        </table>
                                    </TD>
                    
                                    <TD>				
                                        <cfset iCount = 0>
                                        <cfif changeArray[1]>
                                            <cfset iCount = displayChange("Targets Changed", iCount, 2)>
                                        </cfif>
                                        <cfif changeArray[2]>
                                            <cfset iCount = displayChange("Rate Changed", iCount, 2)>
                                        </cfif>
                                        &nbsp;
                                    </TD>
                                </TR>
                            </cfif>
                        </cfif>
                    </cfloop>
                </cfloop>
            </cfif>
        
            <!--- Off-Invoice --->
            <cfif ProgramGenericType EQ "Distributor Off-Invoice">
                <cfset qGetOffInvoice = qGetChangeLog.getOffInvoiceRemoved(Child_Contract_Main_ID, Parent_Contract_Main_ID) />
                <cfset HeaderShow = 0>
                <cfset GrouporItem = ""> 

                <cfloop query="qGetOffInvoice">
                    <cfif Deleted OR Added OR Change>
                        <cfif HeaderShow eq 0>	
                            <cfset HeaderShow = 1>	
                            <TR valign="top">
                                <TD colspan="100%" class="itemHeading">Off Invoice</TD>
                            </TR>
                        </cfif>
        
                        <cfif GrouporItem neq Is_Group>
                            <cfset GrouporItem = Is_Group>
                            <TR valign="top">
                                <TD colspan="100%" class="itemHeading">#Is_Group#</TD>
                            </TR>
                        </cfif>
            
                        <TR valign="top">
                            <TD>&nbsp;</TD>
                            <TD>
                                <cfif serialNum EQ 1>
                                    <cfif Second_ID NEQ "">#Second_Name# (#NumberFormat(Second_Rate,viewProgramManager.getRateFormatMask(0))# #Second_UOM#)
                                    </cfif>
                                <cfelse>
                                    <cfif First_ID NEQ "">#First_Name# (#NumberFormat(First_Rate,viewProgramManager.getRateFormatMask(0))# #First_UOM#)
                                    </cfif>
                                </cfif>
                                &nbsp;
                            </TD>
                            <TD>
                                <cfif serialNum EQ 1>
                                    <cfif First_ID NEQ "">#First_Name# (#NumberFormat(First_Rate,viewProgramManager.getRateFormatMask(0))# #First_UOM#)
                                    </cfif>
                                <cfelse>
                                    <cfif Second_ID NEQ "">#Second_Name# (#NumberFormat(Second_Rate,viewProgramManager.getRateFormatMask(0))# #Second_UOM#)
                                    </cfif>
                                </cfif>
                                &nbsp;
                            </TD>
                            <TD>
                                <cfset iCount = 0>
                                <cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
                                    <cfset iCount = displayChange("Deleted", iCount, 0) />
                                </cfif>
                                <cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
                                    <cfset iCount = displayChange("Added", iCount, 1) />
                                </cfif>
                                <cfif Change>
                                    <cfset iCount = displayChange("Rate Changed", iCount, 2) />
                                </cfif>
                                &nbsp;
                            </TD>
                        </TR>
                    </cfif>
                </cfloop>
            </cfif>		

            <!--- Dev Note: Milan - 11370; Bid Request - For Bid request, we have proposal rebate and fixed price. The proposal rebate details come from the
                        rebate tables (The rebate section of this page takes care of that) and the fixed price details come from 
                        the bid request table --->
            <cfif ProgramGenericType EQ "Bid Request">
                <cfset qGetBidRequest = qGetChangeLog.getBidRequestRemoved(Child_Contract_Main_ID, Parent_Contract_Main_ID) />
                <cfset HeaderShow = 0>
                <cfset GrouporItem = ""> 

                <cfloop query="qGetBidRequest">
                    <cfif Deleted OR Added OR Change>
                        <cfif HeaderShow eq 0>	
                            <cfset HeaderShow = 1>	
                            <TR valign="top">
                                <TD colspan="100%" class="itemHeading">Fixed Price</TD>
                            </TR>
                        </cfif>
            
                        <cfif GrouporItem neq Is_Group>
                            <cfset GrouporItem = Is_Group>
                            <TR valign="top">
                                <TD colspan="100%" class="itemHeading">#Is_Group#</TD>
                            </TR>
                        </cfif>
                
                        <TR valign="top">
                            <TD>&nbsp;</TD>
                            <TD>
                            <cfif serialNum EQ 1>
                                <cfif Second_ID NEQ "">#Second_Name# (#Second_Rate# #Second_UOM#)</cfif>
                            <cfelse>
                                <cfif First_ID NEQ "">#First_Name# (#First_Rate# #First_UOM#)</cfif>
                            </cfif>
                            &nbsp;</TD>
                            <TD>
                            <cfif serialNum EQ 1>
                                <cfif First_ID NEQ "">#First_Name# (#First_Rate# #First_UOM#)</cfif>
                            <cfelse>
                                <cfif Second_ID NEQ "">#Second_Name# (#Second_Rate# #Second_UOM#)</cfif>
                            </cfif>
                            &nbsp;</TD>
                            <TD>
                                <cfset iCount = 0>
                                <cfif (serialNum EQ 1 AND Deleted) OR (serialNum EQ 2 AND Added)>
                                    <cfset iCount = displayChange("Deleted", iCount, 0) />
                                </cfif>
                                <cfif (serialNum EQ 1 AND Added) OR (serialNum EQ 2 AND Deleted)>
                                    <cfset iCount = displayChange("Added", iCount, 1) />
                                </cfif>
                                <cfif Change>
                                    <cfset iCount = displayChange("Rate Changed", iCount, 2) />
                                </cfif>&nbsp;
                            </TD>
                        </TR>
                    </cfif>
                </cfloop>
            </cfif>			
        </TABLE>
        </cfoutput>
        </body>
        </html>
    </cfsavecontent>

    <cftransaction>
        <!--- If the history already exists for that Program, delete the history and enter a new one --->
        <cfset qGetChangeLog.addProgramHistory(
                programId = qGetChangedPrograms.Child_Contract_Main_ID, 
                contractNumber = qGetChangedPrograms.Child_Contract_Number,
                content = programChangeReport,
                historyAction = 100,
                deletePreviousEntry = 1) />

        <!--- Set the "Run_Program_History" to 1 (Has Run)--->
        <cfquery name="UpdateContract" datasource="#application.datasource#">
            UPDATE 	Contract_Main_Aux_Data
            SET 	Run_Program_History = 1
            WHERE 	Contract_Main_ID ='#qGetChangedPrograms.Child_Contract_Main_ID#'
        </cfquery>        
    </cftransaction>
</cffunction>
