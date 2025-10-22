#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecureBearSSL.h>
#include <Arduino_JSON.h>
#include "secrets.h"

//Your IP address or domain name with URL path
const char* getEndpoint = "https://pieparking.co.za/api/iot?id=1";
const char* postEndpoint = "https://pieparking.co.za/api/iot?id=1&close=true";

// Update interval time set to 5 seconds
const long interval = 5000;
unsigned long previousMillis = 0;

String outputsState;

void setup() {
    Serial.begin(9600);
    delay(250);
    pinMode(D4, OUTPUT);
    pinMode(D5, OUTPUT);

    Serial.print("Connecting to ");
    Serial.println(WIFI_SSID);

    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    while (WiFi.status() != WL_CONNECTED){
        delay(1000);
        Serial.print(".");
        digitalWrite(D4,HIGH);
        delay(100);
        digitalWrite(D4,LOW);
    }
    Serial.println("");
    Serial.println("WiFi Connected.");
    Serial.print("IP: ");
    Serial.println(WiFi.localIP());
}

void loop() {
  unsigned long currentMillis = millis();
  
  if(currentMillis - previousMillis >= interval) {
     // Check WiFi connection status
    if(WiFi.status()== WL_CONNECTED ){ 
      outputsState = httpGETRequest(getEndpoint);
      Serial.println(outputsState);
      JSONVar myObject = JSON.parse(outputsState);
  
      // JSON.typeof(jsonVar) can be used to get the type of the var
      if (JSON.typeof(myObject) == "undefined") {
        Serial.println("Parsing input failed!");
        return;
      }
    
      // myObject.keys() can be used to get an array of all the keys in the object
      int status = myObject["status"];

      if(status == 1){
        digitalWrite(D5, HIGH);
        delay(200);
        digitalWrite(D5, LOW);
        httpPOSTRequest(postEndpoint);
      }
    
      // save the last HTTP GET Request
      previousMillis = currentMillis;
    }
    else {
      Serial.println("WiFi Disconnected");
    }
  }
}

String httpGETRequest(const char* serverName) {
  std::unique_ptr<BearSSL::WiFiClientSecure>client(new BearSSL::WiFiClientSecure);

  // Ignore SSL certificate validation
  client->setInsecure();

  HTTPClient https;
    
  // Your IP address with path or Domain name with URL path 
  https.begin(*client, serverName);

  https.addHeader("Authorization", "Bearer " + String(BEARER_TOKEN));
  
  // Send HTTP POST request
  int httpResponseCode = https.GET();
  
  String payload = "{}"; 
  
  if (httpResponseCode>0) {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
    payload = https.getString();
  }
  else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
  }
  // Free resources
  https.end();

  return payload;
}

String httpPOSTRequest(const char* serverName) {
  std::unique_ptr<BearSSL::WiFiClientSecure>client(new BearSSL::WiFiClientSecure);

  // Ignore SSL certificate validation
  client->setInsecure();

  HTTPClient https;
    
  // Your IP address with path or Domain name with URL path 
  https.begin(*client, serverName);

  https.addHeader("Authorization", "Bearer " + String(BEARER_TOKEN));
  
  // Send HTTP POST request
  int httpResponseCode = https.PUT("");
  
  String payload = "{}"; 
  
  if (httpResponseCode>0) {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
    payload = https.getString();
  }
  else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
  }
  // Free resources
  https.end();

  return payload;
}