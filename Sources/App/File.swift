//
//  File.swift
//  
//
//  Created by mostfa on 8/5/20.
//
#warning("CHECKING THAT FIRST INDEX = LAST INNDEX, IS THAT OKAY ? OR WILL LEAD TO BUGS?")
import Foundation
import SourceKittenFramework

struct SKittenParser  {

  var file : File?

  init(for file: File) {
    self.file = file
  }

  var response: SourceKittenResponse?
  init(for response: SourceKittenResponse, from file: File) {
    self.response = response
    self.file = file
  }


  //MARK: - Decoding file -

  func decode() throws -> SKittenParser {
    guard let file = file else { throw SKittenError.fileInitliazation }
    guard let structure = try SourceKittenFramework.Structure(file: file).description.data(using: .utf8) else { throw SKittenError.structureError }

    do {
      let json =  try JSONDecoder().decode(SourceKittenResponse.self, from: structure)
        return .init(for: json,from: file)

    } catch (let error) {
      throw SKittenError.decodeError(error: error)
    }

  }

  //MARK: - Model to Json -

  func extractDefaultValues() throws -> [JsonSchema] {
    guard let file = self.file else { throw SKittenError.fileInitliazation }
    guard let response = self.response else { throw  SKittenError.jsonInitlization }

    let sourceCode = file.contents
    var modelNames = [String]()
    var realReturn = [JsonSchema]()
    var firstIndex = 0
    var secondIndex = 1
    for model in response.models {
      modelNames.append(model.name)

      var properties = [JsonSchema.Property]()
      for (index,property) in model.propertiesO.enumerated() {
        let nextIndex = index + 1
        if nextIndex <= model.propertiesO.count - 1 {

          let value =  defaultValueFinder(firstIndex: property.chars,
                                          secondIndex: model.propertiesO[nextIndex].chars,
                                          sourceCode: sourceCode)
          let cleanedValue = cleanValue(for: value,isLast: false)
          properties.append(.init(name: property.name ?? "NO_NAME_ENTERED", type: property.type!, value: cleanedValue))

          #warning("add auto detection to the type if possible for simple types")
        } else {
          let lastValue = lastValueFinder(lastIndex: property.chars, sourceCode: sourceCode)

          let cleanedValue = (cleanValue(for: lastValue, isLast: true))
          properties.append(.init(name: property.name ?? "NO_NAME_ENTERED", type: property.type!, value: cleanedValue))
        }
      }
      let schema = JsonSchema(modelName: model.name, property: properties)
      realReturn.append(schema)
      //    realReturn.append(.init(modelName: model.name, property: ))
//      testInit.append(arr)
      firstIndex += 1
      secondIndex += 1
    }
    return realReturn
  }

  //MARK: - default values Finder -

  func defaultValueFinder(firstIndex: Range<Int>?, secondIndex: Range<Int>? , sourceCode: String) -> String {
    //TODO: should do special check if secondnIndex is not avaliable = means we are at the end of the file
    guard let firstIndex = firstIndex else { return "WRONG INDEX!" }
    guard let secondIndex = secondIndex else  { return "WRONG INDEX!" }
    let startIndex = sourceCode.index(sourceCode.startIndex, offsetBy: firstIndex.upperBound + 1)
    let endIndex = sourceCode.index(sourceCode.startIndex, offsetBy: secondIndex.lowerBound - 1)
    let range = startIndex...endIndex

    return String(sourceCode[range])
    //.trimmingCharacters(in: .whitespaces) O(N), not needed since it won't reduce much of the needed steps later
  }

  func lastValueFinder(lastIndex: Range<Int>?, sourceCode: String) -> String {
    guard let lastIndex = lastIndex else { return ""}

    //TODO: - We need to find a better way to search forh the } if avaliable ?
    var lastLetterIndex =  sourceCode.index(sourceCode.startIndex, offsetBy: lastIndex.upperBound)

    #warning("add check if } there's no at all!")
    while sourceCode[lastLetterIndex] != "}" {
      sourceCode.formIndex(after: &lastLetterIndex)

    }

    let first = sourceCode.index(sourceCode.startIndex, offsetBy: lastIndex.upperBound)
    return String(sourceCode[first ... lastLetterIndex])
    //.trimmingCharacters(in: .whitespaces) O(N), not needed since it won't reduce much of the needed steps later
  }




  //MARK: - Value cleaners -

  func cleanValue(for value: String,isLast: Bool) -> String {
    if let stringValue = cleanStringValues(for: value, isLast: isLast) {
      return stringValue
    } else if let NotStringValue = cleanAnyValue(for: value, isLast: isLast) {
      return NotStringValue
    }
    return ""
  }

  func cleanStringValues(for value: String,isLast: Bool) -> String? {

    guard let firxtIndex = value.firstIndex(of: "\""),
      let lastIndex = value.lastIndex(of: isLast ? "}": "\""),
      firxtIndex != lastIndex else { return nil }

    return String(value[firxtIndex ... lastIndex])

  }

  func cleanAnyValue(for value: String, isLast: Bool) -> String? {

    guard var searchIndex = value.firstIndex(of: "=") else { return nil }
    //search for equal sign
    while value[searchIndex] != "=" {
      value.formIndex(after: &searchIndex)
    }

    //search for } if  not found search for \n, if not found, then use the lastIndex in the string
    let lastIndex = value.firstIndex(of: isLast ? "}": "\n") != nil ?
      value.firstIndex(of: isLast ? "}": "\n")!: value.endIndex

    return String(value[ value.index(after: searchIndex) ... value.index(before: lastIndex)]).trimmingCharacters(in: .whitespaces)

  }






}


//MARK: - Helper types -

enum SKittenError: Error {
  case decodeError(error: Error)
  case structureError
  case fileInitliazation
  case jsonInitlization
  case defaultStringNotFound(inValue: String)

}



struct JsonSchema {
  var modelName: String?
  var property:[Property]?
  var childs: [JsonSchema] = []

  struct Property {
    var name: String
    var type: String
    var value: String
  }

}
