//
//  ARCurveSlider.h
//  ARCurveSlider
//
//  Created by Andrey Ryabov on 07.07.14.
//  Copyright (c) 2014 Andrey Ryabov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARCurveSlider : UIControl
@property (nonatomic) CGFloat widthSlider;
@property (nonatomic) float radius;
@property (nonatomic) float startAngle;
@property (nonatomic) float endAngle;
@property (nonatomic) BOOL clockwise;
@property (nonatomic) float value;
@property (nonatomic, strong) UIColor *sliderFrontColor;
@property (nonatomic, strong) UIColor *sliderBackColor;
@property (nonatomic, strong) UIColor *sliderButtonColor;
@end
