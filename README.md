# OpenCombineJS

[OpenCombine](https://github.com/OpenCombine/OpenCombine) helpers for JavaScriptKit/WebAssembly
APIs. Currently it provides:

- A `JSScheduler` class that implements [the `Scheduler`
  protocol](https://developer.apple.com/documentation/combine/scheduler). This allows you to use
  time-dependent Combine operators such as
  [`measureInterval`](<https://developer.apple.com/documentation/combine/publisher/measureinterval(using:options:)>),
  [`debounce`](<https://developer.apple.com/documentation/combine/publisher/debounce(for:scheduler:options:)>),
  [`throttle`](<https://developer.apple.com/documentation/combine/publisher/throttle(for:scheduler:latest:)>),
  and
  [`timeout`](<https://developer.apple.com/documentation/combine/publisher/timeout(_:scheduler:options:customerror:)>)
  in a browser environment.
- A [`TopLevelDecoder`](https://developer.apple.com/documentation/combine/topleveldecoder)
  implementation on [`JSValueDecoder`](https://swiftwasm.github.io/JavaScriptKit/JSValueDecoder/).
- A `publisher` property on [`JSPromise`](https://swiftwasm.github.io/JavaScriptKit/JSPromise/),
  which converts your [JavaScript `Promise`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) instances to Combine publishers.

## Example

Here's an example of a timer that fetches a UUID from a remote server every second, parses it
with `JSValueDecoder`, and then displays the result as text:

```swift
import JavaScriptKit
import OpenCombine
import OpenCombineJS

private let jsFetch = JSObject.global.fetch.function!
func fetch(_ url: String) -> JSPromise {
  JSPromise(jsFetch(url).object!)!
}

let document = JSObject.global.document
var p = document.createElement("p")
_ = document.body.appendChild(p)

var subscription: AnyCancellable?

let timer = JSTimer(millisecondsDelay: 1000, isRepeating: true) {
  subscription = fetch("https://httpbin.org/uuid")
    .publisher
    .flatMap {
      JSPromise($0.json().object!)!.publisher
    }
    .mapError { $0 as Error }
    .map { Result<String, Error>.success($0.uuid.string!) }
    .catch { Just(.failure($0)) }
    .sink {
      let time = JSDate().toLocaleTimeString()
      switch $0 {
      case let .success(uuid):
        p.innerText = .string("At \(time) received uuid \(uuid)")
      case let .failure(error):
        p.innerText = .string("At \(time) received error \(error)")
      }
    }
}
```
