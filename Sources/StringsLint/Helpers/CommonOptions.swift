//
//  CommonOptions.swift
//  stringslint
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Commandant
import StringsLintFramework

func pathOption(action: String) -> Option<String> {
    return Option(key: "path",
                  defaultValue: "",
                  usage: "the path to the file or directory to \(action)")
}

func pathsArgument(action: String) -> Argument<[String]> {
    return Argument(defaultValue: [""],
                    usage: "list of paths to the files or directories to \(action)")
}

let configOption = Option(key: "config",
                          defaultValue: Configuration.fileName,
                          usage: "the path to StringsLint's configuration file")
