//
//  AudioRecorderController.m
//  engzo
//
//  Created by Capricorn on 12-9-3.
//  Copyright (c) 2012年 engzo. All rights reserved.
//

#import "AudioRecorderController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface AudioRecorderController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (assign, nonatomic) BOOL recording;
@property (strong, nonatomic) AVAudioPlayer * player;

- (void)startRecord;
- (NSURL *)getRecordFilePath;
- (void)playRecord;
- (void)deleteTmpFile;

@end

@implementation AudioRecorderController
@synthesize textView;
@synthesize recordButton;
@synthesize recorder;
@synthesize recording;
@synthesize sentence;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error;
	//Instanciate an instance of the AVAudioSession object.
	AVAudioSession * audioSession = [AVAudioSession sharedInstance];
	//Setup the audioSession for playback and record.
	//We could just use record and then switch it to playback leter, but
	//since we are going to do both lets set it up once.
	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
	//Activate the session
	[audioSession setActive:YES error: &error];
    
    self.textView.text = sentence;
}

- (void)viewDidUnload
{
    [self setRecordButton:nil];
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSURL *)getRecordFilePath {
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", @"test", @"caf"]]];
}

- (IBAction)record_button_pressed:(id)sender {
    if (!self.recording) {
        self.recording = YES;
        [self.recordButton setTitle:@"点击停止" forState:UIControlStateNormal];
        [self startRecord];
    } else {
        self.recording = NO;
        [self.recordButton setTitle:@"点击录音" forState:UIControlStateNormal];
        //Stop the recorder.
		[recorder stop];
        [self playRecord];
    }
}

- (void)startRecord {
    NSLog(@"startRecord");
    //Begin the recording session.
    //Error handling removed.  Please add to your own code.
    
    //Setup the dictionary object with all the recording settings that this
    //Recording sessoin will use
    //Its not clear to me which of these are required and which are the bare minimum.
    //This is a good resource: http://www.totodotnet.net/tag/avaudiorecorder/
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleLossless] forKey:AVFormatIDKey];
    
    [recordSetting setValue:[NSNumber numberWithFloat:44110] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    //Now that we have our settings we are going to instanciate an instance of our recorder instance.
    //Generate a temp file for use by the recording.
    //This sample was one I found online and seems to be a good choice for making a tmp file that
    //will not overwrite an existing one.
    //I know this is a mess of collapsed things into 1 call.  I can break it out if need be.
    NSURL *recordedTmpFile = [self getRecordFilePath];
    NSLog(@"Using File called: %@",recordedTmpFile);
    
    NSError *error;
    //Setup the recorder to use this file and record to it.
    recorder = [[ AVAudioRecorder alloc] initWithURL:recordedTmpFile settings:recordSetting error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    //Use the recorder to start the recording.
    //Im not sure why we set the delegate to self yet.
    //Found this in antother example, but Im fuzzy on this still.
    //		[recorder setDelegate:self];
    //We call this to start the recording process and initialize
    //the subsstems so that when we actually say "record" it starts right away.
    [recorder prepareToRecord];
    //Start the actual Recording
    [recorder record];
    //There is an optional method for doing the recording for a limited time see
    //[recorder recordForDuration:(NSTimeInterval) 10]
}

- (void)playRecord {
    NSLog(@"playRecord");
    NSError *error;
    //Setup the AVAudioPlayer to play the file that we just recorded.
    if (!self.player) {
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[self getRecordFilePath] error:&error];
        
        if (error) {
            NSLog(@"%@", error);
        }
    }	
    
	[self.player prepareToPlay];
	[self.player play];

}

- (void)deleteTmpFile {
    NSError *error;
    //Clean up the temp file.
	NSFileManager * fm = [NSFileManager defaultManager];
	[fm removeItemAtPath:[[self getRecordFilePath] path] error:&error];
}

@end
