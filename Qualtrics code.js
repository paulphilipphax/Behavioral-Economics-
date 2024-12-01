/* 
MPL randomizer
Sequential row reveal
Forced consistent response function
Formatting  
*/

var columnTitles = [
    "<b>Lottery<b>", 
    "<b>Keep it private</b><br>& enter lottery for:", 
    "<b>Show</b><br>& enter lottery for:"
];

// Wait for the page to load before applying titles
Qualtrics.SurveyEngine.addOnload(function() {
    // Find the first row of the table and create a new header row
    var table = jQuery(this.getQuestionContainer()).find("table");

    // New header row and append it to the top of the table
    var headerRow = jQuery('<tr>').css({
        "font-weight": "bold", // Optional styling for the header row
        "text-align": "center"
    });

    // Populate the header row with cells containing the column titles
    for (var i = 0; i < columnTitles.length; i++) {
        var headerCell = jQuery('<th>').html(columnTitles[i]);
        headerRow.append(headerCell);
    }

    // Insert the new header row before the first row of the table
    table.find("tr:first-child").before(headerRow);
});


// Sequential reveal part
Qualtrics.SurveyEngine.addOnload(function() {
    // Select the table and rows within the question
    var table = jQuery(this.getQuestionContainer()).find("table");
    var rows = table.find("tr");

    // Function to detect if the device is mobile based on user agent
    function isMobileDevice() {
        return /Mobi|Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
    }

    // Apply compact styling directly and prepare for reveal
    function applyCompactStyles() {
        const isMobile = isMobileDevice();

        table.css("width", "100%");

        rows.each(function(index) {
            jQuery(this).find("th, td").css({
                "padding": isMobile ? "3px 5px" : "5px 10px",  // Compact padding
                "font-size": isMobile ? "0.85em" : "1em",      // Adjust font size
                "line-height": "1.1em",                        // Tighter line height
                "vertical-align": "middle",                    // Center content vertically
                "box-sizing": "border-box",
                "overflow": "hidden"                           // Prevent overflow
            });

            // Set a controlled, minimal height to avoid large boxes
            jQuery(this).css("height", isMobile ? "2em" : "2.5em");
        });

        // Initial hiding using visibility and opacity for smoother reveal, with a flag to track revealed rows
        rows.each(function(index) {
            if (index > 1 && !jQuery(this).data("revealed")) { // Skip header and first row, only apply if not revealed
                jQuery(this).css({
                    "visibility": "hidden",
                    "opacity": "0",
                    "transition": "visibility 0s, opacity 0.3s ease"
                });
            }
        });
    }

    // Apply initial compact styles
    applyCompactStyles();

    // Set up event listener to progressively reveal rows using visibility and opacity
    rows.each(function(index) {
        if (index > 0) { // Skip the header row
            var inputs = jQuery(this).find("input[type='radio']");

            // Set up a click event on each radio button in the current row
            inputs.on("click", function() {
                // Reveal the next row, if there is one, using visibility and opacity
                if (index + 1 < rows.length) {
                    rows.eq(index + 1).css({
                        "visibility": "visible",
                        "opacity": "1"
                    }).data("revealed", true); // Mark row as revealed
                }
            });
        }
    });
});


/* Inconsistency forcer
Qualtrics.SurveyEngine.addOnload(function() {
    // Select the table and rows within the question
    var table = jQuery(this.getQuestionContainer()).find("table");
    var rows = table.find("tr");

    // Variables to track selection and switching
    var initialSelection = null;
    var switched = false;

    rows.each(function(index) {
        var inputs = jQuery(this).find("input[type='radio']");

        inputs.on("click", function() {
            var selectedValue = jQuery(this).val();

            // If no selection has been made, record the initial selection
            if (initialSelection === null) {
                initialSelection = selectedValue;
                console.log("Initial selection:", initialSelection);
            }

            // Check if the participant switched to a different column
            if (!switched && initialSelection !== selectedValue) {
                switched = true; // Mark that a switch has occurred
                console.log("Switch detected on row:", index + 1);

                // Pre-fill only the rows after the switch with the new selection
                rows.slice(index + 1).each(function() {
                    jQuery(this).find("input[type='radio'][value='" + selectedValue + "']")
                        .prop("checked", true);
                });

                console.log("Rows after row", index + 1, "pre-filled with selection:", selectedValue);
            }
        });
    });
});
*/

// random row generator and getting choice in that row
Qualtrics.SurveyEngine.addOnPageSubmit(function() {
    /*generate random number and set the variable embedded variable "randomRow" = randomRow*/
	var randomRow = Math.floor(Math.random() * 10) + 1;

	/*Store the user choice for that random row in this variable */
    var selectedChoice = this.getChoiceAnswerValue(randomRow);
  
	var lotteryValues = ["240 DKK", "220 DKK", "200 DKK", "180 DKK", "160 DKK", "140 DKK", "120 DKK", "100 DKK", "80 DKK", "60 DKK"];
    
    var lotteryValue;
    if (selectedChoice == 1) {
		lotteryValue = lotteryValues[randomRow - 1]; } 
	else {
		lotteryValue = "200 DKK"
    }
    
    // Store the in the embedded data field for later use
	Qualtrics.SurveyEngine.setEmbeddedData("randomRow", randomRow);
    Qualtrics.SurveyEngine.setEmbeddedData("lotteryValue", lotteryValue);
	Qualtrics.SurveyEngine.setEmbeddedData("selectedChoice", selectedChoice);
});