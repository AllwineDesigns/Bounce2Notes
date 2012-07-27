//
//  FSAGestureCurve.m
//  ParticleSystem
//
//  Created by John Allwine on 7/21/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSAGestureCurve.h"
#import "FSAShaderManager.h"

#import <vector>

@implementation FSAGestureCurve {
    std::vector<vec2> _points;
    std::vector<float> _times;
    
    std::vector<vec2> _resampledPoints;
    std::vector<float> _resampledTimes;
    
    float _time;
    float _fadeTime;
    BOOL _ended;
}

@synthesize ended = _ended;
@synthesize fadeTime = _fadeTime;
@synthesize time = _time;

-(id)init {
    self = [super init];
    if(self) {
        _fadeTime = .4;
        _time = 0;
    }
    
    return self;
}

/*
-(void)resample {
    float segmentLength = .1;
    
    _resampledPoints.clear();
    _resampledTimes.clear();
    
    float numPoints = _points.size();
    if(numPoints > 1) {
        std::vector<float> lengths;
        float length = 0;
        vec2 lastP = _points[0];
        for(int i = 0; i < numPoints; i++) {
            length += (lastP-_points[i]).length();
            lengths.push_back(length);
            lastP = _points[i];
        }
        
        
        NSLog(@"points:\n");
        for(int i = 0; i < _points.size(); i++) {
            NSLog(@"%f, %f\n", _points[i].x, _points[i].y);
        }
        NSLog(@"resampled points:\n");
        
        float t = 0;
        _resampledPoints.push_back(pointAt(&_points[0], _points.size(), t));
        _resampledTimes.push_back(valueAt(&_times[0], _times.size(), t));
        NSLog(@"%f: %f, %f\n", t, _resampledPoints[_resampledPoints.size()-1].x, _resampledPoints[_resampledPoints.size()-1].y);
        while(t < 1) {
            t += segmentLength;
            _resampledPoints.push_back(pointAt(&_points[0], _points.size(), t));
            _resampledTimes.push_back(valueAt(&_times[0], _times.size(), t));
            NSLog(@"%f: %f, %f\n", t, _resampledPoints[_resampledPoints.size()-1].x, _resampledPoints[_resampledPoints.size()-1].y);

        }
        
        NSLog(@"\n\n\n");
        
    } else {
        _resampledPoints = _points;
        _resampledTimes = _times;
    }
}
*/

-(BOOL)disappeared {
    return (_time-_times[_times.size()-1]) > _fadeTime;
}

-(void)resample {
    float segmentLength = .01;
    
    _resampledPoints.clear();
    _resampledTimes.clear();
    
    float numPoints = _points.size();
    if(numPoints > 1) {
        std::vector<float> lengths;
        float length = 0;
        vec2 lastP = _points[0];
        for(int i = 0; i < numPoints; i++) {
            length += (lastP-_points[i]).length();
            lengths.push_back(length);
            lastP = _points[i];
        }
        
        float curLength = 0;
        float t = 0;
        _resampledPoints.push_back(pointAt(&_points[0], _points.size(), t));
        _resampledTimes.push_back(valueAt(&_times[0], _times.size(), t));
        while(t < 1) {
            curLength += segmentLength;
            t = tFromLength(curLength, &lengths[0], lengths.size());
            
            vec2 pt = pointAt(&_points[0], _points.size(), t);
           // if((pt-_resampledPoints[_resampledPoints.size()-1]).length() >= segmentLength) {
            _resampledPoints.push_back(pointAt(&_points[0], _points.size(), t));
            _resampledTimes.push_back(valueAt(&_times[0], _times.size(), t));
          //  }
        }
        
    } else {
        _resampledPoints = _points;
        _resampledTimes = _times;
    }
}
 
-(float*)resampledTimes {
    return &_resampledTimes[0];
}
-(vec2*)resampledPoints {
    return &_resampledPoints[0];
}
-(unsigned int)resampledNumPoints {
    return _resampledPoints.size();
}

-(float*)times {
    return &_times[0];
}

-(void)step:(float)dt {
    _time += dt;
}

-(void)addPoint:(vec2)pt {
    if(_points.size() > 0) {
        vec2 lastPt = _points[_points.size()-1];
        if(lastPt.x != pt.x || lastPt.y != pt.y) {
            _points.push_back(pt);
            _times.push_back(_time);
        }
    } else {
        _points.push_back(pt);
        _times.push_back(_time);
    }
}

-(unsigned int)numPoints {
    return _points.size();
}
-(vec2*)points {
    return &_points[0];
}

-(void)draw {
    FSAShaderManager *shaderManager = [FSAShaderManager instance];
    
    FSAShader *shader = [shaderManager getShader:@"IntensityShader"];
    std::vector<float> intensities;
    int numPoints = _points.size();
    for(int i = 0; i < numPoints; i++) {
        float t = (_time-_times[i])/_fadeTime;
        t = t > 1 ? t = 1 : t;
        intensities.push_back((float)i/(numPoints-1)*(1-t));
    }
    vec4 color(1,1,1,1);
    [shader setPtr:&color forUniform:@"color"];
    
    [shader setPtr:&_points[0] forAttribute:@"position"];
    [shader setPtr:&intensities[0] forAttribute:@"intensity"];

    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    [shader enable];
    glDrawArrays(GL_LINE_STRIP, 0, _points.size());
    [shader disable];
    glDisable(GL_BLEND);
}

@end
