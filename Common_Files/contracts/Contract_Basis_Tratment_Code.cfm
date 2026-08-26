<!------ 
Contract_Basis_Tratment_Code.cfm 
Arguments: 	CSLGetContractInfo
			qComponentNames
----->

<!------ Initialise components ----->
<cfset AllowanceCodeManager = CreateObject("component","components.Operating_Group.AllowanceCodeManager").init() />
<cfset BasisCodeManager = CreateObject("component","components.Operating_Group.BasisCodeManager").init() />
<cfset TreatmentCodeManager = CreateObject("component","components.Operating_Group.TreatmentCodeManager").init() />
<cfset BasisTreatmentCodeXRefManager = CreateObject("component","components.Operating_Group.BasisTreatmentCodeXRefManager").init() />
<cfset AccountingProgramTypeManager = CreateObject("component","components.programs.Accounting_Program_Type.AccountingProgramTypeManager").init() />

<cfset Current_Accounting_Program_Type_ID = 0 />
<cfif IsNumeric(CSLGetContractInfo.Accounting_Program_Type_ID)>
	<cfset Current_Accounting_Program_Type_ID = CSLGetContractInfo.Accounting_Program_Type_ID />
</cfif>
<cfset qGetAllowanceCodes = AllowanceCodeManager.getAllowanceCodes() />
<cfset qGetBasisCodes = BasisCodeManager.getBasisCodes() />
<cfset GetAPT = AccountingProgramTypeManager.getAccountingProgramTypes(Current_Accounting_Program_Type_ID) />
<cfset qGetTreatmentCodes = TreatmentCodeManager.getTreatmentCodes(type=GetAPT.APT_Reference_Number) />
<cfset qGetBasisTreatmentCodeXRef = BasisTreatmentCodeXRefManager.getBasisTreatmentCodeXRef() />


<script language="JavaScript">

function ComponentName(componentId, allowanceCodeId, defaultBasisCodeID, defaultTreatmentCodeID)
{
	this.componentId 			= componentId;
	this.allowanceCodeId 		= allowanceCodeId;
	this.defaultBasisCodeID 	= defaultBasisCodeID;
	this.defaultTreatmentCodeID = defaultTreatmentCodeID;
	return this;
}

function BasicCode(basisCodeMasterId, basisCodeName)
{
	this.basisCodeMasterId 			= basisCodeMasterId;
	this.basisCodeName 				= basisCodeName;
	return this;
}

function TreatmentCode(treatmentCodeMasterId, treatmentCodeName)
{
	this.treatmentCodeMasterId 			= treatmentCodeMasterId;
	this.treatmentCodeName 				= treatmentCodeName;
	return this;
}

function BasisTreatmentCodeXRef(basisCodeMasterId, treatmentCodeMasterId)
{
	this.basisCodeMasterId 				= basisCodeMasterId;
	this.treatmentCodeMasterId 			= treatmentCodeMasterId;	
	return this;
}

<!------ dump component information into javascript array ----->
var arComponentNames = new Array();
<cfloop query="qComponentNames">
	<cfset defaultBasisCodeID = 0 />
	<cfset defaultTreatmentCodeID = 0 />
	<cfset allowanceCodeID = 0 />
	<cfif isNumeric(Component_Allowance_Code_ID)>
		<cfset allowanceCodeID = Component_Allowance_Code_ID />
		<cfset useLakebaseForqGetDefaultBasicTreatmentCode = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetallowancecodes")>
<cfif useLakebaseForqGetDefaultBasicTreatmentCode>
	<cftry>
		<cfset qGetDefaultBasicTreatmentCode = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetallowancecodes", {
				"allowance_code_id" = "eq.#Component_Allowance_Code_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDefaultBasicTreatmentCode = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDefaultBasicTreatmentCode>
<cfquery name="qGetDefaultBasicTreatmentCode" dbtype="query">
			SELECT	*
			FROM	qGetAllowanceCodes
			WHERE	Allowance_Code_ID = #Component_Allowance_Code_ID#
		</cfquery>
