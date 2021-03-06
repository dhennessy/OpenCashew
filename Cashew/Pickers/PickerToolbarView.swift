//
//  PickerToolbarView.swift
//  Issues
//
//  Created by Hicham Bouabdallah on 5/28/16.
//  Copyright © 2016 Hicham Bouabdallah. All rights reserved.
//

import Cocoa

class PickerToolbarView: BaseView {
    
    private static let padding: CGFloat = 6.0
    //private static let buttonSize: CGSize = CGSize(width: 100, height: 20)
    
    private var leftButton: BaseImageLabelButton?
    private var rightButton: BaseImageLabelButton?
    
    var viewModel: PickerToolbarViewModel {
        didSet {
            didSetViewModel()
        }
    }
    
    required init(viewModel: PickerToolbarViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        
        didSetViewModel()
        
        //        self.layer?.borderColor = NSColor.purpleColor().CGColor
        //        self.layer?.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func didSetViewModel() {
        
        setupLeftButton()
        setupRightButton()
        
        if let leftButton = leftButton, leftButtonViewModel = viewModel.leftButtonViewModel {
            leftButton.viewModel = leftButtonViewModel
            leftButton.hidden = false
        } else {
            leftButton?.hidden = true
        }
        
        if let rightButton = rightButton, rightButtonViewModel = viewModel.rightButtonViewModel {
            rightButton.viewModel = rightButtonViewModel
            rightButton.hidden = false
        } else {
            rightButton?.hidden = true
        }
    }
    
    // MARK: Setup
    private func setupLeftButton() {
        guard let leftButtonViewModel = viewModel.leftButtonViewModel else {
            leftButton?.hidden = true
            return
        }
        
        if let leftButton = leftButton {
            leftButton.viewModel = leftButtonViewModel
            leftButton.hidden = false
        } else {
            let leftButton = BaseImageLabelButton(viewModel: leftButtonViewModel)
            leftButton.hidden = false
            addSubview(leftButton)
            self.leftButton = leftButton
        }
    }
    
    private func setupRightButton() {
        guard let rightButtonViewModel = viewModel.rightButtonViewModel else {
            rightButton?.hidden = true
            return
        }
        
        if let rightButton = rightButton {
            rightButton.viewModel = rightButtonViewModel
            rightButton.hidden = false
        } else {
            let rightButton = BaseImageLabelButton(viewModel: rightButtonViewModel)
            rightButton.hidden = false
            addSubview(rightButton)
            self.rightButton = rightButton
        }
    }
    
    // MARK: Layout
    override func layout() {
        if let leftButton = leftButton {
            let leftButtonSize = leftButton.suggestedSize()
            let buttonTop = bounds.height / 2.0 - leftButtonSize.height / 2.0
            leftButton.frame = CGRectIntegralMake(x: PickerToolbarView.padding, y: buttonTop, width: leftButtonSize.width, height: leftButtonSize.height)
        }
        
        if let rightButton = rightButton {
            let rightButtonSize = rightButton.suggestedSize()
            let buttonTop = bounds.height / 2.0 - rightButtonSize.height / 2.0
            let rightButtonLeft = bounds.width - PickerToolbarView.padding - rightButtonSize.width
            rightButton.frame = CGRectIntegralMake(x: rightButtonLeft, y: buttonTop, width: rightButtonSize.width, height: rightButtonSize.height)
        }
        super.layout()
    }
    
}

@objc(SRPickerToolbarViewModel)
class PickerToolbarViewModel: NSObject {
    
    let leftButtonViewModel: BaseImageLabelButtonViewModel?
    let rightButtonViewModel: BaseImageLabelButtonViewModel?
    
    required init(leftButtonViewModel: BaseImageLabelButtonViewModel?, rightButtonViewModel: BaseImageLabelButtonViewModel?) {
        self.leftButtonViewModel = leftButtonViewModel
        self.rightButtonViewModel = rightButtonViewModel
        
        super.init()
    }
}