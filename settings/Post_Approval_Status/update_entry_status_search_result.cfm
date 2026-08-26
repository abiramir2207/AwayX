<!------ update_entry_status_search_result.cfm ----->
<!------ do search ----->
<cfset New_Program_Number_List = Replace(Form.Program_Number_List, "#chr(13)##chr(10)#", ",", "all") />	

<cfquery name="qDoSearch" datasource="#application.datasource#">
DECLARE @Tmp_Program_List TABLE
(
	Search_Token NVARCHAR(50),
	Program_ID Int,
	Message NVARCHAR(100),
	Update_Type Int
)
DECLARE @Tmp_Current_Program TABLE
(
	Program_ID Int,
	Status_ID Int,
	Approved Bit,
	Program_Post_Approval_Status_ID Int
)
DECLARE @Program_ID Int,
		@Approved Bit,
		@Program_Post_Approval_Status_ID Int,
		@Message NVARCHAR(50),
		@Update_Type Int
<!------ loop thru the list and insert into temp table for each match ----->
<cfloop list="#New_Program_Number_List#" index="EachProgramNumber">
DELETE FROM @Tmp_Current_Program
INSERT INTO @Tmp_Current_Program(Program_ID, Status_ID, Approved, Program_Post_Approval_Status_ID)
SELECT	Contract_Main_ID, Contract_Status_Type_IDX, Approved, Program_Post_Approval_Status_ID
FROM	Contract_Main
WHERE	Deleted = 0
AND		Manual_Cancel = 0
AND (
Contract_Number LIKE '%#EachProgramNumber#%'
OR	Replace(Contract_Number, '000-', '') + '-' + CASE
									WHEN LEN(revision_version) = 4 THEN RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 4)
									WHEN LEN(revision_version) = 5 THEN RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 3)
								END LIKE '%#EachProgramNumber#%'
)
IF(select count(*) from @Tmp_Current_Program) > 1
BEGIN
	-- more than entry
	IF(select count(*) from @Tmp_Current_Program where Approved = 1) > 0
	BEGIN
		DELETE FROM @Tmp_Current_Program
		WHERE	Approved <> 1
	END
	IF(select count(*) from @Tmp_Current_Program where ISNULL(Program_Post_Approval_Status_ID, 0) = 2) > 0
	BEGIN
		DELETE FROM @Tmp_Current_Program
		WHERE	ISNULL(Program_Post_Approval_Status_ID, 0) <> 2
	END
END
SET @Program_ID = NULL
SET @Program_Post_Approval_Status_ID = NULL
SELECT 	@Program_ID = Program_ID,
		@Approved = Approved,
		@Program_Post_Approval_Status_ID = Program_Post_Approval_Status_ID
FROM	@Tmp_Current_Program
SET @Message = ''
SET @Update_Type = 1
IF @Program_ID IS NULL
BEGIN
	SET @Message = 'Program does not exist'
	SET @Update_Type = 0
END
ELSE IF ISNULL(@Program_Post_Approval_Status_ID, 0) <> 2
BEGIN
	SET @Message = 'Program is not in Pending ERP Entry status'
	SET @Update_Type = 0
END
INSERT INTO @Tmp_Program_List(Search_Token,	Program_ID,	Message, Update_Type)
VALUES ('#EachProgramNumber#', @Program_ID, @Message, @Update_Type)

</cfloop>
SELECT 	Tmp_Program_List.Search_Token, Tmp_Program_List.Program_ID, Tmp_Program_List.Message, Tmp_Program_List.Update_Type,
		Contract_Main.Contract_Number, Contract_Main.Contract_Title, Contract_Main.Contract_Status_Type_IDX, Contract_Main.Contract_Reference_Number, 
		Contract_Status_Types.Contract_Status_Type_Desc,
		Contract_Main.ProgramType_ID, Program_Control_Panel_Options.Created_Type
FROM	@Tmp_Program_List Tmp_Program_List
LEFT JOIN Contract_Main
ON		Contract_Main.Contract_Main_ID = Tmp_Program_List.Program_ID
LEFT JOIN Contract_Status_Types
ON		Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
LEFT JOIN Program_Control_Panel_Options
ON		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
</cfquery>