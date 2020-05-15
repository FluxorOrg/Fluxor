/**
 * FluxorSwiftUI
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Combine
import Fluxor

public class ObservableValue<State: Encodable, Value>: ObservableObject {
    public private(set) var value: Value { willSet { objectWillChange.send() } }
    private var cancellable: AnyCancellable!

    public init(store: Store<State>, selector: Selector<State, Value>) {
        self.value = store.selectCurrent(selector)
        self.cancellable = store.select(selector).sink { self.value = $0 }
    }
}
