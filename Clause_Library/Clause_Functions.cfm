<!------ Clause_Functions.cfm ----->
<CFSCRIPT>
	function buildFieldName(sStart, bRequired, clauseType, discountType)
	{
		return sStart & "_" & bRequired & "_" & clauseType & "_" & discountType;
	}
	function addToClause(clauseId, clauseType, discountType, bRequired)
	{
		var stClause = StructNew();
		stClause.clauseId = clauseId;
		stClause.clauseType = clauseType;
		stClause.discountType = discountType;
		stClause.bRequired = bRequired;
		return stClause;
	}
</CFSCRIPT>