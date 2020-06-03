# Testing `Selector`s

In Fluxor `Selector`s are projectors of `State`.  `Selector`s can be created by a `KeyPath`, by a closure or based on up to 5 other `Selector`s.
When a `Selector` is based on other `Selector`s, the projector takes the `Value`s from the others as parameters.

The `Selector`'s `map` function takes the `State` and returns a `Value`.

Because of the simple nature of a `Selector`, it is also simple to test them.


