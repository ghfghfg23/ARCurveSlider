//
//  ViewController.m
//  ARCurveSlider
//
//  Created by Andrey Ryabov on 01.07.14.
//  Copyright (c) 2014 Andrey Ryabov. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.curveSlider.value = 0.3;
    self.curveSlider.startAngle = 0.0f;
    self.curveSlider.endAngle = -3.1415f;
    self.curveSlider.widthSlider = 100.0f;
    self.curveSlider.availabilityEnabled = YES;
    self.curveSlider.sliderFrontColor = [UIColor yellowColor];
    self.curveSlider.sliderBackColor = [UIColor redColor];
    self.curveSlider.sliderButtonColor = [UIColor orangeColor];
    [self.curveSlider setNeedsLayout];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)radiusSliderChangeValue:(UISlider *)sender {
    self.curveSlider.radius = sender.value;
}

- (IBAction)clockwiseSwitchChangeValue:(UISwitch *)sender {
    self.curveSlider.clockwise = sender.isOn;
}

- (IBAction)availabilitySliderChangeValue:(UISlider *)sender {
    self.curveSlider.availableValue = sender.value;
}

- (IBAction)availabilitySwitchChangeValue:(UISwitch *)sender {
    self.curveSlider.availabilityEnabled = sender.isOn;
}
- (IBAction)curveSliderChangeValue:(ARCurveSlider *)sender {
    CGFloat value = [sender value];
    UIColor *backgroundColor = [UIColor colorWithHue:value saturation:0.85f brightness:0.97f alpha:1.0f];
    self.view.backgroundColor = backgroundColor;
}

@end