</cfif>
		<cfif qGetDefaultBasicTreatmentCode.recordCount>
			<cfif isNumeric(qGetDefaultBasicTreatmentCode.Basis_Code_Master_ID)>
				<cfset defaultBasisCodeID = qGetDefaultBasicTreatmentCode.Basis_Code_Master_ID />
			</cfif>
			<cfif isNumeric(qGetDefaultBasicTreatmentCode.Treatment_Code_Master_ID)>
				<cfset defaultTreatmentCodeID = qGetDefaultBasicTreatmentCode.Treatment_Code_Master_ID />
			</cfif>
		</cfif>
	</cfif>
	<cfoutput>arComponentNames[arComponentNames.length] = new ComponentName(#Component_Name_ID#, #allowanceCodeID#, #defaultBasisCodeID#, #defaultTreatmentCodeID#);</cfoutput>	
</cfloop>

<!------ dump basis code information into javascript array ----->
var arBasisCodes = new Array();
<cfloop query="qGetBasisCodes">
	<cfoutput>arBasisCodes[arBasisCodes.length] = new BasicCode(#Basis_Code_Master_ID#, '#Basis_Code_Desc#');</cfoutput>	
</cfloop>

<!------ dump treatment code information into javascript array ----->
var arTreatmentCodes = new Array();
<cfloop query="qGetTreatmentCodes">
	<cfoutput>arTreatmentCodes[arTreatmentCodes.length] = new TreatmentCode(#Treatment_Code_Master_ID#, '#Treatment_Code_Desc#');</cfoutput>	
</cfloop>

<!------ dump basic treatment code XRef information into javascript array ----->
var arBasisTreatmentCodeXRefs = new Array();
<cfloop query="qGetBasisTreatmentCodeXRef">
	<cfoutput>arBasisTreatmentCodeXRefs[arBasisTreatmentCodeXRefs.length] = new BasisTreatmentCodeXRef(#Basis_Code_Master_ID#, #Treatment_Code_Master_ID#);</cfoutput>	
</cfloop>

function checkBasisTreatmentCodeXRef(basisCodeMasterId, treatmentCodeMasterId)
{
	var i, lenArBasisTreatmentCodeXRefs = arBasisTreatmentCodeXRefs.length;
	
	for(i=0;i<lenArBasisTreatmentCodeXRefs;i++)
	{
		if(arBasisTreatmentCodeXRefs[i].basisCodeMasterId == basisCodeMasterId && arBasisTreatmentCodeXRefs[i].treatmentCodeMasterId == treatmentCodeMasterId)
		{
			return true;
		}
	}
	return false;
}

function loadBasisCodes(treatmentCodeId)
{
	var prevSelection = 0;
	var i, objBasisCodeSel = document.all.Basis_Code;
	if(objBasisCodeSel)
	{
		prevSelection = objBasisCodeSel.value;
		var optBasisCodeSel = objBasisCodeSel.options;
		var lenBasisCodeSel = optBasisCodeSel.length;
		for(i=lenBasisCodeSel-1;i>0;i--)
		{
			optBasisCodeSel.remove(i);
		}
		
		var lenArBasisCodes = arBasisCodes.length;
		var oOption;
		
		for(i=0;i<lenArBasisCodes;i++)
		{
			if(!checkBasisTreatmentCodeXRef(arBasisCodes[i].basisCodeMasterId, treatmentCodeId))
			{
				oOption = document.createElement("OPTION");	
				optBasisCodeSel.add(oOption);
				oOption.innerText = arBasisCodes[i].basisCodeName;
				oOption.value = arBasisCodes[i].basisCodeMasterId;
			}
		}
		
		var oOptionToSelect = Get_Object_Property_Match_Collection(optBasisCodeSel, "value", prevSelection);
		if(oOptionToSelect)
		{
			oOptionToSelect.selected = true;
		}
		
	}
}

function loadDefaultBasisTreatmentCodeForComponentName(component_id)
{
	var i, lenArComponentNames = arComponentNames.length;
	var currentComponentName;
	for(i=0;i<lenArComponentNames;i++)
	{
		if(arComponentNames[i].componentId == component_id)
		{
			currentComponentName = arComponentNames[i];
			
			var objSel, oOptionToSelect, prevSelection;
			/* set the default selection for treatment code */
			objSel = document.all.Treatment_Code;
			prevSelection = objSel.value;
			if(objSel)
			{
				oOptionToSelect = Get_Object_Property_Match_Collection(objSel.options, "value", currentComponentName.defaultTreatmentCodeID);
				if(oOptionToSelect)
				{
					if(oOptionToSelect.index != 0 || prevSelection == 0)
					{
						oOptionToSelect.selected = true;
						objSel.fireEvent("onChange");
					}
				}
			}
			/* set the default selection for basis code */
			objSel = document.all.Basis_Code;
			prevSelection = objSel.value;
			if(objSel)
			{
				oOptionToSelect = Get_Object_Property_Match_Collection(objSel.options, "value", currentComponentName.defaultBasisCodeID);
				if(oOptionToSelect)
				{
					if(oOptionToSelect.index != 0 || prevSelection == 0)
					{
						oOptionToSelect.selected = true;
					}
				}
			}
			
		}
	}	
}

</script>