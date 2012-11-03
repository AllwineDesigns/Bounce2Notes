//
//  BounceHowToSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 10/24/12.
//
//

#import "BounceHowToSimulation.h"
#import "FSATextureManager.h"
#import "BounceNoteManager.h"

@implementation BounceHowToSimulation

-(void)setupOpenInSafariButton {
    CGSize dimensions = self.arena.dimensions;
    
    BounceButton *button = [[BounceButton alloc] init];
    button.patternTexture = [[FSATextureManager instance] getTexture:@"Open In Safari"];
    button.bounceShape = BOUNCE_CAPSULE;
    button.size = dimensions.width*.2;
    button.secondarySize = dimensions.height*.08;
    button.position = vec2(-2,0);
    button.isStationary = NO;
    button.sound = [[BounceNoteManager instance] getRest];
    
    button.delegate = self;
    
    [button addToSimulation:self];
    
    _openInSafariButton = button;
}


-(id)initWithRect:(CGRect)rect bounceSimulation:(MainBounceSimulation *)sim {
    self = [super initWithRect:rect bounceSimulation:sim];
    if(self) {
        [self setupOpenInSafariButton];
    }
    return self;
}

-(void)setAngle:(float)angle {
    [super setAngle:angle];
    [_openInSafariButton setAngle:angle];
}
-(void)setAngVel:(float)angVel {
    [super setAngVel:angVel];
    [_openInSafariButton setAngVel:angVel];
}
-(void)step:(float)dt {
    [_openInSafariButton step:dt];
    if(_openInSafariButton.intensity < .5) {
        _openInSafariButton.intensity = .5;
    }
    
    [super step:dt];
}

-(void)pressed:(BounceButton *)button {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bouncesimulation.com/how-to/"]];

    NSLog(@"pressed open in safari");
}

-(void)setPosition:(const vec2 &)pos {
    [super setPosition:pos];
    [_openInSafariButton setPosition:pos];
}

@end
