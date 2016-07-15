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

// MARK: Queue

public class Queue {
    
    ///
    /// Handle to the libDispatch queue
    ///
    #if os(Linux)
    public let osQueue: dispatch_queue_t
    #else
    public let osQueue: DispatchQueue
    #endif
    
    ///
    /// Initializes a Queue instance
    ///
    /// - Parameter type:  QueueType (serial or parallel)
    /// - Parameter label: Optional String describing the Queue
    ///
    /// - Returns: Queue instance
    ///
    public init(type: QueueType, label: String?=nil) {
        #if os(Linux)
            let concurrent = DISPATCH_QUEUE_CONCURRENT
            let serial = DISPATCH_QUEUE_SERIAL
            
            osQueue = dispatch_queue_create(label != nil ? label! : "",
                                            type == .parallel ? concurrent : serial)            
        #else
            osQueue =  DispatchQueue(label: label != nil ? label! : "",
                                     attributes: type == .parallel ? [.concurrent] : [.serial])
        #endif
    }
    
    
    ///
    /// Run a block asynchronously
    ///
    /// - Parameter block: a closure () -> Void
    ///
    public func enqueueAsynchronously(_ block: () -> Void) {
        #if os(Linux)
            dispatch_async(osQueue, block)
        #else
            osQueue.async(execute: block)
        #endif
    }
    
    ///
    /// Run a block synchronously
    ///
    /// - Parameter block: a closure () -> Void
    ///
    public func enqueueSynchronously(_ block: () -> Void) {
        #if os(Linux)
            dispatch_sync(osQueue, block)
        #else
            osQueue.sync(execute: block)
        #endif
    }
}

///
/// QueueType values
///
public enum QueueType {
    
    case serial, parallel
    
}
