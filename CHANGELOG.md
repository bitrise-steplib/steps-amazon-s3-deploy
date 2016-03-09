## Changelog (Current version: 3.5.0)

-----------------

### 3.5.0 (2016 Mar 09)

* [4d941b5] prepare for release
* [1ea5ec7] Merge pull request #16 from bitrise-io/defult_inputs_log_improvements
* [c7eac80] bucket_region fix
* [279f4d3] inputs default values, log improvements

### 3.4.0 (2016 Feb 15)

* [85848a6] Merge pull request #14 from godrei/find_app
* [1e8fc5c] * fix: find app based on ipa path * avoid to find inner .app, inside the ipa * check if generate info.plist success

### 3.3.0 (2016 Feb 01)

* [b031069] Merge pull request #12 from godrei/public_url_fix
* [f7c55b8] yml fix: removed default value
* [36b2e22] public url fix
* [b3cd98c] bitrise.yml : update to be compatible with Bitrise CLI 1.3.0
* [8a11af9] update to new `deps` format

### 3.2.0 (2015 Oct 20)

* [0695e6a] formatted output -> changed to simply log
* [9803469] replaced `s3cmd` with the official `awscli`
* [822f2cf] Merge pull request #8 from bazscsa/patch-1
* [d2fc2fd] Update step.yml

### 3.1.1 (2015 Sep 16)

* [a3953cf] Merge pull request #7 from gkiki90/update
* [5526be6] path fix

### 3.1.0 (2015 Sep 10)

* [be125d5] Merge pull request #6 from gkiki90/update
* [ccce63b] fix

### 3.0.0 (2015 Sep 08)

* [763999c] bitrise stack related update
* [4a2f28d] Merge pull request #5 from gkiki90/update
* [ec0c10f] update

### 2.5.0 (2015 Feb 16)

* [14b0013] upload success info
* [46426a0] uploading status text format change
* [9ef9247] dsym option info text format change
* [d4277f2] dSYM is now optional
* [64b0efb] readme and formatted output update
* [0a71244] step.yml update

### 2.4.0 (2015 Jan 23)

* [1f22b73] minor error msg fix
* [c08eb81] step.yml fix
* [ddc6d41] step.yml : a couple of default values
* [1a0dc05] new s3cmd (1.5.0) OS X fix & step.yml update
* [1dc603c] step.yml update
* [e18a94b] Merge pull request #4 from erosdome/master
* [de1f648] Update step.yml
* [76957e2] Update step.yml
* [5dfb373] steplib links included in yaml
* [d2dd5fd] steplib links included in readme

### 2.3.4 (2014 Sep 08)

* [7b4f593] debug infos removed

### 2.3.3 (2014 Sep 08)

* [2a70046] debug: formatted output

### 2.3.2 (2014 Sep 08)

* [52e6d7a] force flush for formatted_output

### 2.3.1 (2014 Sep 08)

* [d1af894] small step.yml fix and install link title fix

### 2.3.0 (2014 Sep 08)

* [3ac7ac5] better default route in bucket (timestamp prefix for build, not for the app) + a markdown related 'install link' fix

### 2.2.0 (2014 Sep 08)

* [d4c8f21] app-title not used anymore, for better/safer URLs

### 2.1.0 (2014 Sep 08)

* [3c8c851] install plist fix

### 2.0.2 (2014 Sep 08)

* [bbc6b19] readme cleanup

### 2.0.1 (2014 Sep 08)

* [e5b9670] path handling fix (guard with parentheses) + typo fix

### 2.0.0 (2014 Sep 08)

* [b333a44] rewrite to use s3cmd (installed with brew) instead of the S3 Ruby GEM
* [65d48c8] README and step.yml update + step_test update

### 1.1.2 (2014 Aug 02)

* [6b2b48d] Merge branch 'release/1.1.2'
* [c23203d] printing a bit more info and the raw links too (because markdown can interpret certain characters in the links not the way we intend)

### 1.1.1 (2014 Aug 02)

* [154e38a] Merge branch 'release/1.1.1'
* [d4c4126] puts fix

### 1.1.0 (2014 Aug 02)

* [48e2f5d] Merge branch 'release/1.1.0'
* [e8e02d5] formatted output support

### 1.0.4 (2014 Jul 21)

* [59a9431] Merge branch 'release/1.0.4'
* [43b06d0] prefix default path-in-bucket with timestamp

### 1.0.3 (2014 Jul 21)

* [566997f] Merge pull request #3 from tomfurrier/master
* [7d21820] app name extracted properly from .ipa path
* [9b7bdbf] rename to bitrise
* [9174d90] test file changed, but ruby cannot be tested. TODO
* [438e4c4] CONCRETE_ARCHIVE_STATUS input env var removed because it is not used in this step. Added initial tests file

### 1.0.2 (2014 Jun 13)

* [c2adb06] Merge branch 'release/1.0.2'
* [abd1f96] removed 'CONCRETE_DEPLOY_' outputs, only the 'S3_DEPLOY_STEP_' outputs kept + step descriptor 'step.yml' added

-----------------

Updated: 2016 Mar 09