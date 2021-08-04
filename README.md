# FlickrImageDownloader

FlickrImageDownloader is an image downloader that uses the flickr API. The development language is Swift.

To use it, you need flicker apikey, see [flicker page]((https://www.flickr.com/services/apps/create/apply/)) for creating apikey.

## Installing

Place `flcim` in `Export` in your `/usr/local/bin`.

## Usage

It can be used as follows

`flcim <api-key> <text> [--count <count>] [--page <page>]`

For example, if you want to search for images of cats...

`flcim api-key cat --count 100`

The downloaded images will be stored in the document directory.

## Contributions

Pull requests and issues are always welcome. Please open any issues and PRs for bugs, features, or documentation.

## License

XcodeGen is licensed under the MIT license. See [LICENSE](https://github.com/yyokii/FlickrImageDownloader/blob/main/LICENSE) for more info.

