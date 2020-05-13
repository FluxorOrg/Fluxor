/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Fluxor

public class ObservableValue<State: Encodable, Value>: ObservableObject {
    public private(set) var value: Value { willSet { objectWillChange.send() } }

    internal let store: Fluxor.Store<State>
    internal let selector: Fluxor.Selector<State, Value>
    private var cancellable: AnyCancellable!

    public init(store: Fluxor.Store<State>,
                selector: Fluxor.Selector<State, Value>) {
        self.store = store
        self.selector = selector
        self.value = store.selectCurrent(selector)
        self.cancellable = self.store.select(selector).sink { self.value = $0 }
    }
}
