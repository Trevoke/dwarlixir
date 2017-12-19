# Dwarlixir
* Travis ![Travis build](https://travis-ci.org/Trevoke/dwarlixir.svg?branch=master)
* Semaphore [![Build Status](https://semaphoreci.com/api/v1/trevoke/dwarlixir/branches/master/badge.svg)](https://semaphoreci.com/trevoke/dwarlixir)

## Getting started

Make sure you have Elixir ~> 1.5.1 available.

## README-driven development

Things I need to bring back in as I switch to ECS:

- generating a world
- creating location entities
- generating mobs at startup
- putting mobs in locations
- reproduction

### components

- Age
- Mortal
- SexualReproduction (Biology? Subcomponent? Not a component at all?)
- OviparousReproduction
- AIComponent.V1

### Thoughts

What about aging; could be a separate tick for everyone (easy) or some kind of "everything ages at the same time" tick. If the latter, I need, I think, to make it possible to subscribe to _events_ in the ECS framework.
Well, my "Watcher" idea is growing old quickly isn't it.
Unless I create a Universe entity with a Tick component which could get updated with a monotonically increasing value, and that would be something that various things could watch...
