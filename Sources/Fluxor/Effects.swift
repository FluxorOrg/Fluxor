/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

@MainActor
public final class EffectContext<State: Sendable, Environment: Sendable> {
    private unowned let store: Store<State, Environment>
    public let environment: Environment

    init(store: Store<State, Environment>) {
        self.store = store
        environment = store.environment
    }

    public var state: State { store.state }
    public var isCancelled: Bool { Task.isCancelled }

    public func send(_ action: some Action) {
        store.send(action)
    }

    public func current<Value>(_ selector: Selector<State, Value>) -> Value {
        store.current(selector)
    }

    public func finishIfCancelled() throws {
        if Task.isCancelled {
            throw CancellationError()
        }
    }
}

public struct Effect<State: Sendable, Environment: Sendable> {
    public let id: String
    let handleAction: @MainActor (_ action: any Action, _ context: EffectContext<State, Environment>) async -> Bool

    public static func on<A: Action>(
        _ actionType: A.Type = A.self,
        id: String = String(describing: A.self),
        _ handler: @escaping @MainActor (_ action: A, _ context: EffectContext<State, Environment>) async -> Void
    ) -> Effect<State, Environment> {
        .init(id: id) { action, context in
            guard let typedAction = action as? A else { return false }
            await handler(typedAction, context)
            return true
        }
    }

    init(
        id: String,
        handleAction: @escaping @MainActor (_ action: any Action, _ context: EffectContext<State, Environment>) async -> Bool
    ) {
        self.id = id
        self.handleAction = handleAction
    }
}

public protocol Effects {
    associatedtype State: Sendable
    associatedtype Environment: Sendable

    var effects: [Effect<State, Environment>] { get }
    static var id: String { get }
}

public extension Effects {
    static var id: String { String(describing: Self.self) }
}
