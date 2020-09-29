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

public final class JSScheduler: Scheduler {
  private final class CancellableTimer: Cancellable {
    let cancellation: () -> ()

    init(_ cancellation: @escaping () -> ()) {
      self.cancellation = cancellation
    }

    func cancel() {
      cancellation()
    }
  }

  public struct SchedulerTimeType: Strideable {
    let millisecondsValue: Double

    public func advanced(by n: Stride) -> Self {
      .init(millisecondsValue: millisecondsValue + n.magnitude)
    }

    public func distance(to other: Self) -> Stride {
      .init(millisecondsValue: other.millisecondsValue - millisecondsValue)
    }

    public struct Stride: SchedulerTimeIntervalConvertible, Comparable, SignedNumeric {
      /// Time interval magnitude in milliseconds
      public var magnitude: Double

      public init?<T>(exactly source: T) where T: BinaryInteger {
        guard let magnitude = Double(exactly: source) else { return nil }
        self.magnitude = magnitude
      }

      public init(millisecondsValue: Double) {
        magnitude = millisecondsValue
      }

      public init(floatLiteral value: Double) {
        self = .seconds(value)
      }

      public init(integerLiteral value: Int) {
        self = .seconds(value)
      }

      public static func microseconds(_ us: Int) -> Self {
        .init(millisecondsValue: 1.0 / (Double(us) * 1000))
      }

      public static func milliseconds(_ ms: Int) -> Self {
        .init(millisecondsValue: Double(ms))
      }

      public static func nanoseconds(_ ns: Int) -> Self {
        .init(millisecondsValue: 1.0 / (Double(ns) * 1_000_000))
      }

      public static func seconds(_ s: Double) -> Self {
        .init(millisecondsValue: s * 1000)
      }

      public static func seconds(_ s: Int) -> Self {
        .init(millisecondsValue: Double(s) * 1000)
      }

      public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.magnitude < rhs.magnitude
      }

      public static func * (lhs: Self, rhs: Self) -> Self {
        .init(millisecondsValue: lhs.magnitude * rhs.magnitude)
      }

      public static func + (lhs: Self, rhs: Self) -> Self {
        .init(millisecondsValue: lhs.magnitude + rhs.magnitude)
      }

      public static func - (lhs: Self, rhs: Self) -> Self {
        .init(millisecondsValue: lhs.magnitude - rhs.magnitude)
      }

      public static func -= (lhs: inout Self, rhs: Self) {
        lhs.magnitude -= rhs.magnitude
      }

      public static func *= (lhs: inout Self, rhs: Self) {
        lhs.magnitude *= rhs.magnitude
      }

      public static func += (lhs: inout Self, rhs: Self) {
        lhs.magnitude += rhs.magnitude
      }
    }
  }

  public struct SchedulerOptions {}

  public var now: SchedulerTimeType { .init(millisecondsValue: JSDate.now()) }

  public var minimumTolerance: SchedulerTimeType.Stride {
    .init(millisecondsValue: .leastNonzeroMagnitude)
  }

  private var scheduledTimers = [ObjectIdentifier: JSTimer]()

  public func schedule(options: SchedulerOptions?, _ action: @escaping () -> ()) {
    var timer: JSTimer!
    timer = .init(millisecondsDelay: 0) { [weak self, weak timer] in
      action()
      if let timer = timer {
        self?.scheduledTimers[ObjectIdentifier(timer)] = nil
      }
    }
    scheduledTimers[ObjectIdentifier(timer)] = timer
  }

  public func schedule(
    after date: SchedulerTimeType,
    tolerance: SchedulerTimeType.Stride,
    options: SchedulerOptions?,
    _ action: @escaping () -> ()
  ) {
    var timer: JSTimer!
    timer = .init(
      millisecondsDelay: date.millisecondsValue - JSDate.now()
    ) { [weak self, weak timer] in
      action()
      if let timer = timer {
        self?.scheduledTimers[ObjectIdentifier(timer)] = nil
      }
    }
    scheduledTimers[ObjectIdentifier(timer)] = timer
  }

  public func schedule(
    after date: SchedulerTimeType,
    interval: SchedulerTimeType.Stride,
    tolerance: SchedulerTimeType.Stride,
    options: SchedulerOptions?,
    _ action: @escaping () -> ()
  ) -> Cancellable {
    var timeoutTimer, intervalTimer: JSTimer!

    timeoutTimer = .init(
      millisecondsDelay: date.millisecondsValue - JSDate.now()
    ) { [weak self, weak timeoutTimer] in
      intervalTimer = .init(millisecondsDelay: interval.magnitude) { action() }

      self?.scheduledTimers[ObjectIdentifier(intervalTimer)] = intervalTimer

      if let timeoutTimer = timeoutTimer {
        self?.scheduledTimers[ObjectIdentifier(timeoutTimer)] = nil
      }
    }
    scheduledTimers[ObjectIdentifier(timeoutTimer)] = timeoutTimer

    return CancellableTimer { self.scheduledTimers[ObjectIdentifier(intervalTimer)] = nil }
  }
}
