(function() {
	var existingStyle = document.getElementById('cs-dynamic-style');
	if(!existingStyle) {
		var style = document.createElement("style");
		style.type = "text/css";
		style.id = 'cs-dynamic-style';
		document.getElementsByTagName("head")[0].appendChild(style);
	}
	existingStyle = document.getElementById('cs-dynamic-style');

	// alter Reference Number text input
	existingStyle.innerHTML =
		'#allowancesHSA th:nth-child(3) {' +
			'display: inline-block;' +
			'width: 106px;' +
		'}';

	// alter error messages style
	var errorMessageElements = document.getElementsByClassName('ps-error');
	for(var i=0; i < errorMessageElements.length; i++){
		errorMessageElements[i].style.display = "inline-block";
		errorMessageElements[i].style.textAlign = "center";
	}

})();