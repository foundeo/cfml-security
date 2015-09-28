component displayName="Test Upload" extends="BaseTest" {
	
	function testImageUpload() {

		var result = doUpload({extensions="png,jpg,gif", type="image"}, getAssetPath("foundeo.png"));

		$assert.isTrue(result.success, "success should be true");
		$assert.isTrue(result.validExtension, "validExtension should be true");
		$assert.isTrue(result.validType, "validType should be true");
		
		$assert.isTrue(result.deletedUploadedFile, "deletedUploadedFile should be true");

	}

	function testFileNotImageType() {

		var result = doUpload({extensions="png,jpg,gif", type="image", onFailure="log"}, getAssetPath("text.txt.png"));

		$assert.isFalse(result.success, "success should be false");
		$assert.isTrue(result.validExtension, "validExtension should be true");
		$assert.isFalse(result.validType, "validType should be false");
		$assert.isFalse(result.deletedUploadedFile, "deletedUploadedFile should be false");
	}

}