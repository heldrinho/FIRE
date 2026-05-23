# 🔥 FIRE — Sistema de Detecção de Incêndio IoT

<p align="center">
  <img src="https://img.shields.io/badge/iOS-15.0+-black?style=flat-square&logo=apple&logoColor=white" alt="iOS 15.0+"/>
  <img src="https://img.shields.io/badge/Swift-5.5-FA7343?style=flat-square&logo=swift&logoColor=white" alt="Swift 5.5"/>
  <img src="https://img.shields.io/badge/Arquitetura-MVVM-blue?style=flat-square" alt="Arquitetura MVVM"/>
  <img src="https://img.shields.io/badge/Hardware-ESP32-red?style=flat-square" alt="Hardware ESP32"/>
</p>

---

## 📖 Sobre o Projeto
O **FIRE** é uma solução fim-a-fim de segurança residencial e predial focada na detecção precoce de incêndios. Composto por um **Aplicativo Nativo iOS** e integração direta com **Dispositivos IoT (ESP32)**, o sistema monitora em tempo real a temperatura e os níveis de fumaça dos ambientes, acionando notificações críticas com tempo de resposta inferior a 5 segundos em emergências.

Este projeto teve seu início durante o programa **HackaTruck** e foi estruturado tanto para viabilidade de **Plano de Negócios (MVP)** quanto para **Validação Acadêmica**, aplicando as melhores práticas de Engenharia de Software e Interface de Usuário (UI/UX).

---

## 🎯 Principais Funcionalidades

### 👤 Perfil Residencial (Morador)
- **Dashboard em Tempo Real:** Leitura contínua de temperatura, nível de fumaça e bateria dos sensores.
- **Gestão de Ambientes:** Cadastramento customizado por cômodos (Cozinha, Sala, Quarto, Garagem).
- **Onboarding IoT:** Conexão nativa de novos detectores via **Wi-Fi**, **Bluetooth LE** ou **QR Code**.
- **Segurança Ativa:** Teste remoto de sirenes e visualização de Histórico de Ocorrências.
- **Compartilhamento Familiar:** Permissão de acesso sincronizado para membros da família.
- **Ação de Emergência Rápida:** Tela focal de contatos vitais (193, 192, 190) e atalho para rotas de fuga.

### 🏢 Perfil Centralizado (Síndico/Administrador)
- **Monitoramento de Múltiplas Unidades:** Visão global do status de todos os apartamentos do condomínio.
- **Planta Virtual (Mapa):** Interface matricial para identificação visual rápida da origem de focos de fumaça.
- **Auditoria de Hardware:** Rastreamento preditivo de sensores offline ou com bateria crítica.

---

## 🏗️ Arquitetura do Projeto (MVVM)
O aplicativo foi desenvolvido utilizando o padrão de projeto **Model-View-ViewModel (MVVM)** combinado com a reatividade nativa do **Combine** e **SwiftUI**, garantindo separação clara de responsabilidades, facilidade de manutenção e escalabilidade.

```text
FIRE/
├── Models/             # Estruturas de Domínio puros (User, Device, Room, AlertEvent)
├── ViewModels/         # Lógica de Negócio e Estado (AuthViewModel, IoTViewModel)
├── Views/              # Camada de Interface Visual (SwiftUI)
│   ├── Components/     # Botões, Cards e Modais customizados reutilizáveis
│   ├── Auth/           # Telas de Login e Cadastro
│   ├── Resident/       # Telas exclusivas do fluxo do Morador
│   └── Admin/          # Telas exclusivas do fluxo do Síndico
└── Services/           # Camada de Rede, Telemetria e Conexão de Hardware
```

---

## 👥 Equipe

* Helder Domingos
* João Átila
* Nicolas de Sena
* Pedro Henrique
