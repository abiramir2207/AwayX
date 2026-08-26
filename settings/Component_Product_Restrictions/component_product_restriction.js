function getRestrictedProducts(DiscountTypeID,ComponentID)
{
	NewWindow("/settings/component_product_restrictions/select_restrictions.cfm?Discount_Type_ID=" + DiscountTypeID + "&Component_ID=" + ComponentID, "ComponentRestrictions", "600", "400", "yes", "yes", "yes","no")
}

function checkAll()
{
for (i = 0; i < document.SelectRestrictions.CriteriaID.length; i++)
	document.SelectRestrictions.CriteriaID[i].checked = true;
}

function uncheckAll()
{
for (i = 0; i < document.SelectRestrictions.CriteriaID.length; i++)
	document.SelectRestrictions.CriteriaID[i].checked = false;
}
