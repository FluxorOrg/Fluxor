import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(FluxorMacrosImplementation)
import FluxorMacrosImplementation

private let testMacros: [String: Macro.Type] = [
    "FluxorAction": FluxorActionMacro.self,
    "FluxorSelector": FluxorSelectorMacro.self,
    "FluxorEffects": FluxorEffectsMacro.self,
]
#endif

final class FluxorMacrosTests: XCTestCase {
    func testFluxorActionExpansion() throws {
        #if canImport(FluxorMacrosImplementation)
        assertMacroExpansion(
            """
            @FluxorAction("Load Todos")
            struct LoadTodos: Action {}
            """,
            expandedSource: """
            struct LoadTodos: Action {

                public static let fluxorActionName = "Load Todos"
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Macro tests only run on the host platform.")
        #endif
    }

    func testFluxorSelectorExpansion() throws {
        #if canImport(FluxorMacrosImplementation)
        assertMacroExpansion(
            """
            enum Selectors {
                @FluxorSelector
                static let count = \\AppState.count
            }
            """,
            expandedSource: """
            enum Selectors {
                static let count = \\AppState.count

                static let countSelector = Selector(\\AppState.count)
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Macro tests only run on the host platform.")
        #endif
    }

    func testFluxorEffectsExpansion() throws {
        #if canImport(FluxorMacrosImplementation)
        assertMacroExpansion(
            """
            @FluxorEffects
            struct FeatureEffects: Effects {
                typealias State = AppState
                typealias Environment = AppEnvironment

                let load = Effect<State, Environment>.on(Load.self) { _, _ in }
                let save = Effect<State, Environment>.on(Save.self) { _, _ in }
            }
            """,
            expandedSource: """
            struct FeatureEffects: Effects {
                typealias State = AppState
                typealias Environment = AppEnvironment

                let load = Effect<State, Environment>.on(Load.self) { _, _ in }
                let save = Effect<State, Environment>.on(Save.self) { _, _ in }

                public var effects: [Effect<State, Environment>] {
                    [load, save]
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Macro tests only run on the host platform.")
        #endif
    }
}
