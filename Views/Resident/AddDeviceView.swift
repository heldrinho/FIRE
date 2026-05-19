import SwiftUI
import PhotosUI
import CoreImage

struct AddDeviceView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var iotVM: IoTViewModel
    
    @State private var deviceName = ""
    @State private var selectedRoom: RoomType = .kitchen
    @State private var connectionType: ConnectionType = .wifi
    
    // 1. NOVO ESTADO: Variável para guardar o código MAC/Serial extraído da imagem
    @State private var scannedQRCode: String? = nil
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Identificação do Sensor")) {
                    TextField("Nome (ex: Sensor Teto)", text: $deviceName)
                    
                    Picker("Ambiente", selection: $selectedRoom) {
                        ForEach(RoomType.allCases, id: \.self) { room in
                            Text(room.rawValue).tag(room)
                        }
                    }
                }
                
                Section(header: Text("Método de Conexão (RF03)")) {
                    Picker("Protocolo", selection: $connectionType) {
                        Text("Wi-Fi (ESP32)").tag(ConnectionType.wifi)
                        Text("Bluetooth LE").tag(ConnectionType.bluetooth)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Importar QR Code da Galeria")
                        }
                        .foregroundColor(.red)
                    }
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                processQRCode(from: uiImage)
                            }
                        }
                    }
                    
                    // Feedback visual extra para o usuário indicando sucesso na leitura
                    if let code = scannedQRCode {
                        Text("Código validado: \(code)")
                            .font(.footnote)
                            .foregroundColor(.green)
                    }
                }
                
                Section {
                    Button(action: {
                        // 2. INTEGRAÇÃO: Aqui enviamos o scannedQRCode para a ViewModel
                        iotVM.addDevice(name: deviceName.isEmpty ? "Novo Sensor" : deviceName,
                                        roomType: selectedRoom,
                                        connection: connectionType,
                                        scannedCode: scannedQRCode)
                        
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Conectar ao Aplicativo")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(scannedQRCode == nil ? Color.gray : Color.red)
                    // 👇 ADICIONE ESTA LINHA: Desativa o botão se scannedQRCode for nil
                    .disabled(scannedQRCode == nil)
                }
            }
            .navigationBarTitle("Novo Detector", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertTitle == "Sucesso" && deviceName.isEmpty {
                            deviceName = "Detector Premium IoT"
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Função de Leitura do QR Code
    private func processQRCode(from image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            showAlert(title: "Erro", message: "Não foi possível carregar a imagem.")
            return
        }
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        let features = detector?.features(in: ciImage) as? [CIQRCodeFeature]
        
        if let firstFeature = features?.first, let qrCodeString = firstFeature.messageString {
            // 3. SALVAR O CÓDIGO: Guardamos a string decodificada no estado da tela
            DispatchQueue.main.async {
                self.scannedQRCode = qrCodeString
            }
            showAlert(title: "Sucesso", message: "Código capturado: \(qrCodeString). Configurações transferidas.")
        } else {
            showAlert(title: "Aviso", message: "Nenhum QR Code válido foi encontrado na imagem selecionada.")
        }
        
        selectedPhotoItem = nil
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = message
            self.isShowingAlert = true
        }
    }
}
