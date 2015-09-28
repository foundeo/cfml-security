component extends="BaseTest" {

	function testOnFailureLog() {

		var result = doUpload({extensions="png,jpg,gif", type="image", onFailure="log"}, getAssetPath("text.txt.png"));
		$assert.isFalse(result.success, "success should be false");
		$assert.isTrue(result.validExtension, "validExtension should be true");
		$assert.isFalse(result.validType, "validType should be false");
		$assert.isFalse(result.deletedUploadedFile, "deletedUploadedFile should be false");
		//no exception
		$assert.isFalse(StructKeyExists(result, "exception"));
	}

	function testOnFailureThrow() {

		var result = doUpload({extensions="png,jpg,gif", type="image", onFailure="throw"}, getAssetPath("text.txt.png"));
		$assert.isFalse(result.success, "success should be false");
		$assert.isTrue(StructKeyExists(result, "exception"));
		
		
	}


}