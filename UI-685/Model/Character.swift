//
//  Character.swift
//  UI-685
//
//  Created by nyannyan0328 on 2022/09/30.
//

import SwiftUI

struct Character: Identifiable {
    var id = UUID().uuidString
    var value: String
    var index: Int = 0
    var rect: CGRect = .zero
    var pusOffset: CGFloat = 0
    var isCurrent: Bool = false
    var color: Color = .clear
}

