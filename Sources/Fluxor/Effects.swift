//
//  Effects.swift
//  Fluxor
//
//  Created by Morten Bjerg Gregersen on 31/10/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

import Combine

public typealias ActionPublisher = Published<Action>.Publisher
public typealias DispatchingEffect = AnyPublisher<Action, Never>
public typealias NonDispatchingEffect = AnyCancellable

public protocol Effects: AnyObject  {
    var dispatchingEffects: [DispatchingEffect] { get }
    var nonDispatchingEffects: [NonDispatchingEffect] { get }
    init(_ actions: ActionPublisher)
}
