if (typeof PDoc === "undefined") window.PDoc = {};

PDoc.highlightSelected = function(element) {
  if (!element && !window.location.hash) return;
  element = (element || $(window.location.hash.substr(1)));
  if (element) PDoc.highlight(element.up('li, div'));
};

PDoc.highlight = function(element) {
  var self = arguments.callee;
  if (!self.frame) {
    self.frame = new Element('div', { 'class': 'highlighter' });
    document.body.appendChild(self.frame);
  }
  
  var frame = self.frame;
  
  element.getOffsetParent().appendChild(frame);
  
  frame.clonePosition(element, { offsetLeft: -5, offsetTop: -5 });
  var w = parseFloat(element.getStyle('width')),
      h = parseFloat(element.getStyle('height'));
  
  frame.setStyle({
    width:  (w + 10) + 'px',
    height: (h + 10) + 'px'
  });
};

PDoc.HighlightOptions = {
  startcolor: '#e4e4e4',
  restorecolor: true,
  queue: {
    position:'end',
    scope: 'global',
    limit: 1
  }
};

var Filterer = Class.create({
  initialize: function(element, options) {
    this.element = $(element);
    this.options = Object.extend({
      interval: 0.1,
      resultsElement: '.search-results'
    }, options || {});
    
    this.element.writeAttribute("autocomplete", "off");    
    this.element.up('form').observe("submit", function(event) { event.stop(); });
    
    if (Prototype.Browser.WebKit)
      this.element.type = "search";
    
    this.menu = this.options.menu;
    this.links = this.menu.select('a');
    
    this.resultsElement = this.options.resultsElement;
    
    this.events = {
      filter:   this.filter.bind(this),
      keypress: this.keypress.bind(this)
    };
    
    this.menu.setStyle({ opacity: 0.9 });
    this.addObservers();
    
    this.element.value = '';
  },
  
  addObservers: function() {
    this.element.observe('keyup', this.events.filter);
  },
  
  filter: function(event) {
    // clear the text box on ESC
    if (event.keyCode && event.keyCode === Event.KEY_ESC) {
      this.element.value = '';
    }
    
    if ([Event.KEY_UP, Event.KEY_DOWN, Event.KEY_RETURN].include(event.keyCode))
      return;
    
    var value = $F(this.element).strip().toLowerCase();    
    if (value === "") {
      this.onEmpty();
      return;
    }
    
    var urls  = this.findURLs(value);  
    this.buildResults(urls);
  },
  
  keypress: function(event) {    
    if (![Event.KEY_UP, Event.KEY_DOWN, Event.KEY_RETURN].include(event.keyCode))
      return;
      
    event.stop();
    
    var highlighted = this.resultsElement.down('.highlighted');
    if (event.keyCode === Event.KEY_RETURN) {
      // follow the highlighted item
      if (!highlighted) return;
      window.location.href = highlighted.down('a').href;
    } else {
      // move the focus
      if (!highlighted) {
        var highlighted = this.resultsElement.down('li').addClassName('highlighted');
      } else {
        var method = (Event.KEY_DOWN === event.keyCode) ? 'next' : 'previous';
        highlighted.removeClassName('highlighted');
        var adjacent = highlighted[method]('li');
        if (!adjacent) {
          adjacent = method == 'next' ? this.resultsElement.down('li') :
           this.resultsElement.down('li:last-of-type');
        }
        adjacent.addClassName('highlighted');
        highlighted = adjacent;
      }
    }
    
    // Adjust the scroll offset of the container so that the highlighted
    // item is always in view.
    var distanceToBottom = highlighted.offsetTop + highlighted.offsetHeight;
    if (distanceToBottom > this.resultsElement.offsetHeight + this.resultsElement.scrollTop) {
      this.resultsElement.scrollTop = distanceToBottom - this.resultsElement.offsetHeight;
    } else if (highlighted.offsetTop < this.resultsElement.scrollTop) {
      this.resultsElement.scrollTop = highlighted.offsetTop;
    }
  },
  
  buildResults: function(urls) {
    this.resultsElement.update();
    var ul = this.resultsElement;
    urls.each( function(url) {
      var a  = new Element('a', {
        'class': url.type.gsub(/\s/, '_'),
        href:    PDoc.pathPrefix + url.path
      }).update(url.name);
      var li = new Element('li');
      li.appendChild(a);
      ul.appendChild(li);
    });    
    this.showResults();
  },
    
  
  findURLs: function(str) {
    var results = [];
    for (var i in PDoc.elements) {
      if (i.toLowerCase().include(str)) results.push(PDoc.elements[i]);
    }
    return results;
  },
  
  onEmpty: function() {
    this.hideResults();
  },
  
  showResults: function() {
    this.resultsElement.show();
    document.observe("keydown", this.events.keypress);
  },
  
  hideResults: function() {
    this.resultsElement.hide();
    document.stopObserving("keydown", this.events.keypress);
  }  
});

document.observe('dom:loaded', function() {
  new Filterer($('search'), { menu: $('api_menu'), resultsElement: $('search_results') });
});

document.observe('click', function(event) {
  var element = event.findElement('a');
  if (!element) return;
  var href = element.readAttribute('href');
  if (!href.include('#')) return;
  if (element = $(href.split('#').last())) {
    PDoc.highlightSelected(element);
  }
});

document.observe('dom:loaded', function() { PDoc.highlightSelected() });