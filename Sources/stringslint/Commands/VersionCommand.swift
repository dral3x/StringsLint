//
//  VersionCommand.swift
//  stringslint
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Commandant
import StringsLintFramework

struct VersionCommand: CommandProtocol {
    let verb = "version"
    let function = "Display the current version of StringsLint"
    
    func run(_ options: NoOptions<CommandantError<()>>) -> Result<(), CommandantError<()>> {
        print(Version.current.value)
        return .success(())
    }
}
