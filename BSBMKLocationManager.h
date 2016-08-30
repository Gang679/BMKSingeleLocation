//
//  BSBMKLocationManager.h
//  CoffeeMe
//
//  Created by cbs on 16/8/30.
//  Copyright © 2016年 CBS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>

typedef void (^BMKLocatingCompletionBlock)(CLLocation *location, BMKReverseGeoCodeResult *regeocode, NSError *error);

@interface BSBMKLocationManager : NSObject

@property(nonatomic, assign) BOOL isSingleLocation;
@property(nonatomic, assign) BOOL isReGeocode;

@property(nonatomic, assign) CLLocationAccuracy desiredAccuracy;
@property(nonatomic, assign) CLLocationDistance distanceFilter;

@property(nonatomic ,  copy) BMKLocatingCompletionBlock locationBlock;

@property(nonatomic, readonly,   copy) BMKReverseGeoCodeResult *regeocode;
@property(nonatomic, readonly, strong) CLLocation *currentLocation;

+ (void)requestLocationWithReGeocode:(BOOL)isReGeocode completionBlock:(BMKLocatingCompletionBlock)completionBlock;

- (void)startUserLocationService;
- (void)stopUserLocationService;

@end

@interface BMKObjManager : NSObject

@property(nonatomic, readonly, strong)NSMutableArray *objArray;

+ (instancetype)manager;

@end;
