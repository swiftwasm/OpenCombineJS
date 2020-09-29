import JavaScriptKit
import OpenCombine
import OpenCombineJS

private let _jsFetch = JSObject.global.fetch.function!
func fetch(_ url: String) -> JSPromise<JSObject, JSError> {
  JSPromise(_jsFetch(url).object!)!
}

let document = JSObject.global.document.object!
let p = document.createElement!("p").object!
_ = document.body.object!.appendChild!(p)

var subscription: AnyCancellable?

let timer = JSTimer(millisecondsDelay: 2000, isRepeating: true) {
  subscription = fetch("https://httpbin.org/uuid")
    .publisher
    .flatMap { (response: JSObject) -> JSPromise<JSValue, JSError>.PromisePublisher in
      JSPromise<JSValue, JSError>(response.json!().object!)!.publisher
    }
    .mapError { $0 as Error }
    .map { Result<String, Error>.success($0.object!.uuid.string!) }
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
