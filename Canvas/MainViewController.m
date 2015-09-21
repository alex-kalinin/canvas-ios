//
//  MainViewController.m
//  Canvas
//
//  Created by Alex Kalinin on 9/17/15.
//  Copyright (c) 2015 Alex Kalinin. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
{
    CGPoint _origCenter;
    CGPoint _tray_up;
    CGPoint _tray_down;
    UIImageView* _new_face;
    CGPoint _new_face_orig_center;
    CGAffineTransform _initial_face_scale;
    NSMutableArray* _new_faces;
}

@property (strong, nonatomic) IBOutlet UIView *trayView;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *tap_guesture;
@property (strong, nonatomic) IBOutlet UIImageView *arrow_image;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.trayView addGestureRecognizer:self.tap_guesture];
    _new_faces = [NSMutableArray new];
}

-(void)viewDidAppear:(BOOL)animated
{
    _tray_up = self.trayView.center;
    _tray_down = self.trayView.center;
    _tray_down.y = self.view.frame.size.height +
        self.trayView.frame.size.height / 2 - 50;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)tap:(id)sender {
//    _origCenter = self.trayView.center;
    [self animate_tray:_tray_up];
}


- (IBAction)pan:(UIPanGestureRecognizer*)sender
{
    CGPoint translation;
    
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
            _origCenter = self.trayView.center;
            break;
            
        case UIGestureRecognizerStateChanged:
            translation = [sender translationInView:self.view];
            self.trayView.center = CGPointMake(_origCenter.x, _origCenter.y + translation.y);
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGPoint velocity = [sender velocityInView:self.view];
            CGPoint val;
            
            if (velocity.y > 0) // going down
            {
                val = _tray_down;
            }
            else {
                val = _tray_up;
            }
            
            [self animate_tray:val];
        }
            break;
            
        default:
            break;
    }
}

-(void) animate_tray:(CGPoint) pos
{
    [UIView animateWithDuration:0.2
                          delay:0.0
         usingSpringWithDamping:1
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.trayView.center = pos;
                        } completion:^(BOOL finished) {
                        }];
}

- (IBAction)pan_on_face:(UIPanGestureRecognizer *)sender
{
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            UIImageView* image_view = (UIImageView*) sender.view;
            _new_face = [[UIImageView alloc]initWithImage:image_view.image];
            [_new_faces addObject:_new_face];
            [self.view addSubview:_new_face];
            _new_face.center = CGPointMake(image_view.center.x, image_view.center.y + self.trayView.frame.origin.y);
            _new_face.userInteractionEnabled = YES;
            _new_face_orig_center = _new_face.center;
            _new_face.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [sender translationInView:self.view];
            _new_face.center = CGPointMake(_new_face_orig_center.x + translation.x, _new_face_orig_center.y + translation.y);
        }
            break;

        case UIGestureRecognizerStateEnded:
        {
            UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan_new_face:)];
            [_new_face addGestureRecognizer:pan];
            
            UIPinchGestureRecognizer* pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch_new_face:)];
            [_new_face addGestureRecognizer:pinch];

            UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(long_press_face:)];
            longPress.minimumPressDuration = 0.8;
            [_new_face addGestureRecognizer:longPress];
            
            _new_face = nil;
        }
            break;
            
        default:
            break;
    }
}

-(IBAction)long_press_face:(UILongPressGestureRecognizer*)sender
{
//    [sender.view removeFromSuperview];
    for (int i = 0; i < _new_faces.count; i++)
    {
        [_new_faces[i] removeFromSuperview];
    }
    [_new_faces removeAllObjects];
}

//-(IBAction)tap_new_face:(UIPanGestureRecognizer*)sender
//{
//    UIImageView* face = (UIImageView*) sender.view;
//    switch (sender.state) {
//        case UIGestureRecognizerStateBegan:
//            face.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
//            break;
//        case UIGestureRecognizerStateEnded:
//            face.transform = CGAffineTransformIdentity;
//            break;
//        default:
//            break;
//    }
//    
//}

-(IBAction)pinch_new_face:(UIPinchGestureRecognizer*)sender
{
    UIImageView* face = (UIImageView*) sender.view;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            _initial_face_scale = face.transform;
            break;
            
        case UIGestureRecognizerStateChanged:
            face.transform = CGAffineTransformScale(_initial_face_scale, sender.scale, sender.scale);
            break;
            
        default:
            break;
    }
}

-(IBAction)pan_new_face:(UIPanGestureRecognizer*)sender
{
    UIImageView* face = (UIImageView*) sender.view;

    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            _origCenter = face.center;
        }
            break;

        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [sender translationInView:self.view];
            face.center = CGPointMake(_origCenter.x + translation.x, _origCenter.y + translation.y);
        }
            break;
            
        default:
            break;
    }
}

@end
