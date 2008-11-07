//
//  IFLayerGeometry.m
//  ImageFlow
//
//  Created by Michel Schinz on 07.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFLayerGeometry.h"

static CGPoint IFMidPoint(CGPoint p1, CGPoint p2) {
  return CGPointMake(p1.x + (p2.x - p1.x) / 2.0, p1.y + (p2.y - p1.y) / 2.0);
}

static CGPoint IFFaceMidPoint(CGRect r, IFDirection faceDirection) {
  CGPoint bl = CGPointMake(CGRectGetMinX(r), CGRectGetMinY(r));
  CGPoint br = CGPointMake(CGRectGetMaxX(r), CGRectGetMinY(r));
  CGPoint tr = CGPointMake(CGRectGetMaxX(r), CGRectGetMaxY(r));
  CGPoint tl = CGPointMake(CGRectGetMinX(r), CGRectGetMaxY(r));
  CGPoint p1 = (faceDirection == IFLeft || faceDirection == IFDown) ? bl : tr;
  CGPoint p2 = (faceDirection == IFLeft || faceDirection == IFUp) ? tl : br;
  return IFMidPoint(p1,p2);
}

static IFDirection IFPerpendicularDirection(IFDirection d) {
  switch (d) {
    case IFUp: return IFRight;
    case IFRight: return IFDown;
    case IFDown: return IFLeft;
    case IFLeft: return IFUp;
    default: abort();
  }
}

typedef struct {
  float begin, end;
} IFInterval;

static IFInterval IFMakeInterval(float begin, float end) {
  IFInterval i = { begin, end };
  return i;
}

static BOOL IFIntersectsInterval(IFInterval i1, IFInterval i2) {
  return (i1.begin <= i2.begin && i2.begin <= i1.end) || (i2.begin <= i1.begin && i1.begin <= i2.end);
}

static float IFIntervalDistance(IFInterval i1, IFInterval i2) {
  if (IFIntersectsInterval(i1,i2))
    return 0;
  else if (i1.begin < i2.begin)
    return i2.begin - i1.end;
  else
    return i1.begin - i2.end;
}

static IFInterval IFProjectRect(CGRect r, IFDirection projectionDirection) {
  return (projectionDirection == IFUp || projectionDirection == IFDown)
  ? IFMakeInterval(CGRectGetMinX(r), CGRectGetMaxX(r))
  : IFMakeInterval(CGRectGetMinY(r), CGRectGetMaxY(r));
}

CALayer* closestLayerInDirection(CALayer* refLayer, NSArray* candidates, IFDirection direction) {
  const float searchDistance = 1000;
  CGRect refRect = refLayer.frame;
  
  CGPoint refMidPoint = IFFaceMidPoint(refRect, direction);
  CGPoint searchRectCorner;
  const float epsilon = 0.1;
  switch (direction) {
    case IFUp:
      searchRectCorner = CGPointMake(refMidPoint.x - searchDistance / 2.0, refMidPoint.y + epsilon);
      break;
    case IFDown:
      searchRectCorner = CGPointMake(refMidPoint.x - searchDistance / 2.0, refMidPoint.y - (searchDistance + epsilon));
      break;
    case IFLeft:
      searchRectCorner = CGPointMake(refMidPoint.x - (searchDistance + epsilon), refMidPoint.y - searchDistance / 2.0);
      break;
    case IFRight:
      searchRectCorner = CGPointMake(refMidPoint.x + epsilon, refMidPoint.y - searchDistance / 2.0);
      break;
    default:
      abort();
  }
  CGRect searchRect = { searchRectCorner, CGSizeMake(searchDistance, searchDistance) };
  
  NSMutableArray* filteredCandidates = [NSMutableArray array];
  for (CALayer* layer in candidates) {
    if (layer != refLayer && CGRectIntersectsRect(searchRect, layer.frame))
      [filteredCandidates addObject:layer];
  }
  
  IFDirection perDirection = IFPerpendicularDirection(direction);
  
  IFInterval refProjectionPar = IFProjectRect(refRect, direction);
  IFInterval refProjectionPer = IFProjectRect(refRect, perDirection);
  
  CALayer* bestCandidate = nil;
  float bestCandidateDistancePar = searchDistance, bestCandidateDistancePer = searchDistance;
  for (CALayer* candidate in filteredCandidates) {
    CGRect r = candidate.frame;
    
    float dPer = IFIntervalDistance(refProjectionPar, IFProjectRect(r, direction));
    float dPar = IFIntervalDistance(refProjectionPer, IFProjectRect(r, perDirection));
    
    if (dPer < bestCandidateDistancePer || (dPer == bestCandidateDistancePer && dPar < bestCandidateDistancePar)) {
      bestCandidate = candidate;
      bestCandidateDistancePar = dPar;
      bestCandidateDistancePer = dPer;
    }
  }
  return bestCandidate;
}

