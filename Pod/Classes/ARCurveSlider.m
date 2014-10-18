//
//  ARCurveSlider.m
//  ARCurveSlider
//
//  Created by Andrey Ryabov on 07.07.14.
//  Copyright (c) 2014 Andrey Ryabov. All rights reserved.
//

#import "ARCurveSlider.h"

//#define DEBUG_CONTROL

#pragma mark - Utility
void radianRangeAdjust(float *angle) {
    if (*angle < 0.0f) {
        *angle = 2 * M_PI + *angle;
        radianRangeAdjust(angle);
    }
    if (*angle > M_PI * 2.0f) {
        *angle = *angle - 2 * M_PI;
        radianRangeAdjust(angle);
    }
}

CGPoint pointWithCenterRadiusAngle(CGPoint center, CGFloat radius, CGFloat angle) {
    CGFloat targetX = center.x + radius * cos(angle);
    CGFloat targetY = center.y + radius * sin(angle);
    CGPoint position = CGPointMake(targetX, targetY);
    return position;
}

#pragma mark - Slider
@interface ARCurveSlider () {
    UIBezierPath *_touchSliderPath;
    CGFloat _widthSlider;
    float _radius;
    float _startAngle;
    float _endAngle;
    
    float _angleDistance;
    
    CGPoint _centerPoint;
    BOOL _clockwise;
    float _value;
    
    BOOL _needFullRedraw;
    
    BOOL _isTracking;

    CAShapeLayer *_maskSliderProgressPresentationLayer;
    CAShapeLayer *_buttonPresentationLayer;
    CGFloat _buttonRadius;
    
#ifdef DEBUG_CONTROL
    UILabel *_startLabel;
    UILabel *_endLabel;
    UILabel *_valueLabel;
#endif
}
@end

@implementation ARCurveSlider
@synthesize radius = _radius, widthSlider = _widthSlider, startAngle = _startAngle, endAngle = _endAngle, clockwise = _clockwise, value = _value, sliderBackColor = _sliderBackColor, sliderButtonColor = _sliderButtonColor, sliderFrontColor = _sliderFrontColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultInitialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultInitialize];
    }
    return self;
}

- (void)defaultInitialize {
    _centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _radius = 100.0f;
    _value = 0.9f;
    _widthSlider = 44.0f;

    _startAngle = 0.00;
    _endAngle = M_PI;
    _clockwise = YES;
    
    _buttonRadius = 16.0f;
    _needFullRedraw = YES;
    
    _sliderBackColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    _sliderButtonColor = [UIColor whiteColor];
    _sliderFrontColor = [UIColor colorWithWhite:1.0f alpha:0.6f];
    
    [self addObserver:self forKeyPath:@"widthSlider" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"radius" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"startAngle" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"endAngle" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"clockwise" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"sliderBackColor" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"sliderButtonColor" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"sliderFrontColor" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    _needFullRedraw = YES;
    [self setNeedsLayout];
}

- (void)resetView {
    NSArray *array = [self.subviews copy];
    for (UIView *view in array) {
        [view removeFromSuperview];
    }
    array = [self.layer.sublayers copy];
    for (CALayer *layer in array) {
        [layer removeFromSuperlayer];
    }
    
    [self normalizeAngles];
    
    _touchSliderPath = [self bezierPathWithArcCenter:_centerPoint
                                              radius:_radius
                                          startAngle:_startAngle
                                            endAngle:_endAngle
                                           clockwise:_clockwise
                                               width:_widthSlider
                                            roundCap:NO];
    
    [self drawPresentation];
    
#ifdef DEBUG_CONTROL
    [self drawSupportLabels];
#endif
    _needFullRedraw = NO;
}

- (void)normalizeAngles {
    radianRangeAdjust(&_startAngle);
    radianRangeAdjust(&_endAngle);
    float clockwiseSign = _clockwise ? 1 : -1;
    _angleDistance = (_endAngle - _startAngle) * clockwiseSign;
    radianRangeAdjust(&_angleDistance);
}

#ifdef DEBUG_CONTROL
- (void)drawSupportLabels {
    _startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    _startLabel.text = @"0";
    _startLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_startLabel];
    
    _endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    _endLabel.text = @"1";
    _endLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_endLabel];
    
    _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 90.0f, 90.0f)];
    _valueLabel.text = @"";
    _valueLabel.backgroundColor = [UIColor redColor];
    [self addSubview:_valueLabel];
    _valueLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}
