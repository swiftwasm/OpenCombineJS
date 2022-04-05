# 0.2.0 (5 April 2022)

This release updates dependencies on OpenCombine and JavaScriptKit to their 0.13.0 versions.

# 0.1.2 (22 November 2021)

This is a bugfix release that fixes infinite recursion in the use of `JSValueDecoder`.

**Merged pull requests:**

- Fix infinite recursion in `JSValueDecoder` ([#6](https://github.com/swiftwasm/OpenCombineJS/pull/6)) via [@MaxDesiatov](https://github.com/MaxDesiatov)

# 0.1.1 (22 January 2021)

This release uses upstream OpenCombine 0.12.0 instead of an OpenCombine fork as it did previously.

# 0.1.0 (22 January 2021)

This release adds compatibility with JavaScriptKit 0.10, which removes generic parameters from the
`JSPromise` type.

**Merged pull requests:**

- Update `JSPromise` publisher for JSKit 0.10 ([#4](https://github.com/swiftwasm/OpenCombineJS/pull/4)) via [@MaxDesiatov](https://github.com/MaxDesiatov)

# 0.0.1 (24 November 2020)

Initial release of OpenCombineJS with `JSScheduler`, `TopLevelDecoder` implementation on
`JSValueDecoder`, and a `publisher` property on `JSPromise`.
