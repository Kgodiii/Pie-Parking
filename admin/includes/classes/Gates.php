<?php

class Gates{

    private $con;

    public function __construct($con)
    {
        $this->con = $con;
    }

    public function getAllGates(){
        $query = $this->con->prepare("SELECT Gates.gateId, Location.locationName, Gates.gateType FROM Gates INNER JOIN Location ON Gates.locationId=Location.locationId");
        $query->execute();

        $result = $query->fetchAll(PDO::FETCH_ASSOC);

        return $result;
    }

    public function getGatesDropdown(){

        $gates = $this->getAllGates();

        $html = "";

        foreach($gates as $gate){
            $gateId = $gate["gateId"];
            $locationName = $gate["locationName"];

            $gateType = $gate["gateType"];
            if($gateType == 0){
                $gateType = "Entry";
            }elseif($gateType == 1){
                $gateType = "Exit";
            }

            $html .= "<option value='$gateId'>$locationName: $gateType(ID: $gateId)</option>";
        }

        return $html;

    }

    public function insertGate($locationId, $gateType){

        $query = $this->con->prepare("INSERT INTO Gates (locationId, gateType) VALUES (:li, :gt)");
        $query->bindValue(":li", $locationId);
        $query->bindValue(":gt", $gateType);

        if($query->execute()){
            $query = $this->con->prepare("SELECT gateId FROM Gates WHERE locationId=:li AND gateType=:gt ORDER BY gateId ASC");
            $query->bindValue(":li", $locationId);
            $query->bindValue(":gt", $gateType);

            $query->execute();

            $gateId = $query->fetch()[0];

            $qrValue = $gateId.",".$locationId.",".$gateType;
            return $qrValue;         
        }

        return false;
    }

    public function deleteGate($gateId){

        $query = $this->con->prepare("DELETE FROM Gates WHERE gateId=:id");
        $query->bindValue(":id", $gateId);
        
        return $query->execute();

    }

}

?>