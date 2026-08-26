<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cf_cryp type="de" string ="#form.programid#" key="#request.key#">
<cfset program_id = cryp.value>
<cfparam name="typecodelistlist" default="">
<cfparam name="productlist" default="">
<cfparam name="form.ignorethisform" default="0"/>

<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo() />

<cfset ProgramManager = CreateObject("component","components.programs.programmanager") />
<cfset objProgram = CreateObject("component", "components.programs.program") />

<cfset getagreedprogramtypecodes = ProgramManager.getagreedtypecodes(programid=Program_ID,User_Profile=request.AccessStructure.Profiles_ID,approval_GroupTablename=approvalGroupType.tablename,approval_GroupIDFIELD=approvalGroupType.IDFIELD)>
<cfquery name="getcurrentuserdetails" datasource="#application.datasource#">
select ISNULL(hq_position_id,0) as hq_position_id,user_positions_id
from _users inner join user_position_holders on
user_position_holders.user_id = _users.user_id
inner join authority_sequence on _users.authority_sequence_id = 
authority_sequence.authority_sequence_id
where _users.user_id =   <cfqueryparam value="#request.AccessStructure.user_id#" cfsqltype="CF_SQL_NVARCHAR">
and user_position_holders.deleted = 0
and user_position_holders.user_position_type = 'P'
</cfquery>
<cfif getagreedprogramtypecodes.recordcount GT 0>
<cfset productlist =  quotedvaluelist(getagreedprogramtypecodes.BSA_Foodservice_Items_Master_Id)>
<cfset typecodelistlist  = quotedvaluelist(getagreedprogramtypecodes.Type_Code_Desc_ID)>

<cfoutput><cfquery name="deleteagreedtypecodes" datasource="#application.datasource#">
	DELETE 
	from 	Program_Type_Code_Approval_Info
	where 	program_id = #program_id# and (<cfif listlen(productlist) GT 0>product_id IN (#preservesinglequotes(productlist)#)<cfelse>0=0</cfif> OR <cfif listlen(typecodelistlist) GT 0> Type_Code_Desc_ID IN (#preservesinglequotes(typecodelistlist)#)<cfelse> 0=0 </cfif>)
	and 	user_id in 
	(	select _users.user_id 
		from	Group_Approval_Rights
		inner join _users 
		on	Group_Approval_Rights.User_Profile_Id = _users.profiles_id
		<cfif getcurrentuserdetails.recordcount GT 0>
		inner join user_position_holders 
		on	user_position_holders.user_id = _users.user_id 
		left join authority_sequence 
		on	_users.authority_sequence_id = authority_sequence.authority_sequence_id
		</cfif>
		where 
		<cfif listlen(typecodelistlist) GT 0>
			Group_ID IN (#preservesinglequotes(typecodelistlist)#)
		<cfelse>
			0=0
		</cfif>
		<cfif getcurrentuserdetails.recordcount GT 0>
	 	and 	ISNULL(authority_sequence.hq_position_id,0) = #getcurrentuserdetails.hq_position_id#
	 	and 	user_positions_id = #getcurrentuserdetails.user_positions_id#
		</cfif>
		and 	Group_Approval_Rights.deleted = 0
		and 	Group_Approval_Rights.Group_ID_Approval = 1
	)
</cfquery></cfoutput>
</cfif>

<cfquery name="updateagreedprogram" datasource="#application.datasource#">
	update Program_agree
	set system_agreement = 1
	where programid = <cfqueryparam value="#program_Id#" cfsqltype="CF_SQL_INTEGER">
	and user_id in (select user_id from
	Group_Approval_Rights
	inner join _users on
	Group_Approval_Rights.User_Profile_Id = _users.profiles_id
	where 
	<cfif listlen(typecodelistlist) GT 0>
	Group_ID IN (#preservesinglequotes(typecodelistlist)#)
	<cfelse>
	0=0
	</cfif>
	and Group_Approval_Rights.deleted = 0
	and Group_Approval_Rights.Group_ID_Approval = 1)
</cfquery>

<cfquery name="deleteagreedprogram" datasource="#application.datasource#">
delete from Program_agree
where 	programid = <cfqueryparam value="#program_Id#" cfsqltype="CF_SQL_INTEGER">
	and user_id in (select _users.user_id from
	Group_Approval_Rights
	inner join _users on
	Group_Approval_Rights.User_Profile_Id = _users.profiles_id
	<cfif getcurrentuserdetails.recordcount GT 0>
	inner join user_position_holders on
	user_position_holders.user_id = _users.user_id 
	left join authority_sequence on 
	_users.authority_sequence_id = authority_sequence.authority_sequence_id
	</cfif>
	where 
	<cfif listlen(typecodelistlist) GT 0>
	Group_ID IN (#preservesinglequotes(typecodelistlist)#)
	<cfelse>
	0=0
	</cfif>
	<cfif getcurrentuserdetails.recordcount GT 0>
	 and ISNULL(authority_sequence.hq_position_id,0) = #getcurrentuserdetails.hq_position_id#
	 and user_positions_id = #getcurrentuserdetails.user_positions_id#
	</cfif>
	and Group_Approval_Rights.deleted = 0
	and Group_Approval_Rights.Group_ID_Approval = 1)
	
delete from Program_agree_All_Group
where 	programid = <cfqueryparam value="#program_Id#" cfsqltype="CF_SQL_INTEGER">	

INSERT INTO Program_Agree_All_Group
	(User_Id, ProgramId, User_Agree, Agree_DateTime, Executive_Agreement, User_Positions_ID, Authority_Sequence_ID,below_program_margin,program_margin_value,approvable_program_margin_value)
Select
		User_Id, ProgramId, User_Agree, Agree_DateTime, Executive_Agreement, User_Positions_ID, Authority_Sequence_ID,below_program_margin,program_margin_value,approvable_program_margin_value
from	program_agree
where	programid = <cfqueryparam value="#program_Id#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfset objProgram.deletePullbackApproval(
						programId=program_id,
						userId=request.AccessStructure.User_ID) />

<cfquery name="updateagreedprogram" datasource="#application.datasource#">
	update 	contract_main
	set 	edit_agreed_program  =  1,
			modifying_program = 1,
			modifying_user_id = <cfqueryparam value="#request.AccessStructure.user_id#" cfsqltype="CF_SQL_NVARCHAR">
	where 	contract_main_id = <cfqueryparam value="#program_Id#" cfsqltype="CF_SQL_INTEGER">
</cfquery>


<cfif form.ignorethisform EQ 0>
<cfoutput>
<form name="FrmApproveAction" target="mywindowname" action="contract_edit_menu.cfm?CID=#FORM.programid#" method="post">
</form>
</cfoutput>

<script>
	FrmApproveAction.submit();
	window.close();
</script>
</cfif>
