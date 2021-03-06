
#import "LifeViewController.h"
#import "SWRevealViewController.h"
#import "ListEntries.h"
#import "ListEntry.h"

@interface LifeViewController () <UIPopoverPresentationControllerDelegate>

@property (nonatomic) NSMutableArray *events;
@property (nonatomic) NSMutableArray *months;
@property (nonatomic) NSMutableArray *completedTasksSet;

@end

int month;
int i;

@implementation LifeViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//CGFloat h = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
	//self.collectionView.contentOffset = CGPointMake(0, -64);
	
	_dob = [[NSUserDefaults standardUserDefaults] objectForKey:@"dob"];
	NSCalendar *sysCalendar = [NSCalendar currentCalendar];
	NSCalendarUnit unit = NSCalendarUnitMonth;
	NSDateComponents *comp = [sysCalendar components:unit fromDate:_dob toDate:[NSDate date] options:NSCalendarWrapComponents];
	month = [comp month];
	
	[self.navigationController.navigationBar setBackgroundImage:[UIImage new]
												  forBarMetrics:UIBarMetricsDefault];
	self.navigationController.navigationBar.shadowImage = [UIImage new];
	self.navigationController.navigationBar.translucent = YES;
	
	//[self.view sendSubviewToBack:self.collectionView];
	
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	self.collectionView.backgroundColor = [UIColor blackColor];
	
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
	
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	
	// Uncomment the following line to preserve selection between presentations
	// self.clearsSelectionOnViewWillAppear = NO;
	
	// Register cell classes
	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
	
	// Do any additional setup after loading the view.
	
	UIButton *btn = [[UIButton alloc] init];
	UIImage *undoImg = [[UIImage imageNamed:@"cancel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	[btn setImage:undoImg forState:UIControlStateNormal];
	[btn setFrame:CGRectMake(0, 0, 22, 22)];
	btn.tintColor = [UIColor lightGrayColor];
	[btn addTarget:self action:@selector(gotoMain) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *leftbbi = [[UIBarButtonItem alloc] initWithCustomView:btn];
	self.navigationItem.leftBarButtonItem = leftbbi;
	
	
	UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEvent)];
	[self.collectionView addGestureRecognizer:touchRecognizer];
	
	_events = [[NSMutableArray alloc] init];
	_months = [NSMutableArray array];
	_completedTasksSet = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self loadEvents];
}

- (void)loadEvents
{
	[_months removeAllObjects];
	[_events removeAllObjects];
	[_completedTasksSet removeAllObjects];
	
	if ([[ListEntries sharedEntries] allEntries].count > 0) {
		for (ListEntry *entry in [[ListEntries sharedEntries] allEntries]) {
			[_events addObject:entry];
			NSDate *date = entry.dateToFulfill;
			NSCalendar *cal = [NSCalendar currentCalendar];
			NSCalendarUnit unit = NSCalendarUnitMonth;
			NSDateComponents *comp = [cal components:unit fromDate:_dob toDate:date options:0];
			NSInteger month = [comp month] - 1;
			[_months addObject:[NSNumber numberWithInteger:month]];
		}
	}
	if ([[ListEntries sharedEntries] allEntries2].count > 0) {
		for (ListEntry *entry in [[ListEntries sharedEntries] allEntries2]) {
			NSDate *dateCompleted = entry.dateCompleted;
			NSCalendar *cal = [NSCalendar currentCalendar];
			NSCalendarUnit unit = NSCalendarUnitMonth;
			NSDateComponents *comp = [cal components:unit fromDate:_dob toDate:dateCompleted options:0];
			NSInteger monthCompleted = [comp month] - 1;
			[_completedTasksSet addObject:[NSNumber numberWithInteger:monthCompleted]];
		}
	}
	
	i = 0;
}

/*- (void)highlightEvents {
	
	for (NSNumber *num in _months) {
		NSUInteger n = num.intValue;
		NSIndexPath *path = [NSIndexPath indexPathWithIndex:n];
		UICollectionViewCell *eventCell = [self.collectionView cellForItemAtIndexPath:path];
		eventCell.backgroundColor = [UIColor yellowColor];
	}
	
	for (NSNumber *num in _completedTasksSet) {
		NSUInteger n = num.intValue;
		NSIndexPath *path = [NSIndexPath indexPathWithIndex:n];
		UICollectionViewCell *completedCell = [self.collectionView cellForItemAtIndexPath:path];
		completedCell.backgroundColor = [UIColor blueColor];
	}
}*/

