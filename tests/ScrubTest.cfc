<cfcomponent extends="base">
	
	<cffunction name="testScrub">
		<cfset assertEquals("test123", getSecurityUtil().scrub("test123"))>
		<cfset assertEquals("test123", getSecurityUtil().scrub("test123!@##<>"))>
	</cffunction>
	
</cfcomponent>