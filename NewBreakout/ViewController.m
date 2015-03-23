//
//  ViewController.m
//  NewBreakout
//
//  Created by Albert Saucedo on 3/21/15.
//  Copyright (c) 2015 Albert Saucedo. All rights reserved.
//

#import "ViewController.h"
#import "PaddleView.h"
#import "BallView.h"

@interface ViewController ()<UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet PaddleView *paddleView;
@property (weak, nonatomic) IBOutlet BallView *ballView;
@property UIPushBehavior *pushBehavior;
@property UIDynamicAnimator *dynamicAnimator;
@property UICollisionBehavior *collisionBehavior;
@property UIDynamicItemBehavior *dynamicBallBehavior;
@property UIDynamicItemBehavior *dynamicPaddleBehavior;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.ballView.layer.cornerRadius = self.ballView.frame.size.width / 2;
    self.ballView.clipsToBounds = YES;

    [self.view addSubview:self.paddleView];
    [self.view addSubview:self.ballView];

    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    float randomDirectionX = ((int)arc4random_uniform(21) -10)/(float)10;
    float randomDirectionY = (arc4random()%10 +1)/(float)10;
    float randomMagnintude = .10; //((arc4random()%(8 - 4))+4)/(float)10;
    NSLog(@"Rando %.2f = X, %.2f = Y, %.2f = Mag", randomDirectionX, randomDirectionY, randomMagnintude);

    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.pushDirection = CGVectorMake(randomDirectionX, randomDirectionY);
    self.pushBehavior.active = YES;
    self.pushBehavior.magnitude = randomMagnintude;
    [self.dynamicAnimator addBehavior:self.pushBehavior];


    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.paddleView, self.ballView]];
    self.collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    self.collisionBehavior.collisionDelegate = self;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [self.dynamicAnimator addBehavior:self.collisionBehavior];

    self.dynamicBallBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ballView]];
    self.dynamicBallBehavior.allowsRotation = NO;
    self.dynamicBallBehavior.elasticity = 1.0;
    self.dynamicBallBehavior.friction = 0.0;
    self.dynamicBallBehavior.resistance = 0.0;
    [self.dynamicAnimator addBehavior:self.dynamicBallBehavior];

    self.dynamicPaddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddleView]];
    self.dynamicPaddleBehavior.allowsRotation = NO;
    self.dynamicPaddleBehavior.friction = 0.0;
    self.dynamicPaddleBehavior.elasticity = 1.0;
    self.dynamicPaddleBehavior.resistance = 0.0;
    self.dynamicPaddleBehavior.density = 100000;
    [self.dynamicAnimator addBehavior:self.dynamicPaddleBehavior];
    
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p{
    self.collideCount++;
    NSLog(@"Collided  x%d", self.collideCount);

    if (p.y > 580) {
        NSLog(@":D");
        float reset = self.ballView.center.y;
        NSLog(@"reset value %.2f", reset);
    }

    NSLog(@"CGPoint %@", NSStringFromCGPoint(p));

}
- (IBAction)draggPaddle:(UIPanGestureRecognizer *)sender {
    self.paddleView.center = CGPointMake([sender locationInView:self.view].x, self.paddleView.center.y);
    [self.dynamicAnimator updateItemUsingCurrentState:self.paddleView];
}

@end
