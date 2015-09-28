<cfcomponent output="false">

	<cffunction name="run">
		<cfargument name="args" type="struct" default="#StructNew()#">
		<cfargument name="params" type="array" hint="The cfhttpparam arguments as an array of structs." default="#ArrayNew(1)#">
	
		<cfhttp result="local.httpResult" attributecollection="#arguments.args#">
			<cfloop array="#arguments.params#" index="local.p">
				<cfhttpparam attributecollection="#local.p#">
			</cfloop>
		</cfhttp>
		<cfreturn local.httpResult>
	</cffunction>


</cfcomponent>