//
//  FilterImageView.swift
//  Filters
//
//  Created by Jared Warren on 4/29/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit

protocol FilterImageViewDelegate: AnyObject {
    func didPressImageView()
    func didReleaseImageView()
}

class FilterImageView: UIImageView {
    
    weak var delegate: FilterImageViewDelegate?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didPressImageView()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didReleaseImageView()
    }

}
