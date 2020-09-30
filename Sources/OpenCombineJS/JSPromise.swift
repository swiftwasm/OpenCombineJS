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

extension JSPromise where Success: JSValueConstructible, Failure: JSError {
  public final class PromisePublisher: Publisher {
    public typealias Output = Success

    /// Reference to a parent promise instance to prevent early deallocation
    private var parent: JSPromise?

    /// Reference to a `then` success callback promise instance to prevent early deallocation
    private var then: JSPromise<JSValue, Failure>?

    /// `Future` instance that handles subscriptions to this publisher.
    private var future: Future<Success, Failure>?

    fileprivate init(parent: JSPromise) {
      future = .init { [weak self] resolver in
        let then = parent.then { value -> JSValue in
          resolver(.success(value))
          return .undefined
        }

        then.catch {
          resolver(.failure($0))
        }
        self?.then = then
      }
      self.parent = parent
    }

    public func receive<Downstream: Subscriber>(subscriber: Downstream)
      where Success == Downstream.Input, Failure == Downstream.Failure
    {
      guard let parent = parent, let then = then, let future = future else { return }

      future.receive(subscriber: WrappingSubscriber(inner: subscriber, parent: parent, then: then))
    }
  }

  /// Creates a new publisher for this `JSPromise` instance.
  public var publisher: PromisePublisher {
    .init(parent: self)
  }

  /** Helper type that wraps a given `inner` subscriber and holds references to both stored promises
   of `PromisePublisher`, as `PromisePublisher` itself can be deallocated earlier than its
   subscribers.
   */
  private struct WrappingSubscriber<Inner: Subscriber>: Subscriber {
    typealias Input = Inner.Input
    typealias Failure = Inner.Failure

    let inner: Inner
    let parent: JSPromise
    let then: JSPromise<JSValue, Failure>

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
