//
//  BounceContributorsSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 10/28/12.
//
//

#import "BounceContributorsSimulation.h"
#import "BounceNoteManager.h"
#import "FSATextureManager.h"
#import "FSAUtil.h"
#import "BounceConstants.h"

@implementation BounceContributorsList

@synthesize data = _data;
@synthesize delegate = _delegate;

-(id)initWithDelegate:(id<BounceContributorsDelegate>)delegate {
    self.delegate = delegate;
    
    _data = [[NSMutableData alloc] init];
    
    _loading = [[NSArray alloc] initWithObjects:[NSArray arrayWithObjects:@"Loading...", [NSNumber numberWithUnsignedInt:5], nil], nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _contributors = [defaults objectForKey:@"BounceContributors"];
    
    return self;
}

-(void)issueContributorsRequest {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.bouncesimulation.com/bounce-services/contributors.txt"]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:60.0];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)dealloc {
    [_data release];
    [_loading release];
    [_connection release];
    [_contributors release];
    [super dealloc];
}
-(NSArray*)contributors {
    if(_contributors) {
        return _contributors;
    }
    
    return _loading;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    [self.data appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"network error");
    /*
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                 message:[error localizedDescription]
                                delegate:nil
                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                       otherButtonTitles:nil] autorelease] show];
    */
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSMutableArray *contributors = [NSMutableArray arrayWithCapacity:10];
    
    NSString *responseText = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSArray *lines = [responseText componentsSeparatedByString:@"\n"];
    for(NSString* line in lines) {
        NSArray *columns = [line componentsSeparatedByString:@"\t"];
        
        if([columns count] == 2) {
            NSArray *contributor = [NSArray arrayWithObjects:[columns objectAtIndex:0], [f numberFromString:[columns    objectAtIndex:1]], nil];
        
            [contributors addObject:contributor];
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:contributors forKey:@"BounceContributors"];
    [_contributors release];
    _contributors = [contributors retain];
    
    [f release];
    [responseText release];
    
    [_delegate update:self];
}

// Handle basic authentication challenge if needed
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    /*
    NSURLCredential *credential = [NSURLCredential credentialWithUser:HTTP_DIGEST_USER
                                                             password:HTTP_DIGEST_PASSWORD
                                                          persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
     */
}

@end

@implementation BounceContributorsSimulation

-(void)issueContributorsRequest {
    [_contributors issueContributorsRequest];
}

-(void)update:(BounceContributorsList *)contributors {
    [self setupPageSlider];
}

-(void)prepare {
    [super prepare];
    
    [self setupPageSlider];
}

-(void)unload {    
    for(BounceObject *obj in _objects) {
        if([obj isMemberOfClass:[BounceObject class]]) {
            [(FSATextTexture*)obj.patternTexture setText:@""];
        }
    }
}

-(void)setupPageSlider {
    int index = 0;

    if(_pageSlider) {
        index = _pageSlider.index;
        [_pageSlider removeFromSimulation];
        [_pageSlider release];
    }
    
    
    NSMutableArray *pageLabels = [NSMutableArray arrayWithCapacity:10];
    int numPages = (([[_contributors contributors] count]-1)/_contributorsPerPage+1);
    for(int i = 0; i < numPages; i++) {
        [pageLabels addObject:@""];
    }
    if(index >= numPages) {
        index = 0;
    }
    
    CGSize dimensions = self.arena.dimensions;
    
    _pageSlider = [[BounceSlider alloc] initWithLabels:pageLabels index:index];
    _pageSlider.handle.bounceShape = BOUNCE_CAPSULE;
    _pageSlider.handle.size = .35*dimensions.width/numPages-.01;
    _pageSlider.handle.secondarySize = .04*[[BounceConstants instance] unitsPerInch];
    _pageSlider.handle.sound = [[BounceNoteManager instance] getRest];
    _pageSlider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"white.jpg"];
    _pageSlider.handle.isStationary = NO;
    
    _pageSlider.padding = _pageSlider.handle.size+.005;
    
    _pageSlider.track.position = vec2(-2,0);
    _pageSlider.track.size = .35*dimensions.width;
    _pageSlider.track.secondarySize = _pageSlider.handle.secondarySize*1.2;
    
    _pageSlider.track.sound = [[BounceNoteManager instance] getRest];
    _pageSlider.track.patternTexture = [[FSATextureManager instance] getTexture:@"black.jpg"];
    _pageSlider.track.isStationary = NO;
    _pageSlider.handle.renderable.blendMode = GL_ONE;
    _pageSlider.track.renderable.blendMode = GL_ONE;
    
    _pageSlider.delegate = self;
    [_pageSlider addToSimulation:self];
    
    [self changed:_pageSlider];
}

