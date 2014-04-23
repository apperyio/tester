//
//  EXSelectViewController.m
//  Appery
//
//  Created by Sergey Seroshtan on 14.05.13.
//  Copyright (c) 2013Exadel Inc. All rights reserved.
//

#import "EXSelectViewController.h"

@interface EXSelectViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;

@end

@implementation EXSelectViewController

#pragma mark - Initialization

- (id)initWithTitle:(NSString *)title
{
    if (self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil]) {
        self.title = title;
    }
    return self;
}

- (IBAction)doneButtonPressed:(id)sender
{
    if (self.completion != nil) {
        self.completion(YES, self.selection);
        self.completion = nil;
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    if (self.completion != nil) {
        self.completion(NO, nil);
        self.completion = nil;
    }
}

- (void)updateUI
{
    [self.pickerView reloadAllComponents];

    if ([self.data containsObject:self.selection]) {
        NSUInteger selectionRow = [self.data indexOfObject:self.selection];
        [self.pickerView selectRow:selectionRow inComponent:0 animated:NO];
    } else {
        self.selection = nil;
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.data.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row < self.data.count) {
        return [self.data objectAtIndex:row];
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row < self.data.count) {
        self.selection = [self.data objectAtIndex:row];
    } else {
        self.selection = nil;
    }
}

@end
