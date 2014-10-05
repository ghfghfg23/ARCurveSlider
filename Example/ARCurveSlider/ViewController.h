//
//  ViewController.h
//  ARCurveSlider
//
//  Created by Andrey Ryabov on 01.07.14.
//  Copyright (c) 2014 Andrey Ryabov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ARCurveSlider.h>

@interface ViewController : UIViewController
@property (nonatomic, strong) IBOutlet ARCurveSlider *curveSlider;
@property (nonatomic, strong) IBOutlet UISlider *radiusSlider;
@property (nonatomic, strong) IBOutlet UISwitch *clockwiseSwitch;
@end
