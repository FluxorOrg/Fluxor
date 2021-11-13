/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

/// A `Interceptor` to use when debugging. Every `Action`s and `State` change are printed to the console.
public class PrintInterceptor<State: Encodable>: Interceptor {
    private let print: (String) -> Void
    private var name: String { String(describing: type(of: self)) }

    /// Initializes the `PrintInterceptor`.
    public convenience init() {
        self.init(print: { Swift.print($0) })
    }

    internal init(print: @escaping (String) -> Void) {
        self.print = print
    }

    /**
     The function called when an `Action` is dispatched on a `Store`.

     - Parameter action: The `Action` dispatched
     - Parameter oldState: The `State` before the `Action` was dispatched
     - Parameter newState: The `State` after the `Action` was dispatched
     */
    public func actionDispatched(action: Action, oldState: State, newState: State) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let actionLog = getActionLog(for: action, encoder: encoder)
        self.print(actionLog)

        guard let stateLog = getStateLog(for: newState, encoder: encoder) else { return }
        self.print(stateLog)
    }

    private func getActionId(for action: Action) -> String {
        if let action = action as? IdentifiableAction {
            return "\"\(action.id)\""
        }
        return String(describing: type(of: action))
    }

    private func getActionLog(for action: Action, encoder: JSONEncoder) -> String {
        let actionName = getActionId(for: action)
        var actionLog = "\(name) - action dispatched: \(actionName)"
        if Mirror(reflecting: action).children.count > 0 {
            if let encodableAction = action as? EncodableAction,
               let actionData = encodableAction.encode(with: encoder),
               let actionJSON = String(data: actionData, encoding: .utf8),
               actionJSON.replacingOccurrences(of: "\n", with: "") != "{}" {
                actionLog += ", data: \(actionJSON)"
            } else {
                actionLog += "\n⚠️ The payload of the Action has properties but aren't Encodable."
                actionLog += " Make it Encodable to get them printed."
            }
        }
        return actionLog
    }

    private func getStateLog(for state: State, encoder: JSONEncoder) -> String? {
        guard let stateData = try? encoder.encode(state),
              let newStateJSON = String(data: stateData, encoding: .utf8) else { return nil }
        return "\(name) - state changed to: \(newStateJSON)"
    }
}
