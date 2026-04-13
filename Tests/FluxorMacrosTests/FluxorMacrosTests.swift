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

    func testFluxorSelectorRequiresStaticStoredProperty() throws {
        #if canImport(FluxorMacrosImplementation)
        assertMacroExpansion(
            """
            struct Selectors {
                @FluxorSelector
                let count = \\AppState.count
            }
            """,
            expandedSource: """
            struct Selectors {
                let count = \\AppState.count
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@FluxorSelector requires a static stored property with an initializer.",
                    line: 2,
                    column: 5
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("Macro tests only run on the host platform.")
        #endif
    }

    func testFluxorEffectsWarnsWhenNoEffectsAreFound() throws {
        #if canImport(FluxorMacrosImplementation)
        assertMacroExpansion(
            """
            @FluxorEffects
            struct FeatureEffects: Effects {
                typealias State = AppState
                typealias Environment = AppEnvironment
            }
            """,
            expandedSource: """
            struct FeatureEffects: Effects {
                typealias State = AppState
                typealias Environment = AppEnvironment

                public var effects: [Effect<State, Environment>] {
                    []
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@FluxorEffects did not find any effect members to include.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("Macro tests only run on the host platform.")
        #endif
    }
}
