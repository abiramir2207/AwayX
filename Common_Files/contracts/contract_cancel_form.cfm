<!-----
		Name: 			contract_cancel_form.cfm
               			Copyright (c) 2006 Blacksmith Applications, Inc.
		Created:
						03/10/2006
						Deepa Kunnath
		Last Modified:
						03/10/2006
						Deepa Kunnath
		Description:
                       This page includes the frame contract_cancel_form_frame.cfm which gives differet cancel options to the user when user click cancel program

		Parameters:
                       CID - encrypted program ID
		Usage:
                       contract_cancel_form.cfm?CID=0202J8444AB6AA54B0A040441
----->
<cfparam name="URL.CID" default="">
<cfinclude template="\Common_Files\contracts\contract_cancel_form_frame.cfm">
