<!---

CF_ICQpager v0.1 (ColdFusion 4.0 Version)
by Joe Cheng <jcheng@allaire.com>

-------------------------------------

CF_ICQpager sends messages through the ICQ wwp (world-wide-pager) website. For 
more information about ICQ, go to http://www.mirabilis.com.

CF_ICQpager has the following syntax:

<CF_ICQpager
	To="Recipient's ICQ Number"
	From="Sender's Name"
	FromEmail="Sender's Email"
	Subject="Message subject"
	Body="Message body">

You'll want to call CF_ICQpager from within a <CFTRY> block, because if 
something goes wrong with the sending of the message, an error will be
thrown by the tag.

--->

<CFPARAM NAME="Attributes.To" DEFAULT="">
<CFPARAM NAME="Attributes.From" DEFAULT="">
<CFPARAM NAME="Attributes.FromEmail" DEFAULT="">
<CFPARAM NAME="Attributes.Subject" DEFAULT="">
<CFPARAM NAME="Attributes.Body" DEFAULT="">

<CFHTTP URL="http://wwp.mirabilis.com/scripts/WWPMsg.dll" METHOD="POST" RESOLVEURL="false">
	<CFHTTPPARAM NAME="to" VALUE="#Attributes.To#" TYPE="FORMFIELD">
	<CFHTTPPARAM NAME="from" VALUE="#Attributes.From#" TYPE="FORMFIELD">
	<CFHTTPPARAM NAME="fromemail" VALUE="#Attributes.FromEmail#" TYPE="FORMFIELD">
	<CFHTTPPARAM NAME="subject" VALUE="#Attributes.Subject#" TYPE="FORMFIELD">
	<CFHTTPPARAM NAME="body" VALUE="#Attributes.Body#" TYPE="FORMFIELD">
	<CFHTTPPARAM NAME="Send" VALUE="Send message" TYPE="FORMFIELD">
</CFHTTP>

<CFIF Find("Your message has been processed", CFHTTP.FileContent) IS 0>
	<CFTHROW MESSAGE="ICQ has rejected your message.">
</CFIF>