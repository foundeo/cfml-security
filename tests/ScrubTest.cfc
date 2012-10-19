<cfcomponent extends="base">
	
	<cffunction name="testScrub">
		<cfset assertEquals("test123", getSecurityUtil().scrub("test123"))>
		<cfset assertEquals("test123", getSecurityUtil().scrub("test123!@##<>"))>
	</cffunction>
	
	<cffunction name="testLink">
		<cfset var link = "https://example.com/foo.cfm?id=1&x=z">
		<cfset assertEquals(link, getSecurityUtil().scrub(link, "\./:_\?=&-"))>
	</cffunction>
	
</cfcomponent>