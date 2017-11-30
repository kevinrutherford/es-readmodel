# EsReadModel

An opinionated read model framework for EventStore.

Your reducer can be anything that responds to #call.
It will receive two arguments -- the current state and the event.
The current state will be nil if no events have bee processed yet.
The reducer function must return the new state.

