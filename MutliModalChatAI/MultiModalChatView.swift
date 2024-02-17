//
//  MultiModalChatView.swift
//  MutliModalChatAI
//
//  Created by Enes Talha Uçar  on 17.02.2024.
//

import SwiftUI
import PhotosUI

struct MultiModalChatView: View {
    @State private var textInput = ""
    @State private var chatService = ChatService()
    @State private var photoPickerItems = [PhotosPickerItem]()
    @State private var selectedPhotosData = [Data]()
    
    var body: some View {
        VStack {
            Image("gemini-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
            
            
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(chatService.messages) { chatMessage in
                        chatMessageView(chatMessage)
                    }
                }
                .onChange(of: chatService.messages) {
                    guard let recentMessage = chatService.messages.last else { return }
                    DispatchQueue.main.async {
                        withAnimation {
                            proxy.scrollTo(recentMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            if selectedPhotosData.count > 0 {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 10, content: {
                        ForEach(0..<selectedPhotosData.count, id: \.self) { index in
                            Image(uiImage: UIImage(data: selectedPhotosData[index])!)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    })
                }
                .frame(height: 50)
                
            }
            
            HStack {
                PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 3, matching: .images) {
                    Image(systemName: "photo.stack.fill")
                        .tint(Color("blue"))
                        .frame(width: 40,height: 50)
                }.onChange(of: photoPickerItems) {
                    Task {
                        selectedPhotosData.removeAll()
                        for item in photoPickerItems {
                            if let imageData = try await item.loadTransferable(type: Data.self) {
                                selectedPhotosData.append(imageData)
                            }
                        }
                    }
                }
                TextField("Enter a message", text: $textInput)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(.black)
                
                if chatService.loadingResponse {
                    ProgressView()
                        .frame(width: 30)
                        .tint(Color("blue"))
                }
                else {
                    Button(action: sendMessage, label: {
                        Image(systemName: "paperplane.fill")
                            .tint(Color("blue"))
                    }).frame(width: 30)
                    
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder private func chatMessageView(_ message: ChatMessage) -> some View {
        if let images = message.image, images.isEmpty == false {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10, content: {
                    ForEach(0..<images.count, id: \.self) { index in
                        Image(uiImage: UIImage(data: images[index])!)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .containerRelativeFrame(.horizontal)
                    }
                })
                .scrollTargetLayout()
            }
            .frame(height: 150)
        }
        ChatBubble(direction: message.role == .model ? .left : .right) {
            Text(message.message)
                .font(.body)
                .padding(14)
                .foregroundStyle(message.role == .model ? .black : .white)
                .background(message.role == .model ? Color("grey") : Color("blue"))
        }
    }
    
    private func sendMessage() {
        Task {
            await chatService.sendMessage(message: textInput,imageData: selectedPhotosData)
            selectedPhotosData.removeAll()
            textInput = ""
        }
    }
}

#Preview {
    MultiModalChatView()
}
