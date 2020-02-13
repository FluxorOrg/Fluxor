/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

/// A `StoreInterceptor` to use when debugging which `Action`s are dispatched.
public class PrintStoreInterceptor<State: Encodable>: StoreInterceptor {
    let print: (String) -> ()

    public convenience init() {
        self.init(print: { Swift.print($0) })
    }

    internal init(print: @escaping (String) -> ()) {
        self.print = print
    }

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
        print(actionLog)

        if let stateData = try? encoder.encode(newState),
            let newStateJSON = String(data: stateData, encoding: .utf8) {
            print("\(name) - state changed to: \(newStateJSON)")
        }
    }
}
