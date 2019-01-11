//
//  LunarPhaseCalculator.m
//  Planetary Hour
//
//  Created by Xcode Developer on 12/26/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "LunarPhase.h"

float fixangle( float angle ){
    return angle - 360.0f * ( floor ( angle / 360.0f ) );
}

float torad( float deg ){
    return deg * ( M_PI / 180.0f );
}

float todeg( float rad ){
    return rad * ( 180.0f / M_PI );
}

float dsin( float deg ){
    return sin( torad( deg ) );
}

double jtime( double t ){
    return (t / 86400.0f) + 2440587.5f;
}

float kepler( float m, float ecc ){
    float EPSILON = 0.000001f;
    m = torad(m);
    float e = m;
    float delta;
    
    // first time
    delta = e - ecc * sin(e) - m;
    e -= delta / ( 1.0f - ecc * cos(e) );
    
    // loop
    while( fabsf(delta) > EPSILON ){
        delta = e - ecc * sin(e) - m;
        e -= delta / ( 1.0f - ecc * cos(e) );
    }
    
    return e;
}

@implementation LunarPhase

static LunarPhase *calculator = NULL;
+ (nonnull LunarPhase *)calculator
{
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
                      if (!calculator)
                          calculator = [[self alloc] init];
                  });
    
    return calculator;
}

- (id) init {
    self = [super init];
    if (self) {
        now = [NSDate date];
    }
    return self;
}

- (void) dealloc {
    
}

- (float)phaseForDate:(NSDate *)date
{
    // const
    double Epoch = 2444238.5;
    float Elonge = 278.833540;
    float Elongp = 282.596403;
    float Eccent = 0.016718;
    float Mmlong = 64.975464;
    float Mmlongp = 349.383063;
    float Mlnode = 151.950429;
    float Minc = 5.145396;
    
    NSTimeInterval d = [date timeIntervalSince1970];
    
    double pdate = jtime( (float)d );
    double Day = pdate - Epoch;
    
    double N = fixangle( ( 360.0f / 365.2422f ) * Day );
    double M = fixangle( N + Elonge - Elongp );
    double Ec = kepler( M, Eccent );
    Ec = sqrt( ( 1.0f + Eccent ) / ( 1.0f - Eccent ) ) * tan( Ec / 2.0f );
    Ec = 2.0f * todeg( atan( Ec ) );
    double Lambdasun = fixangle( Ec + Elongp );
    
    double ml = fixangle( 13.1763966f * Day + Mmlong );
    double MM = fixangle( ml - 0.1114041f * Day - Mmlongp );
    double MN = fixangle( Mlnode - 0.0529539f * Day );
    double Ev = 1.2739f * sin( torad( 2.0f * ( ml - Lambdasun ) - MM ) );
    double Ae = 0.1858f * sin( torad( M ) );
    double A3 = 0.37f * sin( torad( M ) );
    double MmP = MM + Ev - Ae - A3;
    double mEc = 6.2886f * sin( torad( MmP ) );
    double A4 = 0.214f * sin( torad( 2.0f * MmP ) );
    double lP = ml + Ev + mEc - Ae + A4;
    double V = 0.6583f * sin( torad( 2.0f * ( lP - Lambdasun ) ) );
    double lPP = lP + V;
    double NP = MN - 0.16f * sin( torad( M ) );
    double y = sin( torad( lPP - NP ) ) * cos( torad( Minc ) );
    double x = cos( torad( lPP - NP ) );
    double Lambdamoon = todeg( atan2( y, x ) );
    Lambdamoon += NP;
    
    double MoonAge = lPP - Lambdasun;
    float mpfrac = fixangle( MoonAge ) / 360.0f;
    
    return mpfrac;
}

@end
