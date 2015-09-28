//<cfcomponent>No Script CFC Support<cfabort></cfcomponent>
component {
	this.name = "cfsec-tests" & Hash( GetCurrentTemplatePath() );

	this.rootDirectory = ReReplace(getCurrentTemplatePath(), "tests[\\/]Application.cfc$", "");
	this.mappings[ "/testbox" ] = this.rootDirectory & "tests/testbox";
	this.mappings[ "/tests" ] = this.rootDirectory & "tests/tests";
	this.mappings[ "/util" ] = this.rootDirectory & "tests/util";

	this.mappings[ "/secureupload" ] = this.rootDirectory & "secureupload";
	this.mappings[ "/securityutil" ] = this.rootDirectory & "securityutil";


	public void function onApplicationStart() {
		application.token = generateSecretKey("AES");
	}

	public void function onRequest( required string requestedTemplate ) {
		if (canTestsRun()) {
			include arguments.requestedTemplate;	
		} else {
			writeOutput("Sorry canTestsRun returned false.");
			abort;
		}
		
	}

	public boolean function canTestsRun() {
		return isLocalHost(cgi.remote_addr) && (server.os.name contains "Mac" || isTravisCI());
	}

	public boolean function isTravisCI() {
		var travisEnv = createObject("java", "java.lang.System").getenv("TRAVIS");
		return !isNull(travisEnv) && travisEnv == "true";
	}

}