-(void)setupContributorObjects {
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:_contributorsPerPage];
    CGSize dimensions = self.arena.dimensions;
    
    for(int i = 0; i < _contributorsPerPage; i++) {
        BounceObject * configObject = [[BounceObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2() withVelocity:vec2() withColor:vec4(1,1,1,1) withSize:dimensions.width*_contributorSize withAngle:0];
        configObject.patternTexture = [[FSATextureManager instance] getNewTextTexture];
        [(FSATextTexture*)configObject.patternTexture setText:@""];
        configObject.sound = [[BounceNoteManager instance] getRest];
        [configObject addToSimulation:self];
        [objects addObject:configObject];
        
        [configObject release];
    }
    
    _contributorObjects = objects;
}

-(void)changed:(BounceSlider *)slider {
    unsigned int pageIndex = slider.index;
    
    NSArray *contributors = [_contributors contributors];
    int count = [contributors count];
    
    for(unsigned int i = 0; i < _contributorsPerPage; i++) {
        BounceObject *obj = [_contributorObjects objectAtIndex:i];
        int contributorIndex = pageIndex*_contributorsPerPage+i;
        if(contributorIndex < count) {
            NSArray *contributor = [contributors objectAtIndex:contributorIndex];
            NSString *name = [contributor objectAtIndex:0];
            BounceShape shape = BounceShape([[contributor objectAtIndex:1] unsignedIntValue]);
            [(FSATextTexture*)obj.patternTexture setText:name];
            obj.bounceShape = shape;
            [obj.renderable scalePatternUVs:vec2(2,2)];
            [obj.renderable translatePatternUVs:vec2(-.5,-.5)];
            if(!obj.hasBeenAddedToSimulation) {
                [obj addToSimulation:self];
            }
        } else {
            if(obj.hasBeenAddedToSimulation) {
                [obj removeFromSimulation];
            }
        }
    }
     
}

-(id)initWithRect:(CGRect)rect bounceSimulation:(MainBounceSimulation *)sim {
    self = [super initWithRect:rect bounceSimulation:sim];
    if(self) {
        _contributors = [[BounceContributorsList alloc] initWithDelegate:self];
        
        NSString *device = machineName();
        
        if([device hasPrefix:@"iPad"]) {
            _contributorsPerPage = 8;
            _contributorSize = .1;
        } else {
            _contributorsPerPage = 4;
            _contributorSize = .15;
        }
                
        [self setupContributorObjects];
        [self setupPageSlider];
    }
    return self;
}

-(void)setAngle:(float)angle {
    [super setAngle:angle];
    
    [_pageSlider setAngle:angle];
}
-(void)setAngVel:(float)angVel {
    [super setAngVel:angVel];
    
    [_pageSlider setAngVel:angVel];
}
-(void)step:(float)dt {
    [_pageSlider step:dt];
    
    [super step:dt];
}

-(void)setPosition:(const vec2 &)pos {
    [super setPosition:pos];
    
    CGSize dimensions = self.arena.dimensions;
    float spacing = .45 *dimensions.height;
    
    vec2 offset(0,-spacing);
    
    offset.rotate(-self.arena.angle);
    
    [_pageSlider setPosition:pos+offset];
}

-(void)setVelocity:(const vec2 &)vel {
    [super setVelocity:vel];
    [_pageSlider setVelocity:vel];
}

-(void)dealloc {
    [_pageSlider release];
    
    for(BounceObject *obj in _contributorObjects) {
        if(obj.hasBeenAddedToSimulation) {
            [obj removeFromSimulation];
        }
    }
    [_contributorObjects release];
    [_contributors release];
    [super dealloc];
}


@end
