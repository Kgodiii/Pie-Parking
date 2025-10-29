<?php

class Account{

    private $con;
    private $errorArray = array();

    public function __construct($con)
    {
        $this->con = $con;
    }

    public function login($username, $password){

        $this->validateLoginUsername($username);

        if(empty($this->errorArray)){
            $query = $this->con->prepare("SELECT * FROM AdminUsers WHERE username=:un AND password=:pw");
            $query->bindValue(":un", $username);
            $query->bindValue(":pw", $password);
            $query->execute();

            if($query->rowCount() == 1){
                $_SESSION["userLoggedIn"] = $username;
                return true;
            }
        }

        return false;

    }

    private function validateLoginUsername($username){
        $pattern = "/^[A-z0-9]*$/";

        if(strlen($username) < 2 || strlen($username) > 25){
			array_push($this->errorArray, Errors::$usernameLength);
            return;
		}
        elseif(!preg_match($pattern, $username)){
            array_push($this->errorArray, Errors::$usernameCharacters);
        }
    }

    private function validateUsername($username){

        $query = $this->con->prepare("SELECT * FROM AdminUsers WHERE username=:un");
        $query->bindValue(":un", $username);
        $query->execute();

        $pattern = "/^[A-z0-9]*$/";

        if($query->rowCount() > 0){
            array_push($this->errorArray, Errors::$usernameExists);
            return;
        }elseif(strlen($username) < 2 || strlen($username) > 25){
			array_push($this->errorArray, Errors::$usernameLength);
            return;
		}
        elseif(preg_match($pattern, $username)){
            array_push($this->errorArray, Errors::$usernameCharacters);
        }
    }

    public function getError($error){
		if(in_array($error, $this->errorArray)){
			return "<span class='errorMessage'>$error</span>";
		}
	}

}

?>