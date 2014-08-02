//
//  TwitterComposeScreenViewController.h
//  Feed
//
//  Created by George on 2014-05-15.
//  Copyright (c) 2014 George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TwitterComposeScreenViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UILabel *char_count;
@property (nonatomic, strong) UITextView *inputText;


@property (nonatomic, strong) UIView *kNavBar;
@property (nonatomic, strong) UILabel *tweet;
@property (nonatomic, strong) UIView *middle_section;
@property (nonatomic, strong) UIImageView *profileImage;
@property (nonatomic, strong) UILabel *screen_name;
@property (nonatomic, strong) UILabel *username;
@property (nonatomic, strong) UIView *interactions;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;


@property (nonatomic, strong) NSMutableArray *photos;


@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

-(id)initWithName:(NSString *)replyTo stats:(NSString *)state;

-(id)initForQuote:(NSString *)quote;
@end
