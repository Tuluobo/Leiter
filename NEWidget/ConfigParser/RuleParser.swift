import Foundation
import Yaml
import NEKit
import SPBaseKit

struct RuleParser {
    static func parseRuleManager(_ config: Yaml, adapterFactoryManager: AdapterFactoryManager) throws -> RuleManager {
        guard let ruleConfigs = config.array else {
            throw ConfigurationParserError.noRuleDefined
        }

        var rules: [Rule] = []

        for ruleConfig in ruleConfigs {
            rules.append(try parseRule(ruleConfig, adapterFactoryManager: adapterFactoryManager))
        }
        return RuleManager(fromRules: rules, appendDirect: true)
    }

    static func parseRule(_ config: Yaml, adapterFactoryManager: AdapterFactoryManager) throws -> Rule {
        guard let type = config["type"].string?.lowercased() else {
            throw ConfigurationParserError.ruleTypeMissing
        }

        switch type {
        case "country":
            return try parseCountryRule(config, adapterFactoryManager: adapterFactoryManager)
        case "all":
            return try parseAllRule(config, adapterFactoryManager: adapterFactoryManager)
        case "list", "domainlist":
            return try parseDomainListRule(config, adapterFactoryManager: adapterFactoryManager)
        case "iplist":
            return try parseIPRangeListRule(config, adapterFactoryManager: adapterFactoryManager)
        case "dnsfail":
            return try parseDNSFailRule(config, adapterFactoryManager: adapterFactoryManager)
        default:
            throw ConfigurationParserError.unknownRuleType
        }
    }

    static func parseCountryRule(_ config: Yaml, adapterFactoryManager: AdapterFactoryManager) throws -> CountryRule {
        guard let country = config["country"].string else {
            throw ConfigurationParserError.ruleParsingError(errorInfo: "Country code (country) is required for country rule.")
        }

        guard let adapter_id = config["adapter"].stringOrIntString else {
            throw ConfigurationParserError.ruleParsingError(errorInfo: "An adapter id (adapter_id) is required.")
        }

        guard let adapter = adapterFactoryManager[adapter_id] else {
            throw ConfigurationParserError.ruleParsingError(errorInfo: "Unknown adapter id.")
        }

        guard let match = config["match"].bool else {
            throw ConfigurationParserError.ruleParsingError(errorInfo: "You have to specify whether to apply this rule to ip match the given country or not with \"match\".")
        }

        return CountryRule(countryCode: country, match: match, adapterFactory: adapter)
    }

    static func parseAllRule(_ config: Yaml, adapterFactoryManager: AdapterFactoryManager) throws -> AllRule {
        guard let adapter_id = config["adapter"].stringOrIntString else {
            throw ConfigurationParserError.ruleParsingError(errorInfo: "An adapter id (adapter_id) is required.")
        }

        guard let adapter = adapterFactoryManager[adapter_id] else {
            throw ConfigurationParserError.ruleParsingError(errorInfo: "Unknown adapter id.")
        }

        return AllRule(adapterFactory: adapter)
    }

    static func parseDomainListRule(_ config: Yaml, adapterFactoryManager: AdapterFactoryManager) throws -> DomainListRule {
        guard let adapter_id = config["adapter"].stringOrIntString else {
            throw ConfigurationParserError.ruleParsingError(errorInfo: "An adapter id (adapter_id) is required.")
        }

        guard let adapter = adapterFactoryManager[adapter_id] else {
            throw ConfigurationParserError.ruleParsingError(errorInfo: "Unknown adapter id.")
        }
        
        var criteria: [DomainListRule.MatchCriterion] = []
        if let ruleConfigs = config["criteria"].array {
            for rule in ruleConfigs {
                if let rawString = rule.string,
                    let urlPattern = rawString.substring(from: ","),
                    let type = rawString.substring(to: ",") {
                    switch type {
                    case "s":
                        criteria.append(DomainListRule.MatchCriterion.suffix(urlPattern))
                    case "k":
                        criteria.append(DomainListRule.MatchCriterion.keyword(urlPattern))
                    case "p":
                        criteria.append(DomainListRule.MatchCriterion.prefix(urlPattern))
                    case "r":
                        let re = try NSRegularExpression(pattern: urlPattern, options: .caseInsensitive)
                        criteria.append(DomainListRule.MatchCriterion.regex(re))
                        break
                    case "c":
                        criteria.append(DomainListRule.MatchCriterion.complete(urlPattern))
                    default: continue
                    }
                }
            }
        }
        return DomainListRule(adapterFactory: adapter, criteria: criteria)
    }

    static func parseIPRangeListRule(_ config: Yaml, adapterFactoryManager: AdapterFactoryManager) throws -> IPRangeListRule {
        guard let adapter_id = config["adapter"].stringOrIntString else {
            throw ConfigurationParserError.ruleParsingError(errorInfo: "An adapter id (adapter_id) is required.")
        }

        guard let adapter = adapterFactoryManager[adapter_id] else {
            throw ConfigurationParserError.ruleParsingError(errorInfo: "Unknown adapter id.")
        }

        let ranges = config["criteria"].array?.compactMap({ $0.string }).filter({ $0.count > 0 }) ?? []
        return try IPRangeListRule(adapterFactory: adapter, ranges: ranges)
    }

    static func parseDNSFailRule(_ config: Yaml, adapterFactoryManager: AdapterFactoryManager) throws -> DNSFailRule {
        guard let adapter_id = config["adapter"].stringOrIntString else {
            throw ConfigurationParserError.ruleParsingError(errorInfo: "An adapter id (adapter_id) is required.")
        }

        guard let adapter = adapterFactoryManager[adapter_id] else {
            throw ConfigurationParserError.ruleParsingError(errorInfo: "Unknown adapter id.")
        }

        return DNSFailRule(adapterFactory: adapter)
    }
}
