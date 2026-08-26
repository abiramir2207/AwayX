<!-----
		Name: 			program_reference_number_edit.cfm
               			Copyright (c) 2006 Blacksmith Applications, Inc.
		Created:
						03/20/2006
						Deepa Kunnath
		Last Modified:
						03/21/2006
						Deepa Kunnath
		Description:
						This page includes the frame program_reference_number_edit_frame.cfm
                       	which allows users who have (profile) access to post approval status = 2, Pending ERP Entry
					   	to edit the program reference number.
					   	Will be called from inside the program.
		Parameters:
                       	CID - encrypted program ID
		Usage:
                      	program_reference_number_edit.cfm?CID=0202J8444AB6AA54B0A040441
----->

<cfparam name="URL.CID" 	default="">
<cfinclude template="program_reference_number_edit_frame.cfm">
