import SwiftUI

struct RemoveDeviceView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var iotVM: IoTViewModel
    
    var body: some View {
        NavigationView {
            List {
                // Verificamos se a lista está vazia para dar feedback ao usuário
                if iotVM.devices.isEmpty {
                    Text("Nenhum sensor cadastrado.")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    // Percorremos todos os dispositivos
                    ForEach(iotVM.devices) { device in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(device.name)
                                    .font(.headline)
                                Text("Bateria: \(device.batteryLevel)%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Botão individual de exclusão
                            Button(action: {
                                removeDevice(device)
                            }) {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle()) // Evita que o clique na lixeira selecione a linha inteira
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationBarTitle("Remover Sensores", displayMode: .inline)
            .navigationBarItems(trailing: Button("Concluir") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // MARK: - Função de Remoção
    private func removeDevice(_ device: Device) {
        // Procuramos a posição do dispositivo na lista e o apagamos
        if let index = iotVM.devices.firstIndex(where: { $0.id == device.id }) {
            // Se você tiver uma função específica na IoTViewModel, chame-a aqui.
            // Exemplo: iotVM.deleteDevice(at: index)
            // Caso contrário, removemos diretamente da array (se a variável for @Published)
            iotVM.devices.remove(at: index)
        }
    }
}


