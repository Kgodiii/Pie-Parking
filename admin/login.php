<?php

require_once("includes/config.php");
require_once("includes/classes/FormSanitizer.php");
require_once("includes/classes/Account.php");

$account = new Account($con);

if(isset($_POST["loginSubmit"])){

    $username = FormSanitizer::sanitizeFormString($username);
    $password = hash("sha256", $password);

    $success = $account->login($username, $password);

    if($success){
        header("Location: dashboard.php");
    }
}

?>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>PIE | Admin Login</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="assets/styles.css" rel="stylesheet" type="text/css">
        <link rel="shortcut icon" href="assets/images/favicon.ico" type="image/x-icon">
    </head>
    <body>
        <div class="center">
            <div class="card">
                <h1>Login</h1>
                <form method="post">
                    <input class="userInput" type="text" name="username" id="username" placeholder="Username" required>
                    <input class="userInput" type="password" name="password" id="password" placeholder="Password" required>
                    <input class="buttonStyle" type="submit" name="loginSubmit" value="Login">
                </form>
                <h3>AS EASY AS...</h3>
            </div>
        </div>
    </body>
</html>