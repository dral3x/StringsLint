import AppKit

//let text = "        emptyView.hydrate(NSLocalizedString(\"settings_blocked_users_empty_message\", comment: \"sdfds f\"), image: nil)"
//let text = "NSLocalizedString(\"blabla1\", comment: \"sdfds f\") : NSLocalizedString(\"blabla2\", comment: \"sdfds f\")"
let text = "NSLocalizedString(\"abc\", comment: \"blabla\") NSLocalizedString(\"def\", comment: \"blabla\")"


let pattern = "(NSLocalizedString|CFLocalizedString)\\(\"([^\"]+)\", (tableName: \"([^\"]+)\", )?(comment: \"([^\"]*)\")\\)"

let regex = try NSRegularExpression(pattern: pattern)
let results = regex.matches(in: text, options: [ .reportCompletion ], range: NSRange(text.startIndex..., in: text))

print("matches: \(results.count)")

for result in results {
    
    print("numberOfRanges: \(result.numberOfRanges)")
    
    for index in 0..<result.numberOfRanges {
        print("\(index): range \(result.range(at: index))")
        if let range = Range(result.range(at: index), in: text) {
            let substring = text[range]
            print("\(index): "+String(substring))
        }
    }
    
}

// MARK: - XIB
/*
let text1 = "                                <userDefinedRuntimeAttribute type=\"string\" keyPath=\"textLocalized\" value=\"chat_error_banned\"/>"

let patternXib = "<userDefinedRuntimeAttribute type=\"string\" keyPath=\"(textLocalized|placeholderLocalized)\" value=\"(.*?)\"/>"

let regexXib = try NSRegularExpression(pattern: patternXib)
if let result = regexXib.firstMatch(in: text1, range: NSRange(text1.startIndex..., in: text1)) {
    
    if result.numberOfRanges > 0, let range = Range(result.range(at: 0), in: text1) {
        let substring = text1[range]
        print("0: "+String(substring))
    }
    
    if result.numberOfRanges > 1, let range = Range(result.range(at: 1), in: text1) {
        let substring = text1[range]
        print("1: "+String(substring))
    }
    
    if result.numberOfRanges > 2, let range = Range(result.range(at: 2), in: text1) {
        let substring = text1[range]
        print("2: "+String(substring))
    }
    
    if result.numberOfRanges > 3, let range = Range(result.range(at: 3), in: text1) {
        let substring = text1[range]
        print("3: "+String(substring))
    }
    
    if result.numberOfRanges > 4, let range = Range(result.range(at: 4), in: text1) {
        let substring = text1[range]
        print("4: "+String(substring))
    }
}

let text2 = "                                <userDefinedRuntimeAttribute type=\"string\" keyPath=\"placeholderLocalized\" value=\"chat_textfield_placeholder\"/>"

if let result = regexXib.firstMatch(in: text2, range: NSRange(text2.startIndex..., in: text2)) {
    
    if result.numberOfRanges > 0, let range = Range(result.range(at: 0), in: text2) {
        let substring = text2[range]
        print("0: "+String(substring))
    }
    
    if result.numberOfRanges > 1, let range = Range(result.range(at: 1), in: text2) {
        let substring = text2[range]
        print("1: "+String(substring))
    }
    
    if result.numberOfRanges > 2, let range = Range(result.range(at: 2), in: text2) {
        let substring = text2[range]
        print("2: "+String(substring))
    }
    
    if result.numberOfRanges > 3, let range = Range(result.range(at: 3), in: text2) {
        let substring = text2[range]
        print("3: "+String(substring))
    }
    
    if result.numberOfRanges > 4, let range = Range(result.range(at: 4), in: text2) {
        let substring = text2[range]
        print("4: "+String(substring))
    }
}
*/
