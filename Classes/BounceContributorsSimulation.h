//
//  BounceContributorsSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 10/28/12.
//
//

#import "BounceConfigurationSimulation.h"
#import "BouncePages.h"
#import "BounceSlider.h"

@class BounceContributorsList;

@protocol BounceContributorsDelegate <NSObject>

-(void)update:(BounceContributorsList*)contributors;

@end

@interface BounceContributorsList : NSObject <NSURLConnectionDelegate> {
    NSMutableData *_data;
    NSArray *_loading;
    NSArray *_contributors;
    
    id<BounceContributorsDelegate> _delegate;
    
    NSURLConnection *_connection;
}

@property (nonatomic, readonly) NSMutableData* data;
@property (nonatomic, retain) id<BounceContributorsDelegate> delegate;

-(NSArray*)contributors;
-(id)initWithDelegate:(id<BounceContributorsDelegate>)delegate;
-(void)issueContributorsRequest;
@end

@interface BounceContributorsSimulation : BounceConfigurationSimulation <BounceContributorsDelegate,BounceSliderDelegate> {
    BounceSlider *_pageSlider;
    BounceContributorsList *_contributors;
    NSArray *_contributorObjects;
    int _contributorsPerPage;
    float _contributorSize;
}

-(void)issueContributorsRequest;

@end
