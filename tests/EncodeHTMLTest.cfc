<cfcomponent extends="base">
	
	<cffunction name="testSimple">
		<cfset assertEquals("test", getSecurityUtil().encodeHTML("test"))>
	</cffunction>
	
	<cffunction name="testTag">
		<cfset assertEquals("&lt;pete &##x2f;&gt;", getSecurityUtil().encodeHTML("<pete />"))>
	</cffunction>
	
	
</cfcomponent>