<cfcomponent extends="mxunit.framework.TestCase">
	
	<cffunction name="getSecurityUtil" access="private">
		<cfreturn request.security>
	</cffunction>
	
</cfcomponent>