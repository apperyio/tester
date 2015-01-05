//
//  EXProjectsViewController.h
//  Appery
//
//  Created by Sergey Seroshtan on 30.07.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//
//  Displays information about projects provided by appery.io service (@see EXApperyService class).
//      It also provides ability to load them in the embedded PhoneGap container.
//

#import <UIKit/UIKit.h>

#import "EXApperyService.h"
#import "EXProjectMetadata.h"

/// @name Additional types
typedef void(^EXProjectsMetadataViewControllerCompletionBlock)(BOOL succeeded);

/**
 * This protocol provides callback interface for EXProjectsViewController events observing.
 */
@protocol EXProjectsObserver <NSObject>

@optional
/**
 * Fires when user taps on some project metadata.
 */
- (void) projectMetadataWasSelected: (EXProjectMetadata *) projectMetadata;

/**
 * Fires when user logged out from the service.
 */
- (void) logoutCompleted;

@end

@interface EXProjectsMetadataViewController : UIViewController

/// @name UI properties
@property (retain, nonatomic) IBOutlet UITableView *rootTableView;

@property (retain, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *sortByDateButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *sortByNameButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *folderButton;
@property (retain, nonatomic) UIRefreshControl *refreshControl;

/// @name UI actions
- (IBAction)logoutButtonPressed:(id)sender;
- (IBAction)sortByDateButtonPressed:(id)sender;
- (IBAction)sortByNameButtonPressed:(id)sender;
- (IBAction)selectFolderButtonPressed:(id)sender;
- (void)reloadProjects;

/**
 * Reference to the appery.io web service.
 * EXProjectsViewController uses this property to access to appery.io service for:
 *  - load projects metadata
 *  - logout from service
 *  - load project
 *  - etc
 * So this property should be defined for correct work.
 */
@property (nonatomic, retain) EXApperyService *apperyService;

/** @name EXProjectsObserver protocol support */
/**
 * Add projects observer.
 */
- (void) addProjectsObserver: (id<EXProjectsObserver>) observer;

/**
 * Remove projects observer.
 */
- (void) removeProjectsObserver: (id<EXProjectsObserver>) observer;

/**
 * Initialize Projects Metadata
 */
- (void) initializeProjectsMetadata:(NSArray *) projectsMetadata;

/**
 * Loads projects metadata.
 */
- (void) loadProjectsMetadataCompletion:(EXProjectsMetadataViewControllerCompletionBlock)completion;

/**
 * Perform logout process.
 */
- (void) logoutFromService;

@end
