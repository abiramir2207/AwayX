
This updates all non-0 components with the non-0 program claim mechanism for when D6300 is run.

WHEN _Application_Settings.Claims_at_Comp_Level goes from 0 to 1, this should be run

<cfquery name="UpdatePriorValues" datasource="#application.datasource#">
--Update lump sums
UPDATE		Program_Lump_Sums
SET			Claim_Mechanics = Contract_Main.ClaimMechanics
FROM		Program_Lump_Sums
	inner join Contract_Main
	on         Contract_Main.Contract_Main_ID = Program_Lump_Sums.Program_ID
	and       Contract_Main.ClaimMechanics is not null
WHERE Program_Lump_Sums.Claim_Mechanics = 0 OR Program_Lump_Sums.Claim_Mechanics IS Null

--Update fixed
UPDATE Program_Fixed_Component
SET			Claim_Mechanics = Contract_Main.ClaimMechanics
FROM		Program_Fixed_Component
	inner join Contract_Main
	on         Contract_Main.Contract_Main_ID = Program_Fixed_Component.Program_ID
	and       Contract_Main.ClaimMechanics is not null
WHERE Program_Fixed_Component.Claim_Mechanics = 0 OR Program_Fixed_Component.Claim_Mechanics IS Null

--Update rebate
UPDATE Program_Rebates_Component
SET			Claim_Mechanics = Contract_Main.ClaimMechanics
FROM		Program_Rebates_Component
	inner join Contract_Main
	on         Contract_Main.Contract_Main_ID = Program_Rebates_Component.Program_ID
	and       Contract_Main.ClaimMechanics is not null
WHERE Program_Rebates_Component.Claim_Mechanics = 0 OR Program_Rebates_Component.Claim_Mechanics IS Null

--Update growth
UPDATE Program_Growth_Components
SET			Claim_Mechanics = Contract_Main.ClaimMechanics
FROM		Program_Growth_Components
	inner join Contract_Main
	on         Contract_Main.Contract_Main_ID = Program_Growth_Components.Program_ID
	and       Contract_Main.ClaimMechanics is not null
WHERE Program_Growth_Components.Claim_Mechanics = 0 OR Program_Growth_Components.Claim_Mechanics IS Null

--Update BidRequest
UPDATE	Program_BidRequest_Component
SET		Program_BidRequest_Component.Claim_Mechanics = Contract_Main.ClaimMechanics
FROM	Program_BidRequest_Component
		INNER JOIN Contract_Main ON
		Contract_Main.Contract_Main_ID = Program_BidRequest_Component.Program_ID AND
		Contract_Main.ClaimMechanics IS NOT NULL
WHERE	Program_BidRequest_Component.Claim_Mechanics = 0 
OR		Program_BidRequest_Component.Claim_Mechanics IS NULL
</cfquery>
<p>
Done. You may close this window now.
</p>