(function ($) {

// When the document loads do everything inside here ...  
  $(document).ready(function(){  
  
    // When a link is clicked  
    $("a.tab").click(function () {  
  
        // switch all tabs off  
        $(".active").removeClass("active");  
  
        // switch this tab on  
        $(this).addClass("active");  
  
        // slide all elements with the class 'content' up  
        $(".content").slideUp();  
  
        // Now figure out what the 'title' attribute value is and find the element with that id.  Then slide that down.  
        var content_show = $(this).attr("title");  
        $("#"+content_show).slideDown();  
  
    });  
  
  });  

})(jQuery);