//
//  TrackerManager.swift
//  Leiter
//
//  Created by Hao Wang on 2018/6/30.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import Amplitude_iOS

class TrackerManager {

    static let shared = TrackerManager()
    private init() { }
    private let amplitudeApiKey = "190062e0d5d37ec1c1e7c59edde6005f"
    
    func setup() {
        Amplitude.instance().initializeApiKey(amplitudeApiKey)
    }
    
    func track(event: String, properties: [AnyHashable: Any]? = nil) {
        if let properties = properties {
            Amplitude.instance().logEvent(event, withEventProperties: properties)
        } else {
            Amplitude.instance().logEvent(event)
        }
    }
}
