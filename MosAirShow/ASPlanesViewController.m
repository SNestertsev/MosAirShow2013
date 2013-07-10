//
//  ASPlanesViewController.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 28.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASPlanesViewController.h"
#import "ASPlanesModel.h"
#import "ASPlanesSection.h"
#import "ASPlane.h"

@interface ASPlanesViewController ()

@property (nonatomic, strong) ASPlanesModel *filteredPlanes;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ASPlanesViewController

@synthesize planes = _planes;
@synthesize filteredPlanes = _filteredPlanes;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(ASPlanesModel *)filteredPlanes
{
    if (!_filteredPlanes) {
        return _planes;
    }
    return _filteredPlanes;
}

-(void)filterPlanes
{
    if (self.searchBar.text.length == 0) {
        self.filteredPlanes = nil;
        return;
    }
    NSString *searchText = self.searchBar.text;
    self.filteredPlanes = [[ASPlanesModel alloc] init];
    for (ASPlanesSection *section in self.planes.sections) {
        if ([section.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
            // Entire section matches the search text
            [self.filteredPlanes.sections addObject:section];
            continue;
        }
        for (ASPlane *plane in section.planes) {
            if ([plane.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                ASPlanesSection *sec = [self.filteredPlanes addSectionWithName:section.name andIndex:section.index];
                [sec addPlaneWithName:plane.name inRect:plane.screenRect labelInCorner:plane.labelCorner withImage:plane.imageFileName andDescription:plane.descriptionFile];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.filteredPlanes.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ASPlanesSection *sec = [self.filteredPlanes.sections objectAtIndex:section];
    return sec.planes.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ASPlanesSection *sec = [self.filteredPlanes.sections objectAtIndex:section];
    return sec.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ASPlanesSection *sec = [self.filteredPlanes.sections objectAtIndex:indexPath.section];
    cell.textLabel.text = ((ASPlane*)[sec.planes objectAtIndex:indexPath.row]).name;
    return cell;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.filteredPlanes.sectionNames;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Search bar delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterPlanes];
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self filterPlanes];
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
    
}

- (IBAction)tapGesture:(id)sender
{
    [self.searchBar resignFirstResponder];
}

@end
