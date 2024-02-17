//
//  ChatService.swift
//  MutliModalChatAI
//
//  Created by Enes Talha Uçar  on 17.02.2024.
//

import Foundation
import SwiftUI
import GoogleGenerativeAI


@Observable
class ChatService {
    private var proModel = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    private var proVisionModel = GenerativeModel(name: "gemini-pro-vision", apiKey: APIKey.default)
    private(set) var messages = [ChatMessage]()
    private(set) var loadingResponse = false
    
    
    func sendMessage(message: String, imageData : [Data]) async {
        loadingResponse = true
        
        messages.append(.init(role: ChatRole.user, message: message, image: imageData))
        messages.append(.init(role: ChatRole.model, message: "", image: nil))
        
        
        do {
            let chatModel = imageData.isEmpty ? proModel : proVisionModel
            var images = [PartsRepresentable]()
            for data in imageData {
                if let compressedData = UIImage(data: data)?.jpegData(compressionQuality: 0.1) {
                    images.append(ModelContent.Part.jpeg(compressedData))
                }
            }
            
            let outputStream = chatModel.generateContentStream(message, images)
            for try await chunk in outputStream {
                guard let text = chunk.text else {
                    return
                }
                let lastChatMessageIndex = messages.count - 1
                messages[lastChatMessageIndex].message += text
            }
            
            loadingResponse = false
            
        } catch {
            loadingResponse = false
            messages.removeLast()
            messages.append(.init(role: .model, message: "Something went wrong, please try again later."))
        }
    }
}
