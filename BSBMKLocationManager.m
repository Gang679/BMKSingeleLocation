//
//  BSBMKLocationManager.m
//  CoffeeMe
//
//  Created by cbs on 16/8/30.
//  Copyright © 2016年 CBS. All rights reserved.
//

#import "BSBMKLocationManager.h"


@implementation BMKObjManager
@synthesize objArray = _objArray;

+ (instancetype)manager{
    
    static BMKObjManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BMKObjManager alloc] init];
    });
    
    return manager;
}
- (NSMutableArray *)objArray{
    if (_objArray == nil) {
        _objArray = [[NSMutableArray alloc] init];
    }
    return _objArray;
}
@end

@interface BSBMKLocationManager ()<BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>

@property(nonatomic ,strong) BMKLocationService *bmkLocService;
@property(nonatomic ,strong) BMKGeoCodeSearch   *geoCodeSearch;

@end

@implementation BSBMKLocationManager

@synthesize currentLocation = _currentLocation;

+ (void)requestLocationWithReGeocode:(BOOL)isReGeocode completionBlock:(BMKLocatingCompletionBlock)completionBlock{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BSBMKLocationManager *locationService = [[BSBMKLocationManager alloc] init];
        
        locationService.locationBlock = completionBlock;
        
        locationService.isSingleLocation = YES;
        locationService.isReGeocode = isReGeocode;
        
        [locationService startUserLocationService];
        
        [[BMKObjManager manager].objArray addObject:locationService];
        NSLog(@"%ld",[BMKObjManager manager].objArray.count);
    });
}

- (void)startUserLocationService{
    [self.bmkLocService startUserLocationService];
}
- (void)stopUserLocationService{
    [self.bmkLocService stopUserLocationService];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
    
}
- (void)setup{
    
    _bmkLocService = [[BMKLocationService alloc] init];
    //设定定位的最小更新距离，这里设置 200m 定位一次，频繁定位会增加耗电量
    _bmkLocService.distanceFilter = 30;
    //设定定位精度
    _bmkLocService.desiredAccuracy = kCLLocationAccuracyBest;
    //设置代理
    _bmkLocService.delegate = self;
    
    //获取位置信息
    _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    _geoCodeSearch.delegate = self;
}
- (void)setDistanceFilter:(CLLocationDistance)distanceFilter{
    _distanceFilter = distanceFilter;
    self.bmkLocService.distanceFilter = distanceFilter;
}
- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy{
    _desiredAccuracy = desiredAccuracy;
    self.bmkLocService.desiredAccuracy = desiredAccuracy;
}
//位置更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    
    _currentLocation = userLocation.location;
    if (_isSingleLocation) {
        //停止定位
        [self.bmkLocService stopUserLocationService];
    }
    if (_isReGeocode) {
        
        BMKReverseGeoCodeOption *reverseGeoCodeOption = [[BMKReverseGeoCodeOption alloc] init];
        reverseGeoCodeOption.reverseGeoPoint = self.currentLocation.coordinate;
    
        [self.geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
    }else{
        if (self.locationBlock) {
            self.locationBlock(self.currentLocation, nil, nil);
            
            if (_isSingleLocation) {
                [[BMKObjManager manager].objArray removeObject:self];
            }
        }
    }
}
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (self.locationBlock) {
        if (error) {
            self.locationBlock(self.currentLocation, nil, nil);
            if (_isSingleLocation) {
                [[BMKObjManager manager].objArray removeObject:self];
            }
        }else{
            self.locationBlock(self.currentLocation, result, nil);
            if (_isSingleLocation) {
                [[BMKObjManager manager].objArray removeObject:self];
            }
        }
    }
}
//方向更新
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation{
    
}
//定位失败
- (void)didFailToLocateUserWithError:(NSError *)error{
    
    //停止定位
    if (_isSingleLocation) {
        [self.bmkLocService stopUserLocationService];
    }
    
    if (self.locationBlock) {
        self.locationBlock(nil, nil, error);
        if (_isSingleLocation) {
            [[BMKObjManager manager].objArray removeObject:self];
        }
    }
}

@end
