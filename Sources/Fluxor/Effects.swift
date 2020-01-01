//
//  Effects.swift
//  Fluxor
//
//  Created by Morten Bjerg Gregersen on 31/10/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

import Combine

public typealias ActionPublisher = Published<Action>.Publisher

public protocol Effects: AnyObject  {
    var effects: [Effect] { get }
    init(_ actions: ActionPublisher)
}

public enum Effect {
    case dispatching(_ publisher: AnyPublisher<Action, Never>)
    case nonDispatching(_ cancellable: AnyCancellable)
}
