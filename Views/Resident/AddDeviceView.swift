import SwiftUI
import PhotosUI
import CoreImage

struct AddDeviceView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var iotVM: IoTViewModel
    
    @State private var deviceName = ""
    @State private var selectedRoom: RoomType = .kitchen
    
    @State private var scannedQRCode: String? = nil
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var isShowingPhotoAlert = false
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
                
                Section(header: Text("Pareamento do Dispositivo (RF03)")) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
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
                    
                    if let code = scannedQRCode {
                        Text("Código lido: \(code)")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
                
                Section {
                    Button(action: {
                        iotVM.addDevice(name: deviceName.isEmpty ? "Novo Sensor" : deviceName,
                                        roomType: selectedRoom,
                                        connection: .wifi,
                                        scannedCode: scannedQRCode)
                        
                        if !iotVM.showQRError {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Conectar ao Aplicativo")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(scannedQRCode == nil ? Color.gray : Color.red)
                    .disabled(scannedQRCode == nil) // Obriga o usuário a ler a foto primeiro
                }
            }
            .navigationBarTitle("Novo Detector", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $isShowingPhotoAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertTitle == "Sucesso" && deviceName.isEmpty {
                            deviceName = "Sensor"
                        }
                    }
                )
            }
            .alert(isPresented: $iotVM.showQRError) {
                Alert(
                    title: Text("Erro de Pareamento"),
                    message: Text(iotVM.qrErrorMessage),
                    dismissButton: .default(Text("Entendi"))
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
            DispatchQueue.main.async {
                self.scannedQRCode = qrCodeString
            }
            showAlert(title: "Sucesso", message: "Código QR capturado com sucesso. Você já pode conectar.")
        } else {
            showAlert(title: "Aviso", message: "Nenhum QR Code válido foi encontrado na imagem selecionada.")
        }
        
        selectedPhotoItem = nil
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = message
            self.isShowingPhotoAlert = true
        }
    }
}
