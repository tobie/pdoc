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
    
    this.menu = this.options.menu;
    this.links = this.menu.select('a');
    
    this.resultsElement = this.options.resultsElement;
    
    this.events = {
      filter:   this.filter.bind(this)
    };
    
    this.menu.setStyle({ opacity: 0.9 });
    this.addObservers();
    
    this.element.value = '';
  },
  
  addObservers: function() {
    this.element.observe('keyup', this.events.filter);
  },
  
  filter: function(event) {
    if (event.keyCode && event.keyCode === Event.KEY_ESC) {
      this.element.value = '';
    }
    
    var value = $F(this.element).strip().toLowerCase();
    
    if (value === "") {
      this.onEmpty();
      return;
    }
    
    var urls  = this.findURLs(value);  
    this.buildResults(urls);
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
    this.resultsElement.show();
  },
  
  findURLs: function(str) {
    var results = [];
    for (var i in PDoc.elements) {
      if (i.toLowerCase().include(str)) results.push(PDoc.elements[i]);
    }
    return results;
  },
  
  onEmpty: function() {
    this.resultsElement.hide();
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