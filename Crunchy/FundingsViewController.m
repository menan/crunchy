//
//  FundingsViewController.m
//  Crunchy
//
//  Created by Menan Vadivel on 2/22/2014.
//  Copyright (c) 2014 Menan Vadivel. All rights reserved.
//

#import "FundingsViewController.h"
//#import "DetailViewController.h"

@interface FundingsViewController ()

@end

@implementation FundingsViewController
@synthesize objects;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        objects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSLog(@"data: %@",objects);
    
    [self.tableView reloadData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSLog(@"return key: %@", [self getValuesAtIndex:indexPath.row]);
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    // Configure the cell...
    cell.textLabel.text = [[self getValuesAtIndex:indexPath.row] objectForKey:@"value"];
    cell.detailTextLabel.text = [[self getValuesAtIndex:indexPath.row] objectForKey:@"key"];
    return cell;
}

- (NSDictionary *) getValuesAtIndex:(NSInteger) index{
    NSArray *keys = @[@"company", @"financial_org", @"person"];
    NSArray *keysStr = @[@"Company", @"Financial Organization", @"Person"];
    NSArray *keysType = @[@"company", @"financial-organization", @"person"];
    
    
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
    for (NSString *key in keys) {
        id val = [[objects objectAtIndex:index] objectForKey:key];
        if (val != (id)[NSNull null]){
            if ([key isEqualToString:[keys objectAtIndex:2]]) {
                [returnDict setObject:[NSString stringWithFormat:@"%@ %@", [val objectForKey:@"first_name"],[val objectForKey:@"last_name"]] forKey:@"value"];
            }
            else{
                
                [returnDict setObject:[val objectForKey:@"name"] forKey:@"value"];
            }
            
            [returnDict setObject:[keysType objectAtIndex:[keys indexOfObject:key]] forKey:@"type"];
            [returnDict setObject:[keysStr objectAtIndex:[keys indexOfObject:key]] forKey:@"key"];
            [returnDict setObject:[val objectForKey:@"permalink"] forKey:@"permalink"];
        }
    }
    return returnDict;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    DetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
//    NSMutableDictionary* object = [[NSMutableDictionary alloc] init];
//    
//    [self.navigationController pushViewController:detail animated:YES];
//    
//    NSString *perm = [NSString stringWithFormat:@"%@/%@/%@.json?",[Cruncher crunchBaseURL],[[self getValuesAtIndex:indexPath.row] objectForKey:@"type"],[[self getValuesAtIndex:indexPath.row] objectForKey:@"permalink"]];
//    
//    [object setObject:perm forKey:@"permalink"];
//    [object setObject:[[self getValuesAtIndex:indexPath.row] objectForKey:@"type"] forKey:@"type"];
//    
//    [detail setDetailItem:object];
    
    
    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
