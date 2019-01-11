//
//  LunarPhaseSceneKitView.m
//  Planetary Hour
//
//  Created by Xcode Developer on 1/1/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "LunarPhaseSceneKitView.h"
#import "LunarPhase.h"

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0f * M_PI )

@interface LunarPhaseSceneKitView ()
{
    BOOL shouldRotateSphere;
    SCNNode *cameraOrbit;
    dispatch_source_t timer;
}


@end

@implementation LunarPhaseSceneKitView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self renderLunarPhase];

    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 60.0 * NSEC_PER_SEC, 60.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self renderLunarPhase];
    });
    dispatch_resume(timer);
 
//    [self renderShadowExample];
}

SCNAction *(^orbit)(SCNNode *) = ^(SCNNode *node)
{
    return [SCNAction rotateByAngle:(360.0 * (M_PI / 180.0)) aroundAxis:SCNVector3Make(1, 0, 0) duration:1];
};

float scaleBetween(float unscaledNum, float minAllowed, float maxAllowed, float min, float max) {
    return (maxAllowed - minAllowed) * (unscaledNum - min) / (max - min) + minAllowed;
}

- (void)renderLunarPhase
{
    if (!_moonPhase)
        [self setLunarPhase:[LunarPhase.calculator phaseForDate:[NSDate date]]];
    
    // Scene camera and related nodes
    SCNCamera *camera = [SCNCamera new];
    camera.usesOrthographicProjection = TRUE;
    camera.orthographicScale = 9;
    camera.zNear = 0;
    camera.zFar  = 100;
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.position = SCNVector3Make(0, 0, 10);
    cameraNode.camera = camera;
    cameraOrbit = [SCNNode node];
    [cameraOrbit addChildNode:cameraNode];
    
    float degrees = scaleBetween(_moonPhase, 0, 360, 0, 1);
    
    [cameraOrbit runAction:[SCNAction rotateByX:degreesToRadians(180.0) y:degreesToRadians(-degrees) z:0  duration:1]];
//    [cameraOrbit setRotation:SCNVector4Make(degreesToRadians(180.0), degreesToRadians(degrees), 0.0, 0.0)];
    NSLog(@"Moon phase\t%f", _moonPhase);
    
    
    // Lighting
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeSpot;
    lightNode.position = SCNVector3Make(0, 0, 50);
    lightNode.light.orthographicScale = 9;
    lightNode.light.zNear = 0;
    lightNode.light.zFar  = 100;
    lightNode.light.automaticallyAdjustsShadowProjection = TRUE;
    lightNode.light.shadowColor = [UIColor blackColor];
    lightNode.light.shadowMode = SCNShadowModeDeferred;
    
//    SCNNode *sun = [SCNNode node];
//    sun.light = [SCNLight light];
//    sun.light.type = SCNLightTypeAmbient;
//    sun.light.color = [UIColor whiteColor];
//    sun.light.intensity = sun.light.intensity / 4.0;
    
    // Moon
    SCNSphere *moon = [SCNSphere sphereWithRadius:4];
    [moon setSegmentCount:1000];
    SCNMaterial *moonMaterial = [SCNMaterial material];
    moonMaterial.diffuse.contents = [UIImage imageNamed:@"moon-diffuse.png"];
    moon.firstMaterial = moonMaterial;

    SCNNode *moonNode = [SCNNode nodeWithGeometry:moon];
//    [moonNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:1 z:0 duration:3]]];
    
    // TO-DO: Replace moon shadow with earth shadow
    
    // Scene view configuration
    SCNView *scnView = (SCNView *)self;
    scnView.scene = [SCNScene new];
    scnView.allowsCameraControl = YES;
    scnView.showsStatistics = NO;
    scnView.backgroundColor = [UIColor blackColor];
    
    // Node structure
    [scnView.scene.rootNode addChildNode:cameraOrbit];
    [scnView.scene.rootNode addChildNode:lightNode];
//    [scnView.scene.rootNode addChildNode:sun];
    [scnView.scene.rootNode addChildNode:moonNode];
    
}

- (void)renderShadowExample
{
    SCNScene *scene = [SCNScene new];
    self.scene = scene;
    SCNCamera *camera = [SCNCamera new];
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = camera;
    SCNLight *light = [SCNLight new];
    light.type = SCNLightTypeOmni;
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = light;
    lightNode.position = SCNVector3Make(1.5, 1.5, 1.5);
    
    SCNLight *spotlight = [SCNLight new];
    spotlight.type = SCNLightTypeSpot;
    SCNNode *spotlightNode = [SCNNode node];
    spotlightNode.light = spotlight;
    spotlightNode.position = SCNVector3Make(1.5, 1.5, 1.5);
    
    SCNBox *cubeGeometry = [SCNBox boxWithWidth:1.0 height:1.0 length:1.0 chamferRadius:0.1];
    SCNNode *cubeNode = [SCNNode nodeWithGeometry:cubeGeometry];
    [cubeNode setCastsShadow:TRUE];
    [scene.rootNode addChildNode:spotlightNode];
    [scene.rootNode addChildNode:lightNode];
    [scene.rootNode addChildNode:cameraNode];
    [scene.rootNode addChildNode:cubeNode];
    cameraNode.position = SCNVector3Make(-3.0, 3.0, 3.0);
    SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:cubeNode];
    constraint.gimbalLockEnabled = TRUE;
    cameraNode.constraints = @[constraint];
    //allows user to move camera with touch
    self.allowsCameraControl = TRUE;
    SCNPlane *planeGeometry = [SCNPlane planeWithWidth:100.0 height:100.0];
    SCNNode *planeNode = [SCNNode nodeWithGeometry:planeGeometry];
    planeNode.eulerAngles = SCNVector3Make(degreesToRadians(-90.0), 0, 0);
    planeNode.position = SCNVector3Make(0, -0.5, 0);
    
    [scene.rootNode addChildNode:lightNode];
    [scene.rootNode addChildNode:cameraNode];
    [scene.rootNode addChildNode:cubeNode];
    [scene.rootNode addChildNode:planeNode];
    
    planeNode.position = SCNVector3Make(0, -0.5, 0);
    SCNMaterial *greenMaterial = [SCNMaterial new];
    greenMaterial.diffuse.contents = [UIColor greenColor];
    cubeGeometry.materials = @[greenMaterial];
    
    SCNMaterial *blueMaterial = [SCNMaterial new];
    blueMaterial.diffuse.contents = [UIColor blueColor];
    planeGeometry.materials = @[blueMaterial];
}

// For restricting manual rotation to the Y-axis only
- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        shouldRotateSphere = TRUE;
        NSLog(@"UIGestureRecognizerStateBegan");
    } else if (sender.state == UIGestureRecognizerStateChanged && shouldRotateSphere
               && fabs([sender translationInView:sender.view].y) > 10.0)
    {
        shouldRotateSphere = FALSE;
        [cameraOrbit runAction:[SCNAction rotateByX:0 y:degreesToRadians([sender translationInView:sender.view].y) z:0 duration:1]];
        
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
    }
}



@end


