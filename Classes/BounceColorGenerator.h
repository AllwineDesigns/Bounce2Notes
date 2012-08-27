//
//  BounceColorGenerator.h
//  ParticleSystem
//
//  Created by John Allwine on 8/22/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fsa/Vector.hpp"

using namespace fsa;

@interface BounceColorGenerator : NSObject {
    
}
-(vec4)randomColor;
-(vec4)randomColorFromTime:(NSTimeInterval)time;
-(vec4)randomColorFromLocation:(const vec2&)loc;
-(vec4)perlinColorFromLocation:(const vec2&)loc time:(NSTimeInterval)time;

@end

@interface BouncePastelColorGenerator : BounceColorGenerator {
}
@end;

@interface BounceRedColorGenerator : BounceColorGenerator {
}
@end;

@interface BounceOrangeColorGenerator : BounceColorGenerator {
}
@end;

@interface BounceYellowColorGenerator : BounceColorGenerator {
}
@end;

@interface BounceGreenColorGenerator : BounceColorGenerator {
}
@end;

@interface BounceBlueColorGenerator : BounceColorGenerator {
}
@end;

@interface BouncePurpleColorGenerator : BounceColorGenerator {
}
@end;

@interface BounceGrayColorGenerator : BounceColorGenerator {
}
@end;

@interface BounceRandomColorGenerator : BounceColorGenerator {
    NSArray *_generators;
}
@end


