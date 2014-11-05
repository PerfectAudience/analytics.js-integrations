
var Analytics = require('analytics.js').constructor;
var integration = require('analytics.js-integration');
var tester = require('analytics.js-integration-tester');
var plugin = require('./');
var sandbox = require('clear-env');

describe('FullStory', function(){
  var FullStory = plugin;
  var fullstory;
  var analytics;
  var options = {
    org: '1JO',
    debug: false
  };

  beforeEach(function(){
    analytics = new Analytics;
    fullstory = new FullStory(options);
    analytics.use(plugin);
    analytics.use(tester);
    analytics.add(fullstory);
  });

  afterEach(function(){
    analytics.restore();
    analytics.reset();
    fullstory.reset();
    sandbox();
  });

  it('should have the right settings', function(){
    analytics.compare(FullStory, integration('FullStory')
      .option('org', '')
      .option('debug', false));
  });

  describe('before loading', function(){
    beforeEach(function(){
      analytics.stub(fullstory, 'load');
    });

    describe('#initialize', function(){
      it('should create window.FS', function(){
        analytics.assert(!window.FS);
        analytics.initialize();
        analytics.page();
        analytics.assert(window.FS);
      });

      it('should call #load', function(){
        analytics.initialize();
        analytics.page();
        analytics.called(fullstory.load);
      });
    });
  });

  describe('after loading', function(){
    beforeEach(function(){
      analytics.initialize();
      analytics.page();
    });

    describe('#identify', function(){
      beforeEach(function(){
        analytics.stub(window.FS, 'identify');
      });

      it('should send an id', function(){
        analytics.identify('id');
        analytics.called(window.FS.identify, 'id');
      });

      it('should not send only traits', function(){
        analytics.identify({ trait: true });
        analytics.didNotCall(window.FS.identify);
      });

      it('should map name and email', function(){
        analytics.identify('id', { name: 'Test', email: 'test@test.com' });
        analytics.called(window.FS.identify, 'id', { displayName: 'Test', name: 'Test', id: 'id', email: 'test@test.com' });
      });
    });
  });
});
