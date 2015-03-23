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
#import "BlockView.h"

@interface ViewController ()<UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet PaddleView *paddleView;
@property (weak, nonatomic) IBOutlet BallView *ballView;
@property (strong, nonatomic) IBOutlet BlockView *blockView;
@property UIPushBehavior *pushBehavior;
@property UIDynamicAnimator *dynamicAnimator;
@property UICollisionBehavior *collisionBehavior;
@property UIDynamicItemBehavior *dynamicBallBehavior;
@property UIDynamicItemBehavior *dynamicPaddleBehavior;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.livesCount = 3;
    NSLog(@"Lives Started: %d", self.livesCount);

    self.ballView.layer.cornerRadius = self.ballView.frame.size.width / 2;
    self.ballView.clipsToBounds = YES;

    [self.view addSubview:self.paddleView];
    [self.view addSubview:self.ballView];
    [self.view addSubview:self.blockView];

    float randomDirectionX = ((int)arc4random_uniform(21) -10)/(float)10;
    float randomDirectionY = (arc4random()%10 +1)/(float)10;
    float randomMagnintude = .30; //((arc4random()%(8 - 4))+4)/(float)10;
    NSLog(@"Rando %.2f = X, %.2f = Y, %.2f = Mag", randomDirectionX, randomDirectionY, randomMagnintude);

    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    #pragma mark Push Behaviors

    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.pushDirection = CGVectorMake(randomDirectionX, randomDirectionY);
    self.pushBehavior.active = YES;
    self.pushBehavior.magnitude = randomMagnintude;
    [self.dynamicAnimator addBehavior:self.pushBehavior];

    #pragma mark Collision Behaviors

    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.paddleView, self.ballView, self.blockView]];
    self.collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    self.collisionBehavior.collisionDelegate = self;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [self.dynamicAnimator addBehavior:self.collisionBehavior];

    #pragma mark Dynamic Item Animatiors

    self.dynamicBallBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ballView]];
    self.dynamicBallBehavior.allowsRotation = NO;
    self.dynamicBallBehavior.elasticity = 1.0;
    self.dynamicBallBehavior.friction = 0.0;
    self.dynamicBallBehavior.resistance = 0.0;
    [self.dynamicAnimator addBehavior:self.dynamicBallBehavior];

    self.dynamicPaddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddleView, self.blockView]];
    self.dynamicPaddleBehavior.allowsRotation = NO;
    self.dynamicPaddleBehavior.friction = 0.0;
    self.dynamicPaddleBehavior.elasticity = 1.0;
    self.dynamicPaddleBehavior.resistance = 0.0;
    self.dynamicPaddleBehavior.density = 100000;
    [self.dynamicAnimator addBehavior:self.dynamicPaddleBehavior];
    
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p{


    if (p.y > 595) {

        self.livesCount--;

        if (self.livesCount == 0) {
            NSLog(@"Game Over!");
            self.livesCount = 3;
        }
        NSLog(@"Lives left: %d", self.livesCount);

        //  This method resets the ball when it travels off the frame, and
        //  re-initializes the ball and its behavior for a fresh instance
        //  of the ball.

        CGPoint currentVelocity = [self.dynamicBallBehavior linearVelocityForItem:self.ballView];
        [self.dynamicBallBehavior addLinearVelocity:CGPointMake(-currentVelocity.x, -currentVelocity.y)
                                            forItem:self.ballView];
        self.ballView.center = CGPointMake(175, 270);
        [self.dynamicAnimator updateItemUsingCurrentState:self.ballView];
        self.pushBehavior.pushDirection = CGVectorMake(arc4random(), arc4random());
        self.pushBehavior.magnitude = .3;
        self.pushBehavior.active = YES;
    }

    //NSLog(@"CGPoint %@", NSStringFromCGPoint(p));

}
- (IBAction)draggPaddle:(UIPanGestureRecognizer *)sender {
    self.paddleView.center = CGPointMake([sender locationInView:self.view].x, self.paddleView.center.y);
    [self.dynamicAnimator updateItemUsingCurrentState:self.paddleView];
}

@end
