<?php

class Errors{

    public static $usernameLength = "Username must be between 2 and 25 characters";

    public static $usernameCharacters = "Invalid Username, only A-z and 0-9";

    public static $usernameExists = "This username is already in use, try another.";

    public static $rateEmpty = "Location amount cannot be empty";

    public static $rateInvalid = "Invalid amount";

    public static $rateCharacters = "Amount cannot be more than 20 characters";

    public static $invalidSession = "Session ID Not Found";

}

?>