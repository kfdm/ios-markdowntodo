//
//  Settings.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/08/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation

enum SettingsKeys: String {
    case defaultList
}

extension UserDefaults {
    func string(forKey: SettingsKeys) -> String? {
        return string(forKey: forKey.rawValue)
    }
    func set(_ value: String?, forKey key: SettingsKeys) {
        print("Setting \(value) for \(key.rawValue)")
        set(value, forKey: key.rawValue)
    }
}

class Settings {
    static var defaults = UserDefaults.init(suiteName: "foo")
}
