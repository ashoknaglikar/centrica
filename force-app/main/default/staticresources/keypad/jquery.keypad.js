(function($) {
  (function(pluginName) {
    var defaults = {
      inputField: 'input.keypadCtrl',
      buttonTemplate: '<button></button>',
      submitButtonText: 'ok',
      deleteButtonText: '<',
      submitButtonClass: 'submit',
      deleteButtonClass: 'delete'
    };
    $.fn[pluginName] = function(options) {
      options = $.extend(true, {}, defaults, options);
            
      return this.each(function() {
        var elem = this,
          $elem = $(elem),
          $input = jQuery.type(options.inputField) == 'string' ? $(options.inputField) : options.inputField,
          $form = $input.parents('form').length ? $($input.parents('form')[0]) : $elem;

        var numbers = Array.apply(null, Array(9)).map(function (_, i) {
          return $(options.buttonTemplate).html(i+1).addClass('number');
        });
        numbers.push($(options.buttonTemplate).html(options.deleteButtonText).addClass(options.deleteButtonClass));
        numbers.push($(options.buttonTemplate).html("0").addClass('number'));
        //numbers.push($(options.buttonTemplate).html(options.submitButtonText).addClass(options.submitButtonClass));
        //removing submit for .
        numbers.push($(options.buttonTemplate).html(".").addClass('number'));
        $elem.html(numbers).addClass('keypad');

        $elem.find('.number').click(function(e) {
          $input.val($input.val() + $(e.target).text());
          $input.trigger('change');
          e.preventDefault();
          e.stopPropagation();
        });
        $elem.find('.' + options.deleteButtonClass).click(function(e) {
          $input.val($input.val().slice(0, -1));
          $input.trigger('change');
          e.preventDefault();
          e.stopPropagation();
        });
        $elem.find('.' + options.submitButtonClass).click(function(e) {
          $form.submit();
        });
      });
    };
    $.fn[pluginName].defaults = defaults;
  })('keypad');
})(jQuery);