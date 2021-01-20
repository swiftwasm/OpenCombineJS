// Copyright 2020 OpenCombineJS contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import JavaScriptKit
import OpenCombine

public extension JSPromise {
  final class PromisePublisher: Publisher {
    public typealias Output = JSValue
    public typealias Failure = JSValue

    /// `Future` instance that handles subscriptions to this publisher.
    private var future: Future<JSValue, JSValue>

    fileprivate init(promise: JSPromise) {
      future = .init { resolver in
        promise.then(success: {
          resolver(.success($0))
          return JSValue.undefined
        }, failure: {
          resolver(.failure($0))
          return JSValue.undefined
        })
      }
    }

    public func receive<Downstream: Subscriber>(subscriber: Downstream)
      where Downstream.Input == JSValue, Downstream.Failure == JSValue
    {
      future.receive(subscriber: WrappingSubscriber(inner: subscriber))
    }
  }

  /// Creates a new publisher for this `JSPromise` instance.
  var publisher: PromisePublisher {
    .init(promise: self)
  }

  /** Helper type that wraps a given `inner` subscriber and holds references to both stored promises
   of `PromisePublisher`, as `PromisePublisher` itself can be deallocated earlier than its
   subscribers.
   */
  private struct WrappingSubscriber<Inner: Subscriber>: Subscriber {
    typealias Input = Inner.Input
    typealias Failure = Inner.Failure

    let inner: Inner

    var combineIdentifier: CombineIdentifier { inner.combineIdentifier }

    func receive(subscription: Subscription) {
      inner.receive(subscription: subscription)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
      inner.receive(input)
    }

    func receive(completion: Subscribers.Completion<Failure>) {
      inner.receive(completion: completion)
    }
  }
}
