//Incluindo Bibliotecas
#include <Wire.h>
#include <Adafruit_BMP280.h>
#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>

Adafruit_BMP280 bmp; //I2C
WiFiClient client;
HTTPClient httpClient;

const int AOUTpin = A0; // Pino analógico do sensor de gás

const char *WIFI_SSID = "HackaTruckIoT";
const char *WIFI_PASSWORD = "iothacka";
const char *URL = "http://192.168.128.118:1880/envio";

// --- VARIÁVEL PARA GUARDAR O MAC ADDRESS ---
String macAddress = "";

// --- CONFIGURAÇÃO DO FILTRO DE MÉDIA MÓVEL ---
const int NUM_AMOSTRAS = 30;     // Número de leituras para calcular a média (ajustável)
int leiturasGas[NUM_AMOSTRAS];   // O array que guarda as últimas leituras
int indiceGeral = 0;             // A posição atual no array
long totalGas = 0;               // A soma das leituras atuais
int gasFiltrado = 0;             // O valor final estável

// Controle de tempo para envio (substituindo o delay travado)
unsigned long tempoAnteriorEnvio = 0;
const long intervaloEnvio = 1000; // Tempo em milissegundos entre envios

void setup() {
  Serial.begin(115200);
  Serial.println(F("BMP280 teste"));
  
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
  }
  Serial.println("Connected");
  
  // PEGANDO O MAC ADDRESS APÓS CONECTAR AO WIFI
  macAddress = WiFi.macAddress();
  Serial.print("🏷️ MAC Address da Placa: ");
  Serial.println(macAddress);
  
  delay(2000);
  
  if (!bmp.begin(0x76)) { 
    Serial.println(F(" Não foi possível encontrar um sensor BMP280 válido!"));
    while (1) delay(10);
  }

  // Inicializa todo o array de leituras com zero
  for (int i = 0; i < NUM_AMOSTRAS; i++) {
    leiturasGas[i] = 0;
  }
}

void loop() {
  // === 1. ATUALIZAÇÃO DO FILTRO (Roda continuamente) ===
  // Subtrai a leitura mais antiga armazenada nesta posição
  totalGas = totalGas - leiturasGas[indiceGeral];
  
  // Realiza uma nova leitura bruta do sensor e guarda no array
  leiturasGas[indiceGeral] = analogRead(AOUTpin);
  
  // Adiciona a nova leitura ao total acumulado
  totalGas = totalGas + leiturasGas[indiceGeral];
  
  // Avança o índice do array
  indiceGeral = indiceGeral + 1;
  if (indiceGeral >= NUM_AMOSTRAS) {
    indiceGeral = 0; // Volta para o início do array se estourar o tamanho
  }

  // Calcula a média móvel atualizada
  gasFiltrado = totalGas / NUM_AMOSTRAS;


  // === 2. ENVIO TEMPORIZADO PARA O NODE-RED ===
  unsigned long tempoAtual = millis();
  
  if (tempoAtual - tempoAnteriorEnvio >= intervaloEnvio) {
    tempoAnteriorEnvio = tempoAtual; // Atualiza o cronômetro

    // Lendo a temperatura atual do BMP280
    float temperatura = bmp.readTemperature();

    // Monitor Serial para acompanhar a diferença
// Monitor Serial para acompanhar a diferença
    Serial.print(F("MAC: "));
    Serial.print(macAddress); // <--- Adicionamos a impressão do MAC aqui
    Serial.print(F(" | Temp: "));
    Serial.print(temperatura);
    Serial.print(F(" *C | Gas Bruto: "));
    Serial.print(analogRead(AOUTpin)); 
    Serial.print(F(" | Gas Filtrado: "));
    Serial.println(gasFiltrado);

    // 🚨 MONTANDO O JSON COM O MAC ADDRESS INCLUÍDO
    String jsonPayload = "{\"mac\":\"" + macAddress + "\",\"temperatura\":" + String(temperatura) + ",\"gas\":" + String(gasFiltrado) + "}";

    // Enviando requisição HTTP POST
    httpClient.begin(client, URL);
    httpClient.addHeader("Content-Type", "application/json");
    
    int httpResponseCode = httpClient.POST(jsonPayload);
    
    if (httpResponseCode > 0) {
      String content = httpClient.getString();
      Serial.print("Resposta Node-RED: ");
      Serial.println(content);
    } else {
      Serial.print("Erro no POST: ");
      Serial.println(httpResponseCode);
    }
    
    httpClient.end();
    Serial.println("----------------------------------------");
  }

  // Pequeno intervalo de 100ms para o algoritmo colher amostras de gás com boa frequência
  delay(5000);
}