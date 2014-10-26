
#
# Helpers to test only a specific `integration` or `browser`, or on a `port`.
#

integration ?= *
browser ?= ie10

#
# Binaries.
#

#wildcard i*.js
#TESTS = $(wildcard test/index.js lib/*/test/*.js)
#SRC = lib/*.js lib/*/*.js

src = lib/*/*.js test/*.js
tests = $(wildcard test/index.js lib/*/test/*.js)
duo = node_modules/.bin/duo
phantomjs = node_modules/.bin/duo-test phantomjs $(tests) args: \
	--setting local-to-remote-url-access=true \
	--setting web-security=false \
	--path node_modules/.bin/phantomjs

ifndef NODE_ENV
include node_modules/make-lint/index.mk
endif

#
# Commands.
#

default: build.js

test: lint test-style
	@node bin/tests
	@$(phantomjs)

test-browser: build.js
	@node bin/tests
	@node_modules/.bin/duo-test browser --commands "make default" $(tests)

test-sauce: node_modules build.js
	@node bin/tests
	@node_modules/.bin/duo-test saucelabs $(tests) \
		--name analytics.js-integrations \
		--browser $(browser) \
		--user $(SAUCE_USERNAME) \
		--key $(SAUCE_ACCESS_KEY)

test-cov:
	@./node_modules/.bin/istanbul cover \
		node_modules/.bin/_mocha $(TESTS) \
		--report lcovonly \
		-- -u exports \
		--require should \
		--timeout 20s \
		--reporter dot

test-style:
	@node_modules/.bin/jscs \
		lib/**/index.js \
		--config=test/style.json

clean:
	@-rm -rf $(TMPDIR)/duo
	@rm -rf build.js components integrations.js node_modules test/tests.js

#
# Targets.
#

build.js: node_modules integrations.js $(src)
	@-rm -rf $(TMPDIR)/duo
	@node bin/tests
	@$(duo) --development test/index.js > build.js

integrations.js: $(wildcard lib/*)
	@node bin/integrations

node_modules: package.json
	@npm install

#
# Phonies.
#

.PHONY: clean
.PHONY: test
.PHONY: test-browser
.PHONY: test-coverage
.PHONY: test-sauce
.PHONY: test-style