<?php

# Scraper for EBN data

ini_set ('display_errors', true);

# Ensure serving as UTF-8
header('Content-Type: text/html; charset=utf-8');

# Get the source HTML
$data = file_get_contents ('http://www.electricbicyclenetwork.com/hiring/lakedistrict/');

# Trim to the data part of the page
$data = preg_replace ('/^.+var locations = \[/DsuU', '', $data);
$data = preg_replace ('/\s+\];\svar geocoder;.+$/DsuU', '', $data);
$data = trim ($data);

# Remove the JS brackets
$data = preg_replace ("/^\s*\[/m", '', $data);
$data = preg_replace ("/\],?\s*$/m", '', $data);

# Save to file
$headers = 'description,latitude,longitude,4,hirePoint,chargePoint,accommodation,foodAndDrink,place,numberElectricBikes,regularBikes,url,image,address';
$csvString = $headers . "\n" . $data;
file_put_contents ('./data.txt', $csvString);

# Convert the HTML to an array
require_once ('lib/application.php');
require_once ('lib/pureContent.php');
require_once ('lib/csv.php');
$csv = csv::getData ('./data.txt', false, true);

# Remove tempfiles
#unlink ('./data.txt');

# Trim cells
foreach ($csv as $id => $location) {
	foreach ($location as $key => $value) {
		$csv[$id][$key] = trim ($value);
	}
}

# Extract images from HTML tag
foreach ($csv as $id => $location) {
	$csv[$id]['image'] = str_replace ('-160x100', '', preg_replace ('/^.+src="([^"]+)".+$/', '\1', $location['image']));
}

//application::dumpData ($csv);
//die;

# Save the array as a CSV file
$csv = csv::dataToCsv ($csv);
file_put_contents ('./electricbicyclenetwork.csv', $csv);

?>
