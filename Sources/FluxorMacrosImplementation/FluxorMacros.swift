import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct FluxorActionMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let actionName = if let argument = node.arguments?.as(LabeledExprListSyntax.self)?.first?.expression.as(StringLiteralExprSyntax.self),
                            let segment = argument.segments.first?.as(StringSegmentSyntax.self) {
            segment.content.text
        } else {
            declarationName(for: declaration)
        }

        return [
            "public static let fluxorActionName = \(literal: actionName)"
        ]
    }

    private static func declarationName(for declaration: some DeclGroupSyntax) -> String {
        if let declaration = declaration.as(StructDeclSyntax.self) {
            declaration.name.text
        } else if let declaration = declaration.as(ClassDeclSyntax.self) {
            declaration.name.text
        } else if let declaration = declaration.as(EnumDeclSyntax.self) {
            declaration.name.text
        } else if let declaration = declaration.as(ActorDeclSyntax.self) {
            declaration.name.text
        } else {
            "UnknownAction"
        }
    }
}

public struct FluxorSelectorMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let variable = declaration.as(VariableDeclSyntax.self),
              let binding = variable.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              let initializer = binding.initializer?.value else {
            return []
        }

        return [
            "static let \(raw: identifier)Selector = Selector(\(initializer))"
        ]
    }
}

public struct FluxorEffectsMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let effectNames = declaration.memberBlock.members.compactMap { member -> String? in
            guard let variable = member.decl.as(VariableDeclSyntax.self) else { return nil }
            guard let binding = variable.bindings.first else { return nil }
            guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else { return nil }
            let annotation = binding.typeAnnotation?.type.trimmedDescription ?? ""
            let initializer = binding.initializer?.value.trimmedDescription ?? ""
            let effectSource = "\(annotation) \(initializer)"
            return effectSource.contains("Effect") ? identifier : nil
        }

        let arrayContents = effectNames.joined(separator: ", ")
        return [
            """
            public var effects: [Effect<State, Environment>] {
                [\(raw: arrayContents)]
            }
            """
        ]
    }
}
