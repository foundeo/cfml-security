<cfcomponent extends="base">
	
	<cffunction name="testSimple">
		<cfset assertEquals("test", getSecurityUtil().canonicalize("test"))>
	</cffunction>
	
	<cffunction name="testTag">
		<cfset assertEquals("<pete />", getSecurityUtil().canonicalize("&lt;pete &##x2f;&gt;"))>
	</cffunction>
	
	
</cfcomponent>