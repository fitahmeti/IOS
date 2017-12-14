//
//  CustomFadeSegue.swift
//  Precisely
//
//  Created by iOS Development Company on 5/18/17.
//  Copyright © 2017 iOS Development Company. All rights reserved.
//

import UIKit

class CustomFadeSegue: UIStoryboardSegue {

    override func perform() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        self.source.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.source.navigationController?.pushViewController(self.destination, animated: false)
    }
}
