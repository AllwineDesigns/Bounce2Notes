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

-(void)setupInstructions {
    CGSize dimensions = self.arena.dimensions;
    
    BounceButton *button = [[BounceButton alloc] init];
    [[FSATextureManager instance] addTextTexture:@"Instruction Manual"];
    FSATextTexture *tex = (FSATextTexture*)[[FSATextureManager instance] getTexture:@"Instruction Manual"];
    [tex setFontSize:30];
    button.patternTexture = tex;
    
    button.bounceShape = BOUNCE_CAPSULE;
    button.size = dimensions.width*.2;
    button.secondarySize = dimensions.height*.08;
    button.position = vec2(-2,0);
    button.isStationary = NO;
    button.sound = [[BounceNoteManager instance] getRest];
    
    button.delegate = self;
    
    [button addToSimulation:self];
    
    _instructions = button;
}

-(void)setupHowTo {
    CGSize dimensions = self.arena.dimensions;
    
    BounceButton *button = [[BounceButton alloc] init];
    [[FSATextureManager instance] addTextTexture:@"How-To Videos"];
    FSATextTexture *tex = (FSATextTexture*)[[FSATextureManager instance] getTexture:@"How-To Videos"];
    [tex setFontSize:30];
    button.patternTexture = tex;
    button.bounceShape = BOUNCE_CAPSULE;
    button.size = dimensions.width*.2;
    button.secondarySize = dimensions.height*.08;
    button.position = vec2(-2,0);
    button.isStationary = NO;
    button.sound = [[BounceNoteManager instance] getRest];
    
    button.delegate = self;
    
    [button addToSimulation:self];
    
    _howto = button;
}

-(void)setupFAQ {
    CGSize dimensions = self.arena.dimensions;
    
    BounceButton *button = [[BounceButton alloc] init];
    [[FSATextureManager instance] addTextTexture:@"FAQ"];
    FSATextTexture *tex = (FSATextTexture*)[[FSATextureManager instance] getTexture:@"FAQ"];
    [tex setFontSize:30];
    button.patternTexture = tex;
    button.bounceShape = BOUNCE_CAPSULE;
    button.size = dimensions.width*.2;
    button.secondarySize = dimensions.height*.08;
    button.position = vec2(-2,0);
    button.isStationary = NO;
    button.sound = [[BounceNoteManager instance] getRest];
    
    button.delegate = self;
    
    [button addToSimulation:self];
    
    _faq = button;
}


-(id)initWithRect:(CGRect)rect bounceSimulation:(MainBounceSimulation *)sim {
    self = [super initWithRect:rect bounceSimulation:sim];
    if(self) {
        [self setupInstructions];
        [self setupHowTo];
        [self setupFAQ];
    }
    return self;
}

-(void)prepare {
    [super prepare];
    [(FSATextTexture*)_instructions.patternTexture setText:@"Instruction Manual"];
    [(FSATextTexture*)_howto.patternTexture setText:@"How-To Videos"];
    [(FSATextTexture*)_faq.patternTexture setText:@"FAQ"];
}

-(void)unload {
    [super unload];

    [(FSATextTexture*)_instructions.patternTexture setText:@""];
    [(FSATextTexture*)_howto.patternTexture setText:@""];
    [(FSATextTexture*)_faq.patternTexture setText:@""];
}

-(void)setAngle:(float)angle {
    [super setAngle:angle];
    [_instructions setAngle:angle];
    [_howto setAngle:angle];
    [_faq setAngle:angle];
}
-(void)setAngVel:(float)angVel {
    [super setAngVel:angVel];
    [_instructions setAngVel:angVel];
    [_howto setAngVel:angVel];
    [_faq setAngVel:angVel];

}
-(void)step:(float)dt {
    [_instructions step:dt];
    if(_instructions.intensity < .5) {
        _instructions.intensity = .5;
    }
    
    [_howto step:dt];
    if(_howto.intensity < .5) {
        _howto.intensity = .5;
    }
    
    [_faq step:dt];
    if(_faq.intensity < .5) {
        _faq.intensity = .5;
    }
    
    [super step:dt];
}

-(void)pressed:(BounceButton *)button {
    if(_instructions == button) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bouncesimulation.com/help/instruction-manual/"]];
    } else if(_howto == button) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bouncesimulation.com/help/how-to/"]];
    } else if(_faq == button) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bouncesimulation.com/help/faq/"]];
    }
}

-(void)setPosition:(const vec2 &)pos {
    [super setPosition:pos];
    CGSize dimensions = self.arena.dimensions;
    
    vec2 offset(0, .25*dimensions.height);
    offset.rotate(-self.arena.angle);
    
    vec2 offset2(0, -.25*dimensions.height);
    offset2.rotate(-self.arena.angle);
    
    [_instructions setPosition:pos];
    [_howto setPosition:pos+offset];
    [_faq setPosition:pos-offset];

}

@end
