/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2026
 *  MIT license, see LICENSE file for details
 */

@attached(member, names: named(fluxorActionName))
public macro FluxorAction(_ name: String? = nil) = #externalMacro(
    module: "FluxorMacrosImplementation",
    type: "FluxorActionMacro"
)

@attached(peer, names: suffixed(Selector))
public macro FluxorSelector() = #externalMacro(
    module: "FluxorMacrosImplementation",
    type: "FluxorSelectorMacro"
)

@attached(member, names: named(effects))
public macro FluxorEffects() = #externalMacro(
    module: "FluxorMacrosImplementation",
    type: "FluxorEffectsMacro"
)
