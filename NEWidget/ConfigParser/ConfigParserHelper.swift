//
//  ConfigParserHelper.swift
//  NEWidget
//
//  Created by Hao Wang on 2018/7/5.
//  Copyright © 2018 Tuluobo. All rights reserved.
//

import NEKit
import Yaml

class ConfigParserHelper {
    
    private(set) var proxyPort: Int?
    private(set) var ruleManager: RuleManager!
    
    init(with configString: String) throws {
        let config = try Yaml.load(configString)
        if let port = config["port"].int {
            proxyPort = port
        }
        let adapterFactoryManager = try AdapterFactoryParser.parseAdapterFactoryManager(config["adapter"])
        ruleManager = try RuleParser.parseRuleManager(config["rule"], adapterFactoryManager: adapterFactoryManager)
    }
}

extension Yaml {
    var stringOrIntString: Swift.String? {
        return string ?? int?.description
    }
}
