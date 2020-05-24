/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

/// A `Interceptor` to use when debugging. Every `Action`s and `State` change are printed ot the console.
public class PrintInterceptor<State: Encodable>: Interceptor {
    private let print: (String) -> Void

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
        encoder.outputFormatting = .prettyPrinted
        let name = String(describing: type(of: self))

        let actionName = String(describing: type(of: action))
        var actionLog = "\(name) - action dispatched: \(actionName)"
        if let actionData = action.encode(with: encoder),
            let actionJSON = String(data: actionData, encoding: .utf8),
            actionJSON.replacingOccurrences(of: "\n", with: "") != "{}" {
            actionLog += ", data: \(actionJSON)"
        }
        self.print(actionLog)

        if let stateData = try? encoder.encode(newState),
            let newStateJSON = String(data: stateData, encoding: .utf8) {
            self.print("\(name) - state changed to: \(newStateJSON)")
        }
    }
}
