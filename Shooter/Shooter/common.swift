//
//  common.swift
//  Shooter
//
//  Created by kotta on 12/06/2018.
//  Copyright © 2018 Starblo Hong. All rights reserved.
//

import Foundation
import CoreFoundation
import UIKit
import ARKit

func random(lower: Float = -1, upper: Float = 1) -> Float {
    let num = Float(drand48());
    return lower + (upper - lower) * num;
}

func genId() -> String {
    return String(random(lower: 0, upper: 10000));
}
