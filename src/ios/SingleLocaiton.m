#import "SingleLocaiton.h"

@implementation SingleLocaiton

#pragma mark - Action Handle

- (void)cleanUpAction {
    //停止定位
    [self.locationManager stopUpdatingLocation];

    [self.locationManager setDelegate:nil];
}

- (void)reGeocodeAction {
    //进行单次带逆地理定位请求
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}

- (id)init {

    [self configLocationManager];

    [self initCompleteBlock];

    return self;
}

- (void)configLocationManager {
    self.locationManager = [[AMapLocationManager alloc] init];

    [self.locationManager setDelegate:self];

    //设置期望定位精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];

    //设置不允许系统暂停定位
//    [self.locationManager setPausesLocationUpdatesAutomatically:NO];

    //设置允许在后台定位
//    [self.locationManager setAllowsBackgroundLocationUpdates:YES];

    //设置定位超时时间
    [self.locationManager setLocationTimeout:DefaultLocationTimeout];

    //设置逆地理超时时间
    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
}


- (void)locAction {
    //进行单次定位请求
    [self.locationManager requestLocationWithReGeocode:NO completionBlock:self.completionBlock];
}


#pragma mark - Initialization

- (void)initCompleteBlock {
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error != nil && error.code == AMapLocationErrorLocateFailed) {
            //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
            NSLog(@"定位错误:{%ld - %@};", (long) error.code, error.localizedDescription);
            return;
        } else if (error != nil
                && (error.code == AMapLocationErrorReGeocodeFailed
                || error.code == AMapLocationErrorTimeOut
                || error.code == AMapLocationErrorCannotFindHost
                || error.code == AMapLocationErrorBadURL
                || error.code == AMapLocationErrorNotConnectedToInternet
                || error.code == AMapLocationErrorCannotConnectToHost)) {
            //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
            NSLog(@"逆地理错误:{%ld - %@};", (long) error.code, error.localizedDescription);
        } else if (error != nil && error.code == AMapLocationErrorRiskOfFakeLocation) {
            //存在虚拟定位的风险：此时location和regeocode没有返回值，不进行annotation的添加
            NSLog(@"存在虚拟定位的风险:{%ld - %@};", (long) error.code, error.localizedDescription);
            return;
        } else {
            //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
        }
        //是否为逆地址编码
        if (regeocode) {

            [self.delegate PositionInfo:location Regeocode:regeocode];
        } else {

            [self.delegate PositionInfo:location Regeocode:regeocode];
        }
    };
}

#pragma mark - Life Cycle

#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager *)locationManager {
    [locationManager requestAlwaysAuthorization];
}

- (void)dealloc {
    [self cleanUpAction];
}
@end;
