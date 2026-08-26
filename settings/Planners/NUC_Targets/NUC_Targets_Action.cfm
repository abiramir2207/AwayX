<!----------------------------------------------------------------------------------
Name         :	NUC_Targets_Action.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/09/2016
Created By   : 	Anand Rao
Description  : 	Page to create NUC Targets
---------------------------------------------------------------------------------->

<cfloop collection="#form#" item="element">
	<cfif element contains "guid_" and form[ element ] neq "">
		<cfscript>
			row_class     = listGetAt(element, 2, "_");
			row_guid      = form[ element ];
			promoted_nuc  = val(form[ "promoted_nuc_"  & row_class ]);
			promoted_uom  = val(form[ "promoted_uom_"  & row_class ]);
			blended_nuc   = val(form[ "blended_nuc_"   & row_class ]);
			blended_uom   = val(form[ "blended_uom_"   & row_class ]);
			case_count    = val(form[ "case_count_"    & row_class ]);
			target_margin = val(form[ "target_margin_" & row_class ]);
		</cfscript>

		<cfquery name="qUpdate" datasource="#application.datasource#" result="qResult">
			UPDATE NUC_Targets
				SET
					Promoted_NUC		= #promoted_nuc#,
					Promoted_NUC_UOM	= #promoted_uom#,
					Blended_NUC			= #blended_nuc#,
					Blended_NUC_UOM		= #blended_uom#,
					Case_Count          = #case_count#,
					Target_Margin       = #target_margin#,
					Updated_Date		= GetDate(),
					Updated_By			= '#request.accessStructure.User_Id#'
				WHERE
					Product_Group_ID = '#row_guid#' AND
					Deleted = 0
		</cfquery>

		<cfif qResult.recordCount eq 0>
			<cfquery name="qInsert" datasource="#application.datasource#">
				INSERT  INTO NUC_Targets (
					Product_Group_ID,
					Promoted_NUC,
					Promoted_NUC_UOM,
					Blended_NUC,
					Blended_NUC_UOM,
					Case_Count,
					Target_Margin,
					Created_Date,
					Created_By
				)
			    VALUES
				(
					'#row_guid#',
					#promoted_nuc#,
					#promoted_uom#,
					#blended_nuc#,
					#blended_uom#,
					#case_count#,
					#target_margin#,
					GetDate(),
					'#request.accessStructure.User_Id#'
				)
			</cfquery>
		</cfif>
	</cfif>
</cfloop>
