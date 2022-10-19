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
        let strings: [String]

        init(key: String, value: Any) throws {
            self.key = key
            let container = try JSONDecoder().decode(JSONObject: value,
                                                     as: Container.self)
            self.format = container.format
            self.formattedComment = container.formattedComment
            self.strings = container.format.strings
        }
    }
}

extension StringDict.PluralItem {
    struct Format: Decodable {
        enum CodingKeys: String, CodingKey {
            case formatValueKey = "NSStringFormatValueTypeKey"
            case zero
            case one
            case two
            case many
            case few
            case other
        }

        let formatValueKey: String
        let strings: [String]

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            let formatValueKey: String = try values.decode(String.self, forKey: .formatValueKey)
            self.formatValueKey = formatValueKey

            let zero = try values.decodeIfPresent(String.self, forKey: .zero)
            let one = try values.decodeIfPresent(String.self, forKey: .one)
            let two = try values.decodeIfPresent(String.self, forKey: .two)
            let many = try values.decodeIfPresent(String.self, forKey: .many)
            let few = try values.decodeIfPresent(String.self, forKey: .few)
            let other = try values.decodeIfPresent(String.self, forKey: .other)
            self.strings = [zero, one, two, many, few, other].compactMap{ $0 }
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
