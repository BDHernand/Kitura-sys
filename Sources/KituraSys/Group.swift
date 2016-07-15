/**
 * Copyright IBM Corporation 2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Dispatch

// MARK: Group

public class Group {
    
    public init() {}
    
    #if os(Linux)
    private let osGroup = dispatch_group_create()
    #else
    private let osGroup = DispatchGroup()
    #endif
    
    ///
    /// Run a block asynchronously
    ///
    /// - Parameter block: a closure () -> Void
    ///
    public func enqueueAsynchronously(on queue: Queue, block: () -> Void) {
        #if os(Linux)
            dispatch_group_async(osGroup, queue.osQueue, block)
        #else
            queue.osQueue.async(group: osGroup, execute: block)
        #endif
    }
    
    ///
    /// Wait synchronously for asynchronous blocks to complete
    ///
    public func wait(for timeout: GroupTimeout) {
        #if os(Linux)
            let osTimeout: dispatch_time_t
        #else
            let osTimeout: DispatchTime
        #endif
        switch(timeout) {
        case .ever:
            #if os(Linux)
                osTimeout = DISPATCH_TIME_FOREVER
            #else
                osTimeout = DispatchTime.distantFuture
            #endif
        case .seconds(let seconds):
            #if os(Linux)
                osTimeout = dispatch_time(DISPATCH_TIME_NOW, seconds * Int64(NSEC_PER_SEC))
            #else
                osTimeout = DispatchTime.now() + DispatchTimeInterval.seconds(Int(seconds))
            #endif
        case .milliSeconds(let milliSeconds):
            #if os(Linux)
                osTimeout = dispatch_time(DISPATCH_TIME_NOW, milliSeconds * Int64(NSEC_PER_USEC))
            #else
                osTimeout = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(milliSeconds))
            #endif
        case .nanoSeconds(let nanoSeconds):
            #if os(Linux)
                osTimeout = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
            #else
                osTimeout = DispatchTime.now() + DispatchTimeInterval.nanoseconds(Int(nanoSeconds))
            #endif
        }
        #if os(Linux)
            dispatch_group_wait(osGroup, osTimeout)
        #else
            _ = osGroup.wait(timeout: osTimeout)
        #endif
    }
}

///
/// Timeout values
///
public enum GroupTimeout {
    case ever, seconds(Int64), milliSeconds(Int64), nanoSeconds(Int64)
}