#endif

- (UIBezierPath *)bezierPathWithArcCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise width:(CGFloat)width roundCap:(BOOL)roundCap {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat halfWidth = width * 0.5f;
    [path addArcWithCenter:center radius:(radius-halfWidth) startAngle:startAngle endAngle:endAngle clockwise:clockwise];

    if(roundCap) {
        CGPoint endOuter = pointWithCenterRadiusAngle(_centerPoint, _radius+halfWidth, endAngle);
        CGPoint endInner = pointWithCenterRadiusAngle(_centerPoint, _radius-halfWidth, endAngle);
        CGPoint endCenter = CGPointMake((endOuter.x + endInner.x)*0.5f, (endOuter.y + endInner.y)*0.5f);
        CGFloat endStartAngle = [self angleWithCenter:endCenter point:endOuter];
        CGFloat endEndAngle = [self angleWithCenter:endCenter point:endInner];
        [path addArcWithCenter:endCenter radius:halfWidth startAngle:endEndAngle endAngle:endStartAngle clockwise:!clockwise];
    }
    
    [path addArcWithCenter:center radius:(radius+halfWidth) startAngle:endAngle endAngle:startAngle clockwise:!clockwise];
    
    if (roundCap) {
        CGPoint startOuter = pointWithCenterRadiusAngle(_centerPoint, _radius+halfWidth, startAngle);
        CGPoint startInner = pointWithCenterRadiusAngle(_centerPoint, _radius-halfWidth, startAngle);
        CGPoint startCenter = CGPointMake((startOuter.x + startInner.x)/2, (startOuter.y + startInner.y)/2);
        CGFloat startStartAngle = [self angleWithCenter:startCenter point:startOuter];
        CGFloat startEndAngle = [self angleWithCenter:startCenter point:startInner];
        [path addArcWithCenter:startCenter radius:halfWidth startAngle:startStartAngle endAngle:startEndAngle clockwise:!clockwise];
    }
    [path closePath];
    
    return path;
}

- (float)value {
    return _value;
}

- (void)setValue:(float)value {
    if (_isTracking)
        return;
    _value = value;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_needFullRedraw) {
        [self resetView];
    }
#ifdef DEBUG_CONTROL
    _startLabel.center = pointWithCenterRadiusAngle(_centerPoint, _radius, _startAngle);
    _endLabel.center = pointWithCenterRadiusAngle(_centerPoint, _radius, _endAngle);
#endif
    [self updateView];
}

- (void)updateView {
    float anchorAngle = _clockwise ? _startAngle : _endAngle;
    float value = _clockwise ? _value : 1 - _value;
    float progressAngle = anchorAngle + (value * _angleDistance);
    radianRangeAdjust(&progressAngle);
    _buttonPresentationLayer.position = pointWithCenterRadiusAngle(_centerPoint, _radius, progressAngle);
    
    CGFloat addition = 4.0f;
    CGFloat maskRadius = addition + _radius;
    UIBezierPath *path = [UIBezierPath bezierPath];
    float sign = _clockwise ? 1 : -1;
    float additionAngle = sign * 2*asinf(addition/(2*_radius));
    float correctedStartAngle = _startAngle - additionAngle;
    [path moveToPoint:_centerPoint];
    [path addLineToPoint:pointWithCenterRadiusAngle(_centerPoint, maskRadius, correctedStartAngle)];
    [path addArcWithCenter:_centerPoint radius:maskRadius startAngle:correctedStartAngle endAngle:progressAngle clockwise:_clockwise];
    [path closePath];
    _maskSliderProgressPresentationLayer.path = path.CGPath;
#ifdef DEBUG_CONTROL
    _valueLabel.text = [NSString stringWithFormat:@"%.5f", _value];
#endif
}

