//
//  main.swift
//  stringslint
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Commandant
import Dispatch
import StringsLintFramework

DispatchQueue.global().async {
    let registry = CommandRegistry<CommandantError<()>>()
    registry.register(LintCommand())
    registry.register(VersionCommand())
    registry.register(HelpCommand(registry: registry))
    
    registry.main(defaultVerb: LintCommand().verb) { error in
        queuedPrintError(String(describing: error))
    }
}

dispatchMain()
