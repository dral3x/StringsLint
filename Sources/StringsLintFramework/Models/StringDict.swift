//
//  StringDict.swift
//  
//
//  Created by Mark Hall on 2022-07-21.
//

import Foundation


struct StringDict {
    let items: [PluralItem]

    init?(dictionary: [String: Any]) {
        self.items = dictionary.compactMap {
            try? PluralItem(key: $0.key, value: $0.value)
        }
    }
}

extension StringDict {
    struct PluralItem {
        let key: String
        let format: Format
        let formattedComment: String?

        init(key: String, value: Any) throws {
            self.key = key
            let container = try JSONDecoder().decode(JSONObject: value,
                                                     as: Container.self)
            self.format = container.format
            self.formattedComment = container.formattedComment
        }
    }
}

extension StringDict.PluralItem {
    struct Format: Decodable {
        enum CodingKeys: String, CodingKey {
            case formatValueKey = "NSStringFormatValueTypeKey"
        }

        let formatValueKey: String

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            let formatValueKey: String = try values.decode(String.self, forKey: .formatValueKey)
            self.formatValueKey = formatValueKey
        }
    }
}

private extension StringDict.PluralItem {
    struct Container: Decodable {
        enum CodingKeys: String, CodingKey {
            case format = "elements"
            case formattedComment = "context"
        }
        let format: StringDict.PluralItem.Format
        let formattedComment: String?
    }
}

private extension JSONDecoder {
    func decode<T: Decodable>(JSONObject: Any, as type: T.Type? = nil) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: JSONObject, options: [])
        return try self.decode(T.self, from: data)
    }
}