- (void)gotoMain
{
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showEvent
{
	if (_events.count > 0) {
		
		/*
		 NSSortDescriptor *lowToHigh = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
		 [_months sortUsingDescriptors:@[lowToHigh]];
		 */
		
		//int rand  = arc4random() % _events.count;
		if (i >= _events.count) {
			i = 0;
		}
		ListEntry *entry = [_events objectAtIndex:i];
		NSString *descString = entry.desc;
		
		UITextView *view = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
		[view setBackgroundColor:[UIColor colorWithRed:39.0/255.0 green:40.0/255.0 blue:34.0/255.0 alpha:1.0]];
		[view setFont:[UIFont fontWithName:@"din-light" size:17]];
		[view setTextColor:[UIColor whiteColor]];
		[view setTextAlignment:NSTextAlignmentLeft];
		[view setEditable:false];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setLocale:[NSLocale currentLocale]];
		[formatter setDateStyle:NSDateFormatterMediumStyle];
		NSString *dateString = [formatter stringFromDate:entry.dateToFulfill];
		[view setText:[NSString stringWithFormat:@"%@\n%@", dateString, descString]];
		
		UIViewController *pop = [[UIViewController alloc] init];
		pop.view = view;
		UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController:pop];
		destNav.modalPresentationStyle = UIModalPresentationPopover;
		pop.preferredContentSize = CGSizeMake(150, 30);
		UIPopoverPresentationController *ppc;
		ppc = destNav.popoverPresentationController;
		ppc.delegate = self;
		ppc.sourceView = self.view;
		int row = [[_months objectAtIndex:i] intValue];
		NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
		ppc.sourceRect = [self.collectionView layoutAttributesForItemAtIndexPath:path].frame;
		[ppc setBackgroundColor:pop.view.backgroundColor];
		destNav.navigationBarHidden = YES;
		[self presentViewController:destNav animated:YES completion:nil];
		
		++i;
	}
}

- (void)setMonth:(int)v
{
	month = v;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (UICollectionReusableView *)collectionView:(nonnull UICollectionView *)collectionView viewForSupplementaryElementOfKind:(nonnull NSString *)kind atIndexPath:(nonnull NSIndexPath *)indexPath
{
	if (kind == UICollectionElementKindSectionHeader) {
		UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, header.frame.size.width, header.frame.size.height)];
		label.numberOfLines = 0;
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor = [UIColor whiteColor];
		label.font = [UIFont fontWithName:@"din-light" size:22];
		//label.text = [NSString stringWithFormat:@"%d/900\n\nToday begins\nthe rest of your life", month];
		label.text = [NSString stringWithFormat:@"%d/900\n\nLife is only about 900 months\r\rThis is all you have left", month];

		header.backgroundColor = [UIColor blackColor];
		[header addSubview:label];
		return  header;
	}
	return nil;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 900;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
	
	if (indexPath.row < month) {
		cell.backgroundColor = [UIColor redColor];
	}
	else cell.backgroundColor = [UIColor grayColor];
	
	if (_months.count > 0) {
		NSNumber *number = [NSNumber numberWithInteger:indexPath.row];
		if ([_months containsObject:number] && number.intValue >= month) {
			cell.backgroundColor = [UIColor yellowColor];
		}
	}
	
	if (_completedTasksSet.count > 0) {
		NSNumber *num = [NSNumber numberWithInteger:indexPath.row];
		if ([_completedTasksSet containsObject:num]) {
			cell.backgroundColor = [UIColor blueColor];
		}
	}
	
	return cell;
}

- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
	CGFloat viewWidth = ([[UIScreen mainScreen] bounds].size.width);
	CGFloat cellSize = (viewWidth - 29.0) / 30.0;
	return CGSizeMake(cellSize, cellSize);
}

- (CGFloat)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
	return 1.0;
}

- (CGFloat)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return 1.0;
}

- (UIEdgeInsets)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
	return UIEdgeInsetsMake(0,0,0,0);
}

- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
	CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
	CGFloat navbarHeight = self.navigationController.navigationBar.frame.size.height;
	return CGSizeMake(screenWidth, screenHeight - screenWidth);
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(nonnull UIPresentationController *)controller
{
	return UIModalPresentationNone;
}

@end
