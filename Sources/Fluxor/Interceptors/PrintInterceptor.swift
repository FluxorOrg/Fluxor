/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

/// An interceptor to use when debugging. Every action and state change is printed.
@MainActor
public final class PrintInterceptor<State: Encodable>: Interceptor {
    private let printClosure: (String) -> Void
    private var name: String { String(describing: type(of: self)) }

    public convenience init() {
        self.init(print: { Swift.print($0) })
    }

    internal init(print: @escaping (String) -> Void) {
        printClosure = print
    }

    public func actionDispatched(action: any Action, oldState: State, newState: State) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        printClosure(getActionLog(for: action, encoder: encoder))
        if let stateLog = getStateLog(for: newState, encoder: encoder) {
            printClosure(stateLog)
        }
    }

    private func getActionLog(for action: any Action, encoder: JSONEncoder) -> String {
        var actionLog = "\(name) - action dispatched: \(ActionMetadata.name(of: action))"
        if Mirror(reflecting: action).children.isEmpty {
            return actionLog
        }

        if let encodableAction = action as? any EncodableAction,
           let actionData = try? encodableAction.encode(with: encoder),
           let actionJSON = String(data: actionData, encoding: .utf8),
           actionJSON != "{}" {
            actionLog += ", data: \(actionJSON)"
        } else {
            actionLog += "\n⚠️ The payload of the Action has properties but is not Encodable."
        }
        return actionLog
    }

    private func getStateLog(for state: State, encoder: JSONEncoder) -> String? {
        guard let stateData = try? encoder.encode(state),
              let stateJSON = String(data: stateData, encoding: .utf8) else {
            return nil
        }

        return "\(name) - state changed to: \(stateJSON)"
    }
}
