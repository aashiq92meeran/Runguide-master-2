//
//  fbloginViewController.m
//  Runguide
//
//  Created by BSA Univ20 on 30/01/14.
//  Copyright (c) 2014 Hibrise Technologies. All rights reserved.
//

#import "fbloginViewController.h"
#import "Runguide.h"
#import "AppDelegate.h"

@interface fbloginViewController ()
{
    BOOL isUserName;
}
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


@end

@implementation fbloginViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Create a FBLoginView to log the user in with basic, email and likes permissions
        // You should ALWAYS ask for basic permissions (basic_info) when logging the user in
        FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_likes"]];
        
        // Set this loginUIViewController to be the loginView button's delegate
        loginView.delegate = self;
        
        // Align the button in the center horizontally
        loginView.frame = CGRectOffset(loginView.frame,
                                       (self.view.center.x - (loginView.frame.size.width / 2)),
                                       5);
        
        // Align the button in the center vertically
        loginView.center = self.view.center;
        
        // Add the button to the view
        [self.view addSubview:loginView];
        
        
    }
    return self;
}
// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    self.profilePictureView.profileID = user.id;
    
    
       self.nameLabel.text = user.name;
    NSLog(@" \n username= %@",user.name);
    
   
    NSFetchRequest *fetch=[[NSFetchRequest alloc]initWithEntityName:@"Runguide"];
    NSPredicate *pre=[NSPredicate predicateWithFormat:@"username like %@",self.nameLabel.text];
    [fetch setPredicate:pre];
    
    NSError *error;
    NSArray * data=[self.managedObjectContext executeFetchRequest:fetch error:&error];
    for(NSManagedObject *obj in data)
    {
        
         isUserName=1;
        
    }
    if(isUserName!=1){
    Runguide * newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Runguide" inManagedObjectContext:self.managedObjectContext];
   
    newEntry.username = self.nameLabel.text;
   // NSError *error;
    [_managedObjectContext save:&error];
    }
 
    
}


// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    self.statusLabel.text = @"You're logged in as";
    
    
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.profilePictureView.profileID = nil;
    self.nameLabel.text = @"";
    self.statusLabel.text= @"You're not logged in!";
    
}
// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

-(void)viewDidLoad
{
    //1
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    //2
    self.managedObjectContext = appDelegate.managedObjectContext;
    isUserName=0;
}


@end
