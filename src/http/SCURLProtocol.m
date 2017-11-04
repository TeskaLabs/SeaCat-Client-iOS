#import "SeaCatInternals.h"
#import "SCCanonicalRequest.h"

// Heavily inspired by https://github.com/twitter/CocoaSPDY
// For more info see: http://nshipster.com/nsurlprotocol/

///

NSString * SeaCatHostSuffix = @".seacat";

///

@implementation SCURLProtocol
{
    struct {
        BOOL didStartLoading:1;
        BOOL didStopLoading:1;
    } flags;
}

#pragma mark NSURLProtocol implementation

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{

    NSString *scheme = request.URL.scheme.lowercaseString;
    if ([scheme isEqualToString:@"http"] | [scheme isEqualToString:@"https"])
	{
		return [request.URL.host hasSuffix:SeaCatHostSuffix];
	}
	
	return FALSE;
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *canonicalRequest = SCCanonicalRequestForRequest(request);
    [SCURLProtocol setProperty:@(YES) forKey:@"x-spdy-is-canonical-request" inRequest:canonicalRequest];
    return canonicalRequest;
}


- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
    // iOS 8 will call this using the 'request' returned from canonicalRequestForRequest. However,
    // iOS 7 passes the original (non-canonical) request. As SPDYCanonicalRequestForRequest is
    // somewhat heavyweight, we'll use a flag to detect non-canonical requests. Ensuring the
    // canonical form is used for processing is important for correctness.
    BOOL isCanonical = ([SCURLProtocol propertyForKey:@"x-spdy-is-canonical-request" inRequest:request] != nil);
    if (!isCanonical) {
        request = [SCURLProtocol canonicalRequestForRequest:request];
    }
    
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

///

- (void)startLoading
{
    // Only allow one startLoading call. iOS 8 using NSURLSession has exhibited different
    // behavior, by calling startLoading, then stopLoading, then startLoading, etc, over and
    // over. This happens asynchronously when using a NSURLSessionDataTaskDelegate after the
    // URLSession:dataTask:didReceiveResponse:completionHandler: callback.
    if (flags.didStartLoading != 0) {
        SCLOG_WARN(@"start loading already called, ignoring %@", self.request.URL.absoluteString);
        return;
    }
    flags.didStartLoading = 1;

    if (SeaCatReactor == NULL)
    {
        SCLOG_ERROR(@"URL request when not initialized.");
        [[self client]
            URLProtocol:self
            didFailWithError:SeaCatError(SeaCat_ErrorCore_GENERIC, @"SeaCat URL request started but SeaCat is not ready.")
         ];

        return; // Report error
    }

    SCLOG_DEBUG(@"SCURLProtocol >> startLoading: %@", self);
    [[self client]
        URLProtocol:self
        didFailWithError:SeaCatError(SeaCat_ErrorCore_GENERIC, @"startLoading not implemented.")
    ];

}

- (void)stopLoading
{
    SCLOG_DEBUG(@"SCURLProtocol >> stopLoading: %@", self);
    
    flags.didStopLoading = 1;
}

@end