#pragma mark - Touch
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    BOOL touchInSliderPath = [_touchSliderPath containsPoint:touchPoint];
    if (touchInSliderPath) {
        BOOL touchInButtonRadius = [self touchInCircleWithPoint:touchPoint circleCenter:_buttonPresentationLayer.position];
        if(touchInButtonRadius) {
            _isTracking = YES;
            return YES;
        }
    }
    return NO;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL touchInSliderPath = [_touchSliderPath containsPoint:point];
    if (touchInSliderPath) {
        BOOL touchInButtonRadius = [self touchInCircleWithPoint:point circleCenter:_buttonPresentationLayer.position];
        if(touchInButtonRadius) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    BOOL touchInSliderPath = [_touchSliderPath containsPoint:touchPoint];
    if (!touchInSliderPath) {
        [self roundValue];
        return NO;
    }
    [self adjustValueWithTargetPoint:touchPoint];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    _isTracking = NO;
    [self roundValue];
}

- (CGFloat)angleWithCenter:(CGPoint)center point:(CGPoint)point {
    CGFloat dY = point.y - center.y;
    CGFloat dX = point.x - center.x;
    CGFloat angle = atan2f(dY, dX);
    return angle;
}

- (CGFloat)angleFromPoint:(CGPoint)point {
    return [self angleWithCenter:_centerPoint point:point];
}

- (CGFloat)relativeAngleFromPoint:(CGPoint)point {
    float angle = [self angleFromPoint:point];
    float zeroAngle = _startAngle;
    radianRangeAdjust(&angle);
    float relativeAngle = _clockwise ? angle - zeroAngle : zeroAngle - angle;
    radianRangeAdjust(&relativeAngle);
    return relativeAngle ;
}

- (void)adjustValueWithTargetPoint:(CGPoint)targetPoint {
    CGFloat angle = [self relativeAngleFromPoint:targetPoint];
    _value = angle/_angleDistance;
    [self setNeedsLayout];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)roundValue {
    if (_value < 0.05) {
        _value = 0.0f;
    } else if (_value > 0.95) {
        _value = 1.0f;
    }
    [self setNeedsLayout];
}

- (BOOL) touchInCircleWithPoint:(CGPoint)touchPoint circleCenter:(CGPoint)circleCenter{
    double x = touchPoint.x - circleCenter.x;
    double y = touchPoint.y - circleCenter.y;
    
    CGFloat distance = sqrt(pow(x, 2.0) + pow(y, 2.0));
    if(distance >= _buttonRadius)
        return NO;
    else
        return YES;
}


#pragma mark - Presentation
- (void)drawPresentation {
    [self drawSliderBackPath];
    [self drawSliderFrontPath];
    [self drawSliderDragButton];
}

- (void)drawSliderDragButton {
    UIBezierPath *buttonPath = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:6.0f startAngle:0.0f endAngle:M_2_PI clockwise:NO];
    
    _buttonPresentationLayer = [CAShapeLayer layer];
    _buttonPresentationLayer.path = buttonPath.CGPath;
    _buttonPresentationLayer.fillColor = _sliderButtonColor.CGColor;
    
    NSMutableDictionary *actions = [NSMutableDictionary dictionaryWithDictionary:_buttonPresentationLayer.actions];
    [actions setObject:[NSNull null] forKey:@"position"];
    _buttonPresentationLayer.actions = actions;
    
    [self.layer addSublayer:_buttonPresentationLayer];
}

- (void)drawSliderFrontPath {
    _maskSliderProgressPresentationLayer = [CAShapeLayer layer];
    UIBezierPath *path = [self bezierPathWithArcCenter:_centerPoint radius:_radius startAngle:_startAngle endAngle:_endAngle clockwise:_clockwise width:8.0f roundCap:YES];
    CAShapeLayer *touchSliderLayer = [CAShapeLayer layer];
    touchSliderLayer.path = path.CGPath;
    touchSliderLayer.fillColor = _sliderFrontColor.CGColor;
    touchSliderLayer.mask = _maskSliderProgressPresentationLayer;
    [self.layer addSublayer:touchSliderLayer];
}

- (void)drawSliderBackPath {
    UIBezierPath *path = [self bezierPathWithArcCenter:_centerPoint radius:_radius startAngle:_startAngle endAngle:_endAngle clockwise:_clockwise width:4.0f roundCap:YES];
    CAShapeLayer *touchSliderLayer = [CAShapeLayer layer];
    touchSliderLayer.path = path.CGPath;
    touchSliderLayer.fillColor = _sliderBackColor.CGColor;
    [self.layer addSublayer:touchSliderLayer];
}

@end
