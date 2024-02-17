//
//  Chat.swift
//  MutliModalChatAI
//
//  Created by Enes Talha Uçar  on 17.02.2024.
//

import Foundation

enum ChatRole {
    case user
    case model
}
struct ChatMessage : Identifiable, Equatable {
    let id = UUID().uuidString
    var role : ChatRole
    var message : String
    var image : [Data]?
}
