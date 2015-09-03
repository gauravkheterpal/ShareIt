//
//  ShareItAppDelegate.swift
//  ShareIt
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

@UIApplicationMain
class ShareItAppDelegate: UIResponder, UIApplicationDelegate, SFAuthenticationManagerDelegate {
    
    var window: UIWindow?

    override init() {
        super.init()

        // Set Salesforce SDK log level
        SFLogger.setLogLevel(SFLogLevelDebug)

        // Initialize SFUserAccountManager
        let dictonaryObj = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource(nil, ofType: "plist")!)
        SFUserAccountManager.sharedInstance().oauthClientId = dictonaryObj!.objectForKey("SFDCOAuthConsumerKey") as! String
        SFUserAccountManager.sharedInstance().oauthCompletionUrl = dictonaryObj!.objectForKey("SFDCOAuthCallbackURL") as! String
        SFUserAccountManager.sharedInstance().scopes = NSSet(array: ["api"]) as Set<NSObject>
        SFAuthenticationManager.sharedManager().addDelegate(self)
    }


    deinit {
        // Un-register the delegates
        SFAuthenticationManager.sharedManager().removeDelegate(self)
    }

    /*!
     This function is called when the launch process is almost done and the app is almost ready to run.
     @param application -> the application
     @param launchOptions -> the launch options
     @return Always true in this implementation
     */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Start login process
        login()
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 46.0/255.0, green: 140.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        return true
    }

    
    // Start Salesforce login process.
    func login() {
        // Call SFAuthenticationManager to start user login process
        SFAuthenticationManager.sharedManager().loginWithCompletion(
            {
                // "success" closure
                (SFOAuthInfo) in
                // save salesforce user account
                if !SIChatterModel.saveSFUserAccount(SFUserAccountManager.sharedInstance().currentUser) {
                    NSLog("ShareItAppDelegate.login: failed to save user account.")
                }
                // switch to main view
                let navigationViewController = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewControllerWithIdentifier("NavigationView") as! UIViewController
                self.window!.rootViewController = navigationViewController
            },
            failure: {
                // "failure" closure
                (SFOAuthInfo, NSError) in
                // logout user anyway
                SFAuthenticationManager.sharedManager().logout()
            }
        )
    }

    /*!
     This function is called when user is logged out.
     @param manager -> the SFAuthenticationManager
     */
    func authManagerDidLogout(manager : SFAuthenticationManager) {
        // Reset app view state to its initial state
        self.initializeAppViewState()
        // Remove User Account
        if !SIChatterModel.saveSFUserAccount(nil) {
            NSLog("ShareItAppDelegate.authManagerDidLogout: failed to remove user account.")
        }
        // Start login process
        login()
    }

    
    // Initializes the app view state.
    
    func initializeAppViewState() {
        // Load initial view
        self.window!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            as? UIViewController;
        self.window!.makeKeyAndVisible()
    }
}
