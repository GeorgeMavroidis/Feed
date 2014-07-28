//
//  TwitterComposeScreenViewController.m
//  Feed
//
//  Created by George on 2014-05-15.
//  Copyright (c) 2014 George. All rights reserved.
//

#import "TwitterComposeScreenViewController.h"
#import "STTwitterAPI.h"
#import "AsyncImageView.h"
#import "UIImageView+WebCache.h"


@interface TwitterComposeScreenViewController (){
    ALAssetsLibrary *library;
    NSArray *imageArray;
    NSMutableArray *assets, *pictures;
    NSString *replT, *statID;
}

@end
static int count=0;
@implementation TwitterComposeScreenViewController
@synthesize char_count, inputText, kNavBar, tweet, middle_section, profileImage, screen_name, username, interactions, placeholderLabel, picker, mapView, locationManager, currentLocation, photos, footer;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
-(void)loadImages {
    if(!assets){
        imageArray = [[NSArray alloc] init];
        assets = [[NSMutableArray alloc] init];
        pictures = [[NSMutableArray alloc] init];
        NSMutableArray *mutableArray =[[NSMutableArray alloc]init];
        
        NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
        
        ALAssetsLibrary*library = [[ALAssetsLibrary alloc] init];
        
        void (^enumerate)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
            if ([[group valueForProperty:@"ALAssetsGroupPropertyType"] intValue] == ALAssetsGroupSavedPhotos){
                //NSLog(@"Camera roll");
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if(result != nil) {
                        if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                            [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                            if([result defaultRepresentation].filename != nil){
                                NSURL *url= (NSURL*) [[result defaultRepresentation] url];
                                [assets addObject:url];
                                
                                [library assetForURL:url
                                         resultBlock:^(ALAsset *asset) {
                                             [pictures addObject:[asset thumbnail]];
                                         }
                                        failureBlock:^(NSError *error){ NSLog(@"test:Fail"); } ];

                            }
                        }
                    }
                }];
            }
            [inputText resignFirstResponder];
            [self.collectionView reloadData];
        };
        
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                               usingBlock:enumerate
                             failureBlock:nil];
        
    }else{
        [inputText resignFirstResponder];
        [self.collectionView reloadData];
        
    }
    
}
-(void)reloadImages {
    imageArray = [[NSArray alloc] init];
    assets = [[NSMutableArray alloc] init];
    pictures = [[NSMutableArray alloc] init];
    NSMutableArray *mutableArray =[[NSMutableArray alloc] init];
    
    NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
    ALAssetsLibrary*library = [[ALAssetsLibrary alloc] init];
    
    void (^enumerate)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        if ([[group valueForProperty:@"ALAssetsGroupPropertyType"] intValue] == ALAssetsGroupSavedPhotos){
            NSLog(@"Camera roll");
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result != nil) {
                    if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                        if([result defaultRepresentation].filename != nil){
                            NSURL *url= (NSURL*) [[result defaultRepresentation] url];
                            [assets addObject:url];
                            
                            [library assetForURL:url
                                     resultBlock:^(ALAsset *asset) {
                                         [pictures addObject:[asset thumbnail]];
                                     }
                                    failureBlock:^(NSError *error){ NSLog(@"test:Fail"); } ];
                            
                            }
                        }
                    }
                }];
            
        }
        [inputText resignFirstResponder];
        [self.collectionView reloadData];
    };
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                               usingBlock:enumerate
                             failureBlock:nil];
        
    
    
}
-(id)initWithName:(NSString *)replyTo stats:(NSString *)state{
    self = [super init];
    if (self) {
        replT = replyTo;
        statID = state;
        
        NSLog(replT);
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    float navController_y = 0;
    float navController_height = 40;
    
    kNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, navController_height)];
    [kNavBar setBackgroundColor:[UIColor whiteColor]];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,kNavBar.frame.size.height-0.5, screenWidth, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [kNavBar addSubview:lineView];
    [self.view addSubview:kNavBar];
    
    UILabel *cancel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, kNavBar.frame.size.height)];
    cancel.text = @"Cancel";
    cancel.textColor = [UIColor colorWithRed: 64/255.0 green: 153/255.0 blue:255/255.0 alpha: 1.0];
    [kNavBar addSubview:cancel];
    
    UITapGestureRecognizer *canc = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
    [cancel setUserInteractionEnabled:YES];
    canc.numberOfTapsRequired = 1;
    [cancel addGestureRecognizer:canc];
    
    tweet = [[UILabel alloc] initWithFrame:CGRectMake(kNavBar.frame.size.width-55, 0, 50, kNavBar.frame.size.height)];
    tweet.text = @"Tweet";
    tweet.textColor = [UIColor colorWithRed: 64/255.0 green: 153/255.0 blue:255/255.0 alpha: 1.0];
    [kNavBar addSubview:tweet];
    
    UITapGestureRecognizer *sendTweet = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tweettweet)];
    [tweet setUserInteractionEnabled:YES];
    sendTweet.numberOfTapsRequired = 1;
    [tweet addGestureRecognizer:sendTweet];
    tweet.userInteractionEnabled = YES;
    
    char_count = [[UILabel alloc] initWithFrame:CGRectMake(kNavBar.frame.size.width-110, 0, 50, kNavBar.frame.size.height)];
    char_count.text = @"140";
    char_count.textAlignment = NSTextAlignmentRight;
    char_count.textColor = [UIColor colorWithRed: 0/255.0 green: 0/255.0 blue:0/255.0 alpha: 0.3];
    [kNavBar addSubview:char_count];
    
    middle_section = [[UIView alloc] initWithFrame:CGRectMake(0, kNavBar.frame.size.height, screenWidth, screenHeight-216-40-kNavBar.frame.size.height)];
    [middle_section setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:middle_section];
    
    inputText = [[UITextView alloc] initWithFrame:CGRectMake(7, 50, screenWidth-20, 150)];
    inputText.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    inputText.delegate = self;
    inputText.keyboardType = UIKeyboardTypeTwitter;
    NSString* firstName = [[replT componentsSeparatedByString:@" "] lastObject];
    inputText.text = [NSString stringWithFormat:@"%@ ", firstName];
    [middle_section addSubview:inputText];
    
    profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    [profileImage setBackgroundColor:[UIColor whiteColor]];
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *storePath = [documentsDirectory stringByAppendingPathComponent:@"twitter_auth"];
    NSMutableArray *twitter_auth = [NSMutableArray arrayWithContentsOfFile:storePath];
    //oAuthToken, oAuthTokenSecret, @"4tIoaRQHod1IQ00wtSmRw", @"S6GATtE4xirn5WlfW79d6aSH4ciMD196hPQuL2g52M8",
    NSString *oauthToken = [twitter_auth objectAtIndex:0];
    NSString *oauthTokenSecret = [twitter_auth objectAtIndex:1];
    NSString *consumerToken = [twitter_auth objectAtIndex:2];
    NSString *consumerTokenSecret = [twitter_auth objectAtIndex:3];
    
    screen_name = [[UILabel alloc] initWithFrame:CGRectMake(50, profileImage.frame.origin.y, screenWidth, 15)];
    [screen_name setBackgroundColor:[UIColor clearColor]];
    screen_name.font =[UIFont fontWithName:@"ArialRoundedMTBold" size:14.0f];
    [middle_section addSubview:screen_name];
    
    username = [[UILabel alloc] initWithFrame:CGRectMake(50, screen_name.frame.origin.y+screen_name.frame.size.height, screenWidth, 15)];
    username.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:11.0f];
    [username setTextColor:[UIColor lightGrayColor]];
    [username setBackgroundColor:[UIColor clearColor]];
    
    [middle_section addSubview:username];
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerToken consumerSecret:consumerTokenSecret oauthToken:oauthToken oauthTokenSecret:oauthTokenSecret];

    [twitter verifyCredentialsWithSuccessBlock:^(NSString *usernam) {
        [twitter getUserInformationFor:usernam successBlock:^(NSDictionary *user) {
//            NSLog(@"%@", user);
            NSString *thing = [user objectForKey:@"profile_image_url"];
            [thing stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
            profileImage.imageURL = [NSURL URLWithString:thing];
            username.text = usernam;
            screen_name.text = [user objectForKey:@"name"];
        } errorBlock:^(NSError *error) {
            
        }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"ee %@", [error localizedDescription]);
    }];
    
    
    

    [middle_section addSubview:profileImage];
    CALayer *imageLayer = profileImage.layer;
    [imageLayer setCornerRadius:4];
    [imageLayer setMasksToBounds:YES];
    
   
    
    interactions = [[UIView alloc] initWithFrame:CGRectMake(0, middle_section.frame.size.height+middle_section.frame.origin.y, screenWidth, 40)];
    [interactions setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:interactions];
    
    UIView *location = [[UIView alloc] initWithFrame:CGRectMake(0, 0, interactions.frame.size.width/3, interactions.frame.size.height)];
    UIImageView *location_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location.png"]];
    location_icon.frame = CGRectMake(location.frame.size.width/2-15, 5, 30, 30);
    [location addSubview:location_icon];
    [interactions addSubview:location];
    
    UITapGestureRecognizer *location_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseLocation:)];
    [location setUserInteractionEnabled:YES];
    location_tap.numberOfTapsRequired = 1;
    [location addGestureRecognizer:location_tap];
    
    UIView *camera = [[UIView alloc] initWithFrame:CGRectMake(location.frame.size.width, 0, interactions.frame.size.width/3, interactions.frame.size.height)];
    UIImageView *camera_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera.png"]];
    camera_icon.frame = CGRectMake(location.frame.size.width/2-15, 5, 30, 30);
    [camera addSubview:camera_icon];
    [interactions addSubview:camera];
    
    
    UIView *roll = [[UIView alloc] initWithFrame:CGRectMake(camera.frame.size.width+location.frame.size.width, 0, interactions.frame.size.width/3, interactions.frame.size.height)];
    UIImageView *select_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select.png"]];
    select_icon.frame = CGRectMake(location.frame.size.width/2-15, 5, 30, 30);
    [roll addSubview:select_icon];
    [interactions addSubview:roll];
    
    UITapGestureRecognizer *camera_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePhoto:)];
    [camera setUserInteractionEnabled:YES];
    camera_tap.numberOfTapsRequired = 1;
    [camera addGestureRecognizer:camera_tap];

    UITapGestureRecognizer *roll_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickPhoto:)];
    [roll setUserInteractionEnabled:YES];
    roll_tap.numberOfTapsRequired = 1;
    [roll addGestureRecognizer:roll_tap];

    
    [self populateUserInfo];
    [inputText becomeFirstResponder];
    
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, inputText.frame.size.width - 20.0, 34.0)];
//    [placeholderLabel setText:@"What's happening?"];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setFont:[inputText font]];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    
    // textView is UITextView object you want add placeholder text to
    [inputText addSubview:placeholderLabel];
    
    if([char_count.text isEqualToString:@"140"]){
        [tweet setTextColor:[UIColor lightGrayColor]];
    }else{
        tweet.textColor = [UIColor colorWithRed: 64/255.0 green: 153/255.0 blue:255/255.0 alpha: 1.0];
    }
    footer = [[UIView alloc] initWithFrame:CGRectMake(0, (interactions.frame.size.height+interactions.frame.origin.y), screenWidth, screenHeight)];
    [footer setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:footer];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    CGFloat s = (screenWidth/4)-12;
    flowLayout.itemSize = CGSizeMake(s, s);
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(5, 5, screenWidth-10, screenHeight-40) collectionViewLayout:flowLayout];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.collectionView setBackgroundColor:[UIColor blackColor]];
    
    [footer addSubview:self.collectionView];
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat s = (screenWidth/4)-12;
    static NSString *cellIdentifier = @"cellIdentifier";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UIImageView *t = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, s, s)];
    
    ALAssetsLibrary*library = [[ALAssetsLibrary alloc] init];
    
    if(pictures.count != 0){
        /*NSURL *url= (NSURL*) [assets objectAtIndex:[assets count]-indexPath.row-1];
        
        [library assetForURL:url
                 resultBlock:^(ALAsset *asset) {
                     t.image = [UIImage imageWithCGImage:[asset thumbnail]];
                 }
                failureBlock:^(NSError *error){ NSLog(@"test:Fail"); } ];*/
        t.image = [UIImage imageWithCGImage:CFBridgingRetain([assets objectAtIndex:[assets count]-indexPath.row-1])];
    }
    
    [cell.contentView addSubview:t];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return cell;
    
}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}
+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [assets count];
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
    // here we get the current location
}
- (IBAction)takePhoto:(UIButton *)sender {
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}
- (IBAction)pickPhoto:(UIButton *)sender {
    if(mapView) [mapView setHidden:YES];
    [self loadImages];
    [self.collectionView reloadData];
    [self reloadImages];
}
- (IBAction)chooseLocation:(UIButton *)sender {
    [inputText resignFirstResponder];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, interactions.frame.origin.y+interactions.frame.size.height, screenWidth, screenHeight-(interactions.frame.origin.y+interactions.frame.size.height))];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    mapView.mapType = MKMapTypeStandard;
    mapView.userInteractionEnabled = NO;
    [self.view addSubview:mapView];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
    
    CLLocation *location = [locationManager location];
    
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    float latitude = coordinate.latitude;
    float longitude = coordinate.longitude;
    mapView.region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
    
}
-(void)tweettweet{
    if(tweet.textColor != [UIColor lightGrayColor]){
        NSString *documentsDirectory = [NSHomeDirectory()
                                        stringByAppendingPathComponent:@"Documents"];
        NSString *storePath = [documentsDirectory stringByAppendingPathComponent:@"twitter_auth"];
        NSMutableArray *twitter_auth = [NSMutableArray arrayWithContentsOfFile:storePath];
        //oAuthToken, oAuthTokenSecret, @"4tIoaRQHod1IQ00wtSmRw", @"S6GATtE4xirn5WlfW79d6aSH4ciMD196hPQuL2g52M8",
        NSString *oauthToken = [twitter_auth objectAtIndex:0];
        NSString *oauthTokenSecret = [twitter_auth objectAtIndex:1];
        NSString *consumerToken = [twitter_auth objectAtIndex:2];
        NSString *consumerTokenSecret = [twitter_auth objectAtIndex:3];
        
        STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerToken consumerSecret:consumerTokenSecret oauthToken:oauthToken oauthTokenSecret:oauthTokenSecret];

        [twitter postStatusUpdate:inputText.text
                inReplyToStatusID:statID
                         latitude:nil
                        longitude:nil
                          placeID:nil
               displayCoordinates:nil
                         trimUser:nil
                     successBlock:^(NSDictionary *status) {
                         [self cancel];
                     } errorBlock:^(NSError *error) {
                         // ...
                     }];
 
    }
    
}
-(void)cancel{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)populateUserInfo{
    
    
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView{
    char_count.text = [NSString stringWithFormat:@"%d", 140-inputText.text.length];
    if(![inputText hasText]) {
        [inputText addSubview:placeholderLabel];
        
    } else if ([[inputText subviews] containsObject:placeholderLabel]) {
        [placeholderLabel removeFromSuperview];
    }
    if([char_count.text isEqualToString:@"140"]){
        [tweet setTextColor:[UIColor lightGrayColor]];
    }else{
        tweet.textColor = [UIColor colorWithRed: 64/255.0 green: 153/255.0 blue:255/255.0 alpha: 1.0];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if (![inputText hasText]) {
        [inputText addSubview:placeholderLabel];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    //self.imageView.image = chosenImage;

    UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil);
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self reloadImages];
        [self.collectionView reloadData];
    }];
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint scrollVelocity = [self.collectionView.panGestureRecognizer velocityInView:self.collectionView.superview];
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    if(translation.y > 0){
        float scrollViewHeight = scrollView.frame.size.height;
        float scrollContentSizeHeight = scrollView.contentSize.height;
        float scrollOffset = scrollView.contentOffset.y;
        if (scrollOffset < -80){
            
            [UIView animateWithDuration:0.4
                             animations:^{
                                 interactions.frame = CGRectMake(0, middle_section.frame.size.height+middle_section.frame.origin.y, screenWidth, 40);
                                 footer.frame = CGRectMake(0, interactions.frame.size.height+interactions.frame.origin.y, screenWidth, screenHeight);
                             }];
        }
        
    } else{
        // react to dragging up
        if(interactions.frame.origin.y > 0){
            [UIView animateWithDuration:0.4
                             animations:^{
                                 footer.frame = CGRectMake(0, 40, screenWidth, screenHeight);
                                 interactions.frame = CGRectMake(0, 0, screenWidth, 40);
                             }];
        }
    }
}
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    footer.center = CGPointMake(footer.center.x, footer.center.y + translation.y/6);
    interactions.center = CGPointMake(interactions.center.x, interactions.center.y+translation.y/6);
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    UICollectionViewCell *datasetCell =[collectionView cellForItemAtIndexPath:indexPath];
    datasetCell.hidden = YES;
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *datasetCell =[collectionView cellForItemAtIndexPath:indexPath];
    datasetCell.hidden = NO;
}
@end
