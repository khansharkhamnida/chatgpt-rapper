//
//  RapperChatError.swift
//  chatgpt-rapper
//
//  Created by Shofia Ghazali on 27/10/26.
//

import Foundation

enum RapperChatError: LocalizedError {
    case missingAPIKey
    case emptyInput
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: "Missing OPENROUTER_API_KEY in the scheme's environment variables."
        case .emptyInput: "Type something first."
        case .emptyResponse: "The model returned no response."
        }
    }
}
