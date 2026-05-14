//Incluindo Bibliotecas
#include <Wire.h>
#include <Adafruit_BMP280.h>

Adafruit_BMP280 bmp; //I2C

const int AOUTpin=A0; //the AOUT pin of the alcohol sensor goes into analog pin A0 of the arduino
//const int DOUTpin=8; //the DOUT pin of the alcohol sensor goes into digital pin D8 of the arduino

int limit;
int value;

void setup() {
  //Iniciando a comunicação serial
  Serial.begin(9600);
  // Imprimindo Mensagem de teste no Monitor Serial
  Serial.println(F("BMP280 teste"));
  Serial.begin(115200); //sets the baud rate
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
  Serial.print("Limit: ");
  Serial.print(limit); //prints the limit reached as either LOW or HIGH (above or underneath)
  delay(100);

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