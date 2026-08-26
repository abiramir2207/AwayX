
function deactivateSelPerfTypes()
{
	var actionFrm = document.frmPlannerPerfTypes;
	if(!Any_Object_Checked(actionFrm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to deactivate the selected Performance Type(s)?"))
	{
		actionFrm.command.value = 'deactSel';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}

	return false;
}

function activateSelPerfTypes()
{
	var actionFrm = document.frmPlannerPerfTypes;
	if(!Any_Object_Checked(actionFrm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to activate the selected Performance Type(s)?"))
	{

		actionFrm.command.value = 'actSel';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}

	return false;
}

	function submitPerfForm(selAction) {
		if (selAction == 'save')
		{
			document.frmPlannerPerfTypes.command.value = 'Save';
		}
		else if (selAction == 'add')
		{
			document.frmPlannerPerfTypes.command.value = 'Add';
		}
		else if (selAction == 'edit')
		{
			document.frmPlannerPerfTypes.command.value = 'Edit';
		}

		/* Check if the sortOrder fields exist whic is for the active tab save */
		if (document.getElementById("sortOrders") != null) {
			var seq = 0;
			/* assign new sequence to hidden sorting field on each row */
			jQuery("table.MAINTABLE tr").each(function(){
				if (jQuery(this).attr("id") !== "HEADER") {
					seq = seq + 1;
					jQuery(this).find("input.order").val( seq );
				}
			});
		}

		document.frmPlannerPerfTypes.display.value = 'Active';
		document.frmPlannerPerfTypes.submit();
	}