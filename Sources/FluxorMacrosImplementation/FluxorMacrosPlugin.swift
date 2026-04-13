import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct FluxorMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FluxorActionMacro.self,
        FluxorSelectorMacro.self,
        FluxorEffectsMacro.self,
    ]
}
