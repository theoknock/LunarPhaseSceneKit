//
//  LunarPhaseSceneKitView.h
//  Planetary Hour
//
//  Created by Xcode Developer on 1/1/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LunarPhaseSceneKitView : SCNView

@property (assign, nonatomic, setter=setLunarPhase:) float moonPhase;

@end

NS_ASSUME_NONNULL_END
