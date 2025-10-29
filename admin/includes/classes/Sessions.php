<?php

class Sessions{

    private $con;
    private $errorArray = array();

    public function __construct($con)
    {
        $this->con = $con;
    }

    public function overrideSession($sessionId){

        $this->validateSessionId($sessionId);

        if(empty($this->errorArray)){
            $timePaid = date("Y-m-d H:i:s");
            $timeOut = date("Y-m-d H:i:s");

            $query = $this->con->prepare("UPDATE Session SET timePaid=:tp, timeOut=:to, override=1 WHERE sessionId=:id");
            $query->bindValue(":tp", $timePaid);
            $query->bindValue(":to", $timeOut);
            $query->bindValue(":id", $sessionId);

             return $query->execute();
        }

    }

    private function validateSessionId($sessionId){

        $query = $this->con->prepare("SELECT * FROM Session WHERE sessionId=:id");
        $query->bindValue(":id", $sessionId);
        $query->execute();

        if($query->rowCount() != 1){
            array_push($this->errorArray, Errors::$invalidSession);
        }else{
            return;
        }

    }

    public function getError($error){
		if(in_array($error, $this->errorArray)){
			return "<span class='errorMessage'>$error</span>";
		}
	}

}

?>