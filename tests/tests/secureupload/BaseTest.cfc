component extends="testbox.system.BaseSpec" {

	package struct function generateUploadKey(string args) {
		var result = {t=getTickCount(), h=""};
		result.h = Hmac(result.t & arguments.args, application.token, "HMACSHA512");
		return result;
	}

	

	function getUploadURL() {
		var u = "http";
		if (cgi.https IS "on") {
			u = u & "s";
		}
		u = u & "://" & cgi.server_name;
		if (cgi.server_port != "80") {
			u = u & ":" & cgi.server_port;
		}
		u = u & replace(cgi.script_name, "run.cfm", "tests/secureupload/upload.cfm");
		return u;
	}

	function doUpload(args, filePath) {
		var httpUtil = new util.cfhttp();
		var argsAsJSON = serializeJSON(arguments.args);
		var uploadKey = generateUploadKey(argsAsJSON);
		var req = {method="POST", url=getUploadURL()};
		var params = [{name="args", value=argsAsJSON, type="formfield"}, 
			{name="t", value=uploadKey.t, type="formfield"},
			{name="h", value=uploadKey.h, type="formfield"},
			{name="file", file=arguments.filePath, type="file"}];
		var result = httpUtil.run(args=req, params=params);
		return deserializeJSON(result.fileContent);
	}

	function getAssetPath(fileName) {
		return ExpandPath("/tests/secureupload/assets/" & arguments.fileName);
	}


	

}