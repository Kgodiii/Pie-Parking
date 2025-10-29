<?php

class Locations{

    private $con;
    private $errorArray = array();

    public function __construct($con)
    {
        $this->con = $con;
    }

    public function getAllLocations(){
        $query = $this->con->prepare("SELECT * FROM Location");
        $query->execute();

        $result = $query->fetchAll(PDO::FETCH_ASSOC);

        return $result;
    }

    public function getLocationsDropdown(){

        $locations = $this->getAllLocations();

        $html = "";

        foreach($locations as $location){
            $locationId = $location["locationId"];
            $locationName = $location["locationName"];

            $html .= "<option value='$locationId'>$locationName</option>";
        }

        return $html;

    }

    public function insertLocation($locationName, $hourlyRate){

        $this->verifyCurrencyValue($hourlyRate);

        if(empty($errorArray)){
            $query = $this->con->prepare("INSERT INTO Location (locationName, hourlyRate) VALUES (:ln, :hr)");
            $query->bindValue(":ln", $locationName);
            $query->bindValue(":hr", $hourlyRate);

            return $query->execute();
        }

    }

    public function deleteLocation($locationId){

        $query = $this->con->prepare("DELETE FROM Location WHERE locationId=:id");
        $query->bindValue(":id", $locationId);
        
        return $query->execute();

    }

    private function verifyCurrencyValue($price){

        $pattern = "/^([0-9]+[\.]?[0-9]*)$/";

        if($price == "" || $price == null){
            array_push($this->errorArray, Errors::$rateEmpty);
        }elseif(!preg_match($pattern, $price)){
            array_push($this->errorArray, Errors::$rateInvalid);
        }elseif(strlen($price) > 20){
            array_push($this->errorArray, Errors::$rateCharacters);
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