<?php

require_once("includes/config.php");
require_once("includes/classes/Locations.php");
require_once("includes/classes/Gates.php");
require_once("includes/classes/Metrics.php");
require_once("includes/classes/Sessions.php");
require_once("includes/classes/Errors.php");
require_once("includes/classes/FormSanitizer.php");

if(!isset($_SESSION["userLoggedIn"])){
    header("Location: login.php");
}

$locations = new Locations($con);
$gates = new Gates($con);
$metrics = new Metrics($con);
$sessions = new Sessions($con);

if(isset($_POST["locationSubmit"])){

    $locationName = FormSanitizer::sanitizeFormString($_POST["locationName"]);
    $hourlyRate = $_POST["hourlyRate"];

    $success = $locations->insertLocation($locationName, $hourlyRate);

    if($success){
        $locationSuccess = "<span class='successMessage'>Location Added Successfully!</span>";
    }else{
        $locationSuccess = "<span class='errorMessage'>Location Could Not Be Added</span>";
    }

}

if(isset($_POST["gateSubmit"])){

    $locationId = $_POST["locationId"];
    $gateType = $_POST["gateType"];

    $success = $gates->insertGate($locationId, $gateType);

    if($success !== false){
        $gateSuccess = "<span class='successMessage'>Gate Added Successfully!</span>";
        $qrValue = $success;
    }elseif($success == false){
        $gateSuccess = "<span class='errorMessage'>Gate Could Not Be Added</span>";
    }

}

if(isset($_POST["locationDeleteSubmit"])){

    $locationId = $_POST["locationDeleteId"];

    $success = $locations->deleteLocation($locationId);

    if($success){
        $locationDeleteSuccess = "<span class='successMessage'>Location Removed Successfully!</span>";
    }else{
        $locationDeleteSuccess = "<span class='errorMessage'>Location Could Not Be Removed</span>";
    }

}

if(isset($_POST["gateDeleteSubmit"])){

    $gateId = $_POST["gateId"];

    $success = $gates->deleteGate($gateId);

    if($success){
        $gateDeleteSuccess = "<span class='successMessage'>Gate Removed Successfully!</span>";
    }else{
        $gateDeleteSuccess = "<span class='errorMessage'>Gate Could Not Be Removed</span>";
    }

}

if(isset($_POST["sessionOverrideSubmit"])){

    $sessionId = $_POST["sessionId"];

    $success = $sessions->overrideSession($sessionId);

    if($success){
        $sessionOverrideSuccess = "<span class='successMessage'>Session Override Successful!</span>";
    }else{
        $sessionOverrideSuccess = "<span class='errorMessage'>Session Override Failed</span>";
    }

}

?>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>PIE | Admin Dashboard</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="assets/styles.css" rel="stylesheet" type="text/css">
        <link rel="shortcut icon" href="assets/images/favicon.ico" type="image/x-icon">
    </head>
    <body>
        <div class="topBar">
            <img class="logo" src="assets/images/PIE Parking Icon.png">
        </div>
        <div class="spacer"></div>

        <div class="cardRow">
            <div class="card stretch">
                <h1>Metrics</h1>
                <h3>User Accounts: <?php echo $metrics->getNumUsers() ?></h3>
                <h3>Active Sessions: <?php echo $metrics->getNumActiveSessions() ?></h3>
                <h3>Successful Transactions: <?php echo $metrics->getNumTransactions() ?></h3>
                <h3>Total Revenue: R <?php echo number_format($metrics->getRevenue(), 2, '.', ' ') ?></h3>
            </div>
            <div class="card stretch">
                <?php 
                    if(isset($locationSuccess)){
                        echo $locationSuccess;
                    }
                ?>
                <h1>Add Location</h1>
                <form method="post">
                    <input class="userInput" type="text" name="locationName" placeholder="Location Name" required>
                    <?php echo $locations->getError(Errors::$rateEmpty); ?>
                    <?php echo $locations->getError(Errors::$rateInvalid); ?>
                    <?php echo $locations->getError(Errors::$rateCharacters); ?>
                    <input class="userInput" type="number" step=".01" name="hourlyRate" placeholder="Hourly Rate" required>
                    <input class="buttonStyle" type="submit" name="locationSubmit" value="Add">
                </form>
            </div>
            <div class="card stretch">
                <?php 
                    if(isset($gateSuccess)){
                        echo $gateSuccess;
                    }
                ?>
                <h1>Add Gate</h1>
                <form method="post">
                    <label for="locationId">Location:</label>
                    <select id="locationId" name="locationId">
                        <?php echo($locations->getLocationsDropdown()); ?>
                    </select>

                    <label for="gateType">Gate Type:</label>
                    <select id="gateType" name="gateType">
                        <option value="0">Entry</option>
                        <option value="1">Exit</option>
                    </select>

                    <input class="buttonStyle" type="submit" name="gateSubmit" value="Add">
                </form>

                <?php 
                    if(isset($qrValue)){
                        echo "<span class='qrValue'>QR Code Text Value: $qrValue</span>";
                    }
                ?>
            </div>
        </div>

        <div class="cardRow">
            <div class="card stretch">
                <?php 
                    if(isset($locationDeleteSuccess)){
                        echo $locationDeleteSuccess;
                    }
                ?>
                <h1>Remove Location</h1>
                <form method="post">
                    <label for="locationDeleteId">Location:</label>
                    <select id="locationDeleteId" name="locationDeleteId">
                        <?php echo($locations->getLocationsDropdown()); ?>
                    </select>
                    <input class="buttonStyle" type="submit" name="locationDeleteSubmit" value="Remove">
                </form>
            </div>
            <div class="card stretch">
                <?php 
                    if(isset($gateDeleteSuccess)){
                        echo $gateDeleteSuccess;
                    }
                ?>
                <h1>Remove Gate</h1>
                <form method="post">
                    <label for="gateId">Gate:</label>
                    <select id="gateId" name="gateId">
                        <?php echo($gates->getGatesDropdown()); ?>
                    </select>
                    <input class="buttonStyle" type="submit" name="gateDeleteSubmit" value="Remove">
                </form>
            </div>
            <div class="card stretch">
                <?php 
                    if(isset($sessionOverrideSuccess)){
                        echo $sessionOverrideSuccess;
                    }
                ?>
                <h1>Override Session</h1>
                <form method="post">
                    <?php echo $sessions->getError(Errors::$invalidSession); ?>
                    <input class="userInput" type="number" step="1" name="sessionId" placeholder="Session ID" required>
                    <input class="buttonStyle" type="submit" name="sessionOverrideSubmit" value="Override">
                </form>
            </div>
        </div>
    </body>
</html>