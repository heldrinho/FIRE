//Incluindo Bibliotecas
#include <Wire.h>
#include <Adafruit_BMP280.h>
#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>

Adafruit_BMP280 bmp; //I2C
WiFiClient client;
HTTPClient httpClient;

const int AOUTpin=A0; //the AOUT pin of the alcohol sensor goes into analog pin A0 of the arduino
//const int DOUTpin=8; //the DOUT pin of the alcohol sensor goes into digital pin D8 of the arduino

int value;
const char *WIFI_SSID = "HackaTruckIoT";
const char *WIFI_PASSWORD = "iothacka";
const char *URL = "http://192.168.128.118:1880/enviar";

void setup() {
  //Iniciando a comunicação serial
  // Imprimindo Mensagem de teste no Monitor Serial
  Serial.begin(115200);
  Serial.println(F("BMP280 teste"));
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("Connected");
    delay(2000); //sets the baud rate
  //pinMode(DOUTpin, INPUT); //sets the pin as an input to the arduino
  
  if (!bmp.begin(0x76)) { /*Definindo o endereço I2C como 0x76. Mudar, se necessário, para (0x77)*/
    
    //Imprime mensagem de erro no caso de endereço invalido ou não localizado. Modifique o valor 
    Serial.println(F(" Não foi possível encontrar um sensor BMP280 válido, verifique a fiação ou "
                      "tente outro endereço!"));
    while (1) delay(10);
  }
}

void loop() {
  
  //Imprimindo os valores de Temperatura
  Serial.print(F("Temperatura = "));
  Serial.print(bmp.readTemperature());
  Serial.println(" *C");

  value= analogRead(AOUTpin); //reads the analaog value from the alcohol sensor's AOUT pin
  //limit= digitalRead(DOUTpin); //reads the digital value from the alcohol sensor's DOUT pin
  Serial.print(" Alcohol value: ");
  Serial.println(value); //prints the alcohol value
 //prints the limit reached as either LOW or HIGH (above or underneath)
  delay(100);
  httpClient.begin(client, URL);
  httpClient.addHeader("Content-Type", "application/x-www-form-urlencoded");
  httpClient.POST(String(value));
  String content = httpClient.getString();
  httpClient.end();

  //Serial.print(output_value); 
  Serial.print("\n resposta");   
  Serial.println(content);
  delay(5000);

/*if (limit == HIGH){
digitalWrite(ledPin, HIGH); //if limit has been reached, LED turns on as status indicator
}
else{
digitalWrite(ledPin, LOW); 
    //Tempo de espera de 1 segundo
    Serial.println();
    delay(1000);
}
*/
}