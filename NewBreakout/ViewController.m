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

-(void)viewWillAppear:(BOOL)animated{
    self.livesCount = 3;
    NSLog(@"Lives Started: %d", self.livesCount);

    self.ballView.layer.cornerRadius = self.ballView.frame.size.width / 2;
    self.ballView.clipsToBounds = YES;

    self.blockView = [BlockView new];
    self.blocksRemoved = [NSMutableArray new];

    [self.view addSubview:self.paddleView];
    [self.view addSubview:self.ballView];
    [self.view addSubview:self.blockView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    float randomDirectionX = ((int)arc4random_uniform(21) -10)/(float)10;
    float randomDirectionY = (arc4random()%10 +5)/(float)10;
    float randomMagnintude = .20; //((arc4random()%(8 - 4))+4)/(float)10;
    NSLog(@"Rando %.2f = X, %.2f = Y, %.2f = Mag", randomDirectionX, randomDirectionY, randomMagnintude);

    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    int x=33;
    int y=33;
    int hei=33;
    int wid=33;

    for (int row=1; row<5;row++)
    {
        for(int column=1;column<5;column++)
        {
            self.blockView = [[BlockView alloc]initWithFrame:CGRectMake((x+wid)*row, (y+hei)*column, wid, hei)];
            self.blockView.backgroundColor = [UIColor darkGrayColor];
            [self.view addSubview:self.blockView];

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
            self.dynamicPaddleBehavior.elasticity = 0.0;
            self.dynamicPaddleBehavior.resistance = 0.0;
            self.dynamicPaddleBehavior.density = 100000;
            [self.dynamicAnimator addBehavior:self.dynamicPaddleBehavior];
        }
    }

#pragma mark Push Behaviors

    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.pushDirection = CGVectorMake(randomDirectionX, randomDirectionY);
    self.pushBehavior.active = YES;
    self.pushBehavior.magnitude = randomMagnintude;
    [self.dynamicAnimator addBehavior:self.pushBehavior];
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior
     beganContactForItem:(id<UIDynamicItem>)item
  withBoundaryIdentifier:(id<NSCopying>)identifier
                 atPoint:(CGPoint)p{

    self.count++;

    if (self.count == 16) {
        self.count = 0;

        if (p.y > 600) {

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
            self.ballView.center = CGPointMake(175, 320);
            [self.dynamicAnimator updateItemUsingCurrentState:self.ballView];
            self.pushBehavior.pushDirection = CGVectorMake(arc4random(), arc4random());
            self.pushBehavior.magnitude = .2;
            self.pushBehavior.active = YES;
        }
    }
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior
     beganContactForItem:(id<UIDynamicItem>)item1
                withItem:(id<UIDynamicItem>)item2
                 atPoint:(CGPoint)p{

    self.countTwo++;
    if (self.countTwo == 16) {
        self.countTwo = 0;
//        NSLog(@"Collision object %@", behavior);
//        NSLog(@"Item 1 object %@", item1);
//        NSLog(@"Item 2 object %@", item2);
//        NSLog(@"Point object %@ \n", NSStringFromCGPoint(p));
    }

    if (item2 == self.ballView) {
        item2 = nil;
    }

    if (item2 != nil) {
        NSLog(@"Item 2 object %@", item2);
        [self.blocksRemoved addObject:item2];
        NSLog(@"Blocks in array %@", self.blocksRemoved);
        NSLog(@"Item 2 object after %@", item2);
    }
}

- (IBAction)draggPaddle:(UIPanGestureRecognizer *)sender {
    self.paddleView.center = CGPointMake([sender locationInView:self.view].x, self.paddleView.center.y);
    [self.dynamicAnimator updateItemUsingCurrentState:self.paddleView];
}

@end